"""Modelagem da rede de trens e metrô como grafo dirigido e ponderado.

Vértices
  ("E", estação)          estar na estação, fora do trem (saguão)
  ("P", estação, linha)   estar dentro de um trem da linha, parado na estação

Arestas (peso em minutos)
  viagem     P(s, L) -> P(s', L)  tempo até a estação vizinha (nos dois sentidos)
  embarque   E(s)    -> P(s, L)   espera média do trem + atrasos ativos da linha
  desembarque P(s, L) -> E(s)     tempo de baldeação da estação

A origem de uma rota é o vértice E(origem); o destino é qualquer P(destino, L),
ou seja, o passageiro chega quando o trem para na estação de destino. Assim a
baldeação só é cobrada quando ele desce para pegar outra linha.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from .dados import Rede

# Hipóteses do protótipo (minutos de espera média na plataforma).
ESPERA_MEDIA = {"METRO": 3, "MONOTRILHO": 4, "TREM": 5, "BRT": 6}
# Tipos que atrasam a linha inteira (atraso, trem parado, trem recolhido).
TIPOS_LINHA = {1, 2, 6}
# Superlotação atrasa só quem embarca naquela estação (espera trens passarem).
TIPO_SUPERLOTACAO = 3

EMBARQUE, VIAGEM, DESEMBARQUE = "embarque", "viagem", "desembarque"


@dataclass
class Grafo:
    vertices: list[tuple] = field(default_factory=list)
    indice: dict[tuple, int] = field(default_factory=dict)
    arestas: list[tuple[int, int, float, str]] = field(default_factory=list)  # (u, v, peso, tipo)
    estacoes_bloqueadas: set[int] = field(default_factory=set)
    avisos: list[str] = field(default_factory=list)

    def vertice(self, chave: tuple) -> int:
        if chave not in self.indice:
            self.indice[chave] = len(self.vertices)
            self.vertices.append(chave)
        return self.indice[chave]

    def ligar(self, a: tuple, b: tuple, peso: float, tipo: str) -> None:
        self.arestas.append((self.vertice(a), self.vertice(b), float(peso), tipo))

    def entradas(self) -> list[list[tuple[int, float, str]]]:
        """Lista de adjacência invertida: para cada v, as arestas (u, peso, tipo) que chegam nele."""
        lista: list[list[tuple[int, float, str]]] = [[] for _ in self.vertices]
        for u, v, peso, tipo in self.arestas:
            lista[v].append((u, peso, tipo))
        return lista


def montar_grafo(
    rede: Rede,
    momento: datetime | None = None,
    mobilidade_reduzida: bool = False,
    incluir_abertas: bool = False,
) -> Grafo:
    """Monta o grafo do cenário: sem `momento`, a rede funciona normalmente."""
    g = Grafo()
    for est_id in rede.estacoes:
        g.vertice(("E", est_id))

    ativas = rede.ocorrencias_ativas(momento, incluir_abertas) if momento else []
    atraso_linha: dict[int, int] = {}
    atraso_embarque: dict[tuple[int, int], int] = {}
    for o in ativas:
        tipo = o["id_tipo_ocorrencia"]
        if tipo in TIPOS_LINHA:
            atraso_linha[o["id_linha"]] = atraso_linha.get(o["id_linha"], 0) + o["nr_atraso_min"]
        elif tipo == TIPO_SUPERLOTACAO and o["id_estacao"]:
            chave = (o["id_estacao"], o["id_linha"])
            atraso_embarque[chave] = atraso_embarque.get(chave, 0) + o["nr_atraso_min"]
        if rede.tipos[tipo]["afeta_acessibilidade"] and o["id_estacao"] and mobilidade_reduzida:
            g.estacoes_bloqueadas.add(o["id_estacao"])
            g.avisos.append(f"{rede.tipos[tipo]['nome']} em {rede.estacoes[o['id_estacao']]['nome']}")
        if tipo not in (4, 5):
            onde = rede.estacoes[o["id_estacao"]]["nome"] if o["id_estacao"] else "linha inteira"
            g.avisos.append(f"{rede.nome_linha(o['id_linha'])}: {o['ds_ocorrencia']} ({onde}, +{o['nr_atraso_min']} min)")
    if mobilidade_reduzida:
        for est_id, est in rede.estacoes.items():
            if not est["acessivel"]:
                g.estacoes_bloqueadas.add(est_id)

    for linha_id, paradas in rede.sequencias.items():
        modal = rede.linhas[linha_id]["modal"]
        for i, (est_id, min_proxima) in enumerate(paradas):
            plataforma = ("P", est_id, linha_id)
            if est_id not in g.estacoes_bloqueadas:
                espera = ESPERA_MEDIA[modal] + atraso_linha.get(linha_id, 0) + atraso_embarque.get((est_id, linha_id), 0)
                g.ligar(("E", est_id), plataforma, espera, EMBARQUE)
                g.ligar(plataforma, ("E", est_id), rede.estacoes[est_id]["baldeacao"], DESEMBARQUE)
            else:
                g.vertice(plataforma)  # o trem passa pela estação, mas não dá para descer ou subir
            if i + 1 < len(paradas):
                vizinha = ("P", paradas[i + 1][0], linha_id)
                g.ligar(plataforma, vizinha, min_proxima, VIAGEM)
                g.ligar(vizinha, plataforma, min_proxima, VIAGEM)
    return g


def destinos(g: Grafo, estacao_id: int) -> list[int]:
    """Vértices que contam como chegada na estação (qualquer plataforma dela)."""
    return [i for i, v in enumerate(g.vertices) if v[0] == "P" and v[1] == estacao_id]
