"""Técnica 3 · TABULAÇÃO: onde colocar os trens reserva (mochila 0/1).

Os registros de lotação feitos pelos passageiros mostram onde e quando a rede
fica mais cheia. A operadora tem poucos trens reserva para o horário de pico e
precisa escolher em quais pontos colocá-los para aliviar o maior número de
passageiros. É o problema da mochila 0/1:

    item       = reforçar uma linha num sentido e período (ex.: Linha 3, sentido
                 Palmeiras-Barra Funda, pico da manhã)
    custo      = trens reserva necessários (metrô 1; trem metropolitano 2,
                 porque as composições são maiores e mais caras de mobilizar)
    benefício  = pontos de alívio, calculados a partir da lotação informada

    tabela[i][c] = maior benefício usando só os i primeiros itens e até c trens
    tabela[i][c] = max( tabela[i-1][c],
                        tabela[i-1][c - custo_i] + beneficio_i   se custo_i <= c )

A tabela (n+1) x (C+1) é preenchida linha a linha: O(n · C), contra O(2^n) de
testar todas as combinações (função `forca_bruta`, usada para conferir).
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations

from .dados import Rede

TRENS_POR_MODAL = {"METRO": 1, "MONOTRILHO": 1, "TREM": 2, "BRT": 1}
PASSAGEIROS_POR_PONTO = 120  # hipótese: cada ponto de alívio ~ 120 passageiros/hora que embarcam melhor
NIVEL_CONFORTAVEL = 2        # 1 vazia, 2 tranquila, 3 moderada, 4 cheia, 5 superlotada


@dataclass(frozen=True)
class Reforco:
    linha_id: int
    sentido: str
    periodo: str
    estacoes: tuple[str, ...]
    custo: int
    beneficio: int


def periodo_de(hora: int) -> str | None:
    if 6 <= hora < 10:
        return "pico da manhã"
    if 16 <= hora < 20:
        return "pico da tarde"
    return None  # fora do pico: não entra no planejamento de reforço


def candidatos(rede: Rede) -> list[Reforco]:
    grupos: dict[tuple[int, str, str], list[dict]] = {}
    for r in rede.lotacao:
        periodo = periodo_de(r["dt_registro"].hour)
        if periodo:
            grupos.setdefault((r["id_linha"], r["ds_sentido"], periodo), []).append(r)
    itens = []
    for (linha_id, sentido, periodo), regs in sorted(grupos.items()):
        beneficio = sum(max(0, r["nr_nivel"] - NIVEL_CONFORTAVEL) for r in regs)
        if beneficio == 0:
            continue
        estacoes = tuple(sorted({rede.estacoes[r["id_estacao"]]["nome"] for r in regs}))
        custo = TRENS_POR_MODAL[rede.linhas[linha_id]["modal"]]
        itens.append(Reforco(linha_id, sentido, periodo, estacoes, custo, beneficio))
    return itens


def mochila(itens: list[Reforco], capacidade: int) -> tuple[int, list[Reforco], list[list[int]]]:
    n = len(itens)
    tabela = [[0] * (capacidade + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        item = itens[i - 1]
        for c in range(capacidade + 1):
            tabela[i][c] = tabela[i - 1][c]
            if item.custo <= c:
                tabela[i][c] = max(tabela[i][c], tabela[i - 1][c - item.custo] + item.beneficio)
    # reconstrução: volta pela tabela vendo quais itens mudaram o valor
    escolhidos, c = [], capacidade
    for i in range(n, 0, -1):
        if tabela[i][c] != tabela[i - 1][c]:
            escolhidos.append(itens[i - 1])
            c -= itens[i - 1].custo
    return tabela[n][capacidade], list(reversed(escolhidos)), tabela


def forca_bruta(itens: list[Reforco], capacidade: int) -> int:
    melhor = 0
    for tamanho in range(len(itens) + 1):
        for combo in combinations(itens, tamanho):
            if sum(i.custo for i in combo) <= capacidade:
                melhor = max(melhor, sum(i.beneficio for i in combo))
    return melhor
