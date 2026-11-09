"""Leitura dos dados do Embarque Certo.

Os dados vêm do mesmo script DML entregue na disciplina de Database Design
(dados/02_DML_EmbarqueCerto.sql). Assim, o algoritmo de rotas trabalha
exatamente com a rede, as ocorrências e os registros de lotação do banco.
"""
from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

CAMINHO_PADRAO = Path(__file__).resolve().parent.parent / "dados" / "02_DML_EmbarqueCerto.sql"

_INSERT = re.compile(r"INSERT\s+INTO\s+(\w+)\s*\(([^)]*)\)\s*VALUES\s*\((.*?)\);", re.S | re.I)
_FORMATOS_DATA = {"YYYY-MM-DD HH24:MI": "%Y-%m-%d %H:%M", "YYYY-MM-DD": "%Y-%m-%d"}


def _separar_valores(texto: str) -> list[str]:
    """Divide a lista de VALUES nas vírgulas de primeiro nível (fora de aspas e parênteses)."""
    partes, atual, profundidade, em_aspas, i = [], [], 0, False, 0
    while i < len(texto):
        c = texto[i]
        if em_aspas:
            atual.append(c)
            if c == "'":
                if i + 1 < len(texto) and texto[i + 1] == "'":  # aspas escapadas ''
                    atual.append("'")
                    i += 1
                else:
                    em_aspas = False
        elif c == "'":
            em_aspas = True
            atual.append(c)
        elif c == "(":
            profundidade += 1
            atual.append(c)
        elif c == ")":
            profundidade -= 1
            atual.append(c)
        elif c == "," and profundidade == 0:
            partes.append("".join(atual).strip())
            atual = []
        else:
            atual.append(c)
        i += 1
    partes.append("".join(atual).strip())
    return partes


def _converter(valor: str):
    if valor.upper() == "NULL":
        return None
    if valor.startswith("'") and valor.endswith("'"):
        return valor[1:-1].replace("''", "'")
    m = re.fullmatch(r"TO_DATE\(\s*'([^']*)'\s*,\s*'([^']*)'\s*\)", valor, re.I)
    if m:
        return datetime.strptime(m.group(1), _FORMATOS_DATA[m.group(2).upper()])
    if re.fullmatch(r"-?\d+", valor):
        return int(valor)
    if re.fullmatch(r"-?\d+\.\d+", valor):
        return float(valor)
    raise ValueError(f"Valor não reconhecido no DML: {valor!r}")


def ler_inserts(caminho: Path | str = CAMINHO_PADRAO) -> dict[str, list[dict]]:
    """Devolve {tabela: [linha como dicionário]} a partir dos INSERTs do script."""
    texto = Path(caminho).read_text(encoding="utf-8")
    # remove comentários de linha para não confundir o parser
    texto = "\n".join(l for l in texto.splitlines() if not l.lstrip().startswith("--"))
    tabelas: dict[str, list[dict]] = {}
    for tabela, colunas, valores in _INSERT.findall(texto):
        nomes = [c.strip().lower() for c in colunas.split(",")]
        convertidos = [_converter(v) for v in _separar_valores(valores)]
        if len(nomes) != len(convertidos):
            raise ValueError(f"{tabela}: {len(nomes)} colunas e {len(convertidos)} valores")
        tabelas.setdefault(tabela.lower(), []).append(dict(zip(nomes, convertidos)))
    return tabelas


def normalizar(texto: str) -> str:
    """Compara nomes sem acento, caixa ou espaços extras ("se" encontra "Sé")."""
    sem_acento = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode()
    return " ".join(sem_acento.lower().replace("-", " ").split())


@dataclass
class Rede:
    linhas: dict[int, dict] = field(default_factory=dict)        # id -> numero, nome, modal
    estacoes: dict[int, dict] = field(default_factory=dict)      # id -> nome, acessivel, baldeacao
    sequencias: dict[int, list[tuple[int, int | None]]] = field(default_factory=dict)  # linha -> [(estacao, min_proxima)]
    tipos: dict[int, dict] = field(default_factory=dict)         # id -> nome, afeta_acessibilidade
    ocorrencias: list[dict] = field(default_factory=list)
    lotacao: list[dict] = field(default_factory=list)

    def nome_linha(self, linha_id: int) -> str:
        l = self.linhas[linha_id]
        return f"Linha {l['numero']}-{l['nome']}"

    def estacao_por_nome(self, nome: str) -> int:
        alvo = normalizar(nome)
        for est_id, est in self.estacoes.items():
            if normalizar(est["nome"]) == alvo:
                return est_id
        parecidas = [e["nome"] for e in self.estacoes.values() if alvo in normalizar(e["nome"])]
        if len(parecidas) == 1:
            return self.estacao_por_nome(parecidas[0])
        opcoes = ", ".join(sorted(e["nome"] for e in self.estacoes.values()))
        raise KeyError(f"Estação '{nome}' não encontrada. Opções: {opcoes}")

    def ocorrencias_ativas(self, momento: datetime, incluir_abertas: bool = False) -> list[dict]:
        """Ocorrências em andamento no momento: CONFIRMADA (e ABERTA, se pedido)."""
        situacoes = {"CONFIRMADA", "ABERTA"} if incluir_abertas else {"CONFIRMADA"}
        return [
            o for o in self.ocorrencias
            if o["st_ocorrencia"] in situacoes
            and o["dt_inicio"] <= momento
            and (o["dt_fim"] is None or o["dt_fim"] > momento)
        ]


def carregar_rede(caminho: Path | str = CAMINHO_PADRAO) -> Rede:
    t = ler_inserts(caminho)
    rede = Rede()
    for r in t["t_ec_linha"]:
        rede.linhas[r["id_linha"]] = {"numero": r["nr_linha"], "nome": r["nm_linha"], "modal": r["tp_modal"]}
    for r in t["t_ec_estacao"]:
        rede.estacoes[r["id_estacao"]] = {
            "nome": r["nm_estacao"],
            "acessivel": r["st_acessivel"] == "S",
            "baldeacao": r["nr_min_baldeacao"],
        }
    paradas = sorted(t["t_ec_linha_estacao"], key=lambda r: (r["id_linha"], r["nr_ordem"]))
    for r in paradas:
        rede.sequencias.setdefault(r["id_linha"], []).append((r["id_estacao"], r["nr_min_proxima"]))
    for r in t["t_ec_tipo_ocorrencia"]:
        rede.tipos[r["id_tipo_ocorrencia"]] = {
            "nome": r["nm_tipo"],
            "afeta_acessibilidade": r["st_afeta_acessibilidade"] == "S",
        }
    rede.ocorrencias = t["t_ec_ocorrencia"]
    rede.lotacao = t["t_ec_registro_lotacao"]
    return rede
