"""Técnica 2 · MEMOIZAÇÃO: rota mais rápida com limite de embarques.

Muita gente prefere uma viagem um pouco mais longa a fazer várias baldeações,
principalmente idosos, gestantes e quem carrega bagagem. Esse limite não cabe
no Floyd-Warshall, então o problema ganha uma dimensão a mais:

    melhor(v, k, b) = menor tempo da origem até v usando no máximo k arestas
                      e no máximo b embarques

    melhor(origem, k, b) = 0
    melhor(v, 0, b)      = infinito, se v != origem
    melhor(v, k, b)      = min( melhor(v, k-1, b),
                                min sobre arestas u->v de
                                    melhor(u, k-1, b - [a aresta é embarque]) + peso )

É um Bellman-Ford escrito de cima para baixo. A recursão pura repete os mesmos
subproblemas um número exponencial de vezes; guardando cada resposta num
dicionário (memo), cada estado (v, k, b) é calculado uma única vez:
O(V · K · B) estados, cada um olhando as arestas que chegam em v.
"""
from __future__ import annotations

import sys
from dataclasses import dataclass, field

from .grafo import EMBARQUE, Grafo, destinos
from .rotas import INF, Rota

sys.setrecursionlimit(10000)


@dataclass
class ResolvedorMemo:
    g: Grafo
    origem_estacao: int
    memo: dict[tuple[int, int, int], tuple[float, tuple | None]] = field(default_factory=dict)
    chamadas: int = 0

    def __post_init__(self):
        self.entradas = self.g.entradas()
        self.origem = self.g.indice[("E", self.origem_estacao)]

    def melhor(self, v: int, k: int, b: int) -> tuple[float, tuple | None]:
        """Devolve (tempo, decisão) — a decisão (u, k-1, b') permite reconstruir o caminho."""
        self.chamadas += 1
        chave = (v, k, b)
        if chave in self.memo:
            return self.memo[chave]
        if v == self.origem:
            resposta = (0.0, None)
        elif k == 0:
            resposta = (INF, None)
        else:
            resposta = self.melhor(v, k - 1, b)
            resposta = (resposta[0], ("mesmo", v, k - 1, b)) if resposta[0] < INF else resposta
            for u, peso, tipo in self.entradas[v]:
                nb = b - 1 if tipo == EMBARQUE else b
                if nb < 0:
                    continue
                custo = self.melhor(u, k - 1, nb)[0] + peso
                if custo < resposta[0]:
                    resposta = (custo, ("aresta", u, k - 1, nb))
        self.memo[chave] = resposta
        return resposta

    def caminho(self, v: int, k: int, b: int) -> list[int]:
        vs = [v]
        while v != self.origem:
            _, decisao = self.memo[(v, k, b)]
            tipo, u, k, b = decisao
            if tipo == "aresta":
                vs.append(u)
                v = u
        return list(reversed(vs))


def rota_com_limite(g: Grafo, origem: int, destino: int, max_embarques: int) -> tuple[Rota | None, ResolvedorMemo]:
    resolvedor = ResolvedorMemo(g, origem)
    if origem in g.estacoes_bloqueadas or destino in g.estacoes_bloqueadas:
        return None, resolvedor
    k = len(g.vertices) - 1  # um caminho simples nunca precisa de mais arestas que isso
    candidatos = [(resolvedor.melhor(j, k, max_embarques)[0], j) for j in destinos(g, destino)]
    tempo, melhor_j = min(candidatos, default=(INF, None))
    if melhor_j is None or tempo == INF:
        return None, resolvedor
    vs = resolvedor.caminho(melhor_j, k, max_embarques)
    embarques = sum(1 for a, b in zip(vs, vs[1:]) if g.vertices[a][0] == "E" and g.vertices[b][0] == "P")
    return Rota(tempo, vs, embarques), resolvedor


def recursao_sem_memo(g: Grafo, origem: int, destino: int, k: int, b: int) -> tuple[float, int]:
    """Mesma recorrência SEM memo, só para medir a explosão de chamadas (use k pequeno)."""
    entradas = g.entradas()
    o = g.indice[("E", origem)]
    chamadas = 0

    def melhor(v: int, k: int, b: int) -> float:
        nonlocal chamadas
        chamadas += 1
        if v == o:
            return 0.0
        if k == 0:
            return INF
        r = melhor(v, k - 1, b)
        for u, peso, tipo in entradas[v]:
            nb = b - 1 if tipo == EMBARQUE else b
            if nb >= 0:
                r = min(r, melhor(u, k - 1, nb) + peso)
        return r

    tempo = min((melhor(j, k, b) for j in destinos(g, destino)), default=INF)
    return tempo, chamadas
