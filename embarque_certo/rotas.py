"""Técnica 1 · GRAFOS + TABULAÇÃO: Floyd-Warshall.

Subproblema: dist[k][i][j] = menor tempo de i até j usando como intermediários
apenas os vértices 0..k-1. Recorrência:

    dist[k][i][j] = min(dist[k-1][i][j], dist[k-1][i][k] + dist[k-1][k][j])

A tabela é preenchida de baixo para cima (tabulação), reaproveitando a mesma
matriz V x V a cada k. Depois de O(V³) operações, uma única tabela responde a
pergunta "qual o caminho mais rápido de qualquer estação para qualquer outra",
que é o que o aplicativo precisa para mostrar rotas na hora, sem recalcular.
A matriz `proximo` guarda a primeira decisão de cada caminho para reconstruí-lo.
"""
from __future__ import annotations

from dataclasses import dataclass

from .dados import Rede
from .grafo import DESEMBARQUE, EMBARQUE, Grafo, destinos

INF = float("inf")


@dataclass
class TabelaRotas:
    dist: list[list[float]]
    proximo: list[list[int | None]]
    operacoes: int  # quantas atualizações de célula foram avaliadas (noção de custo)


def floyd_warshall(g: Grafo) -> TabelaRotas:
    n = len(g.vertices)
    dist = [[INF] * n for _ in range(n)]
    proximo: list[list[int | None]] = [[None] * n for _ in range(n)]
    for i in range(n):
        dist[i][i] = 0.0
        proximo[i][i] = i
    for u, v, peso, _ in g.arestas:
        if peso < dist[u][v]:
            dist[u][v] = peso
            proximo[u][v] = v
    operacoes = 0
    for k in range(n):
        dk = dist[k]
        for i in range(n):
            dik = dist[i][k]
            if dik == INF:
                continue
            di, pi = dist[i], proximo[i]
            for j in range(n):
                operacoes += 1
                novo = dik + dk[j]
                if novo < di[j]:
                    di[j] = novo
                    pi[j] = pi[k]
    return TabelaRotas(dist, proximo, operacoes)


def caminho(tabela: TabelaRotas, i: int, j: int) -> list[int]:
    if tabela.proximo[i][j] is None:
        return []
    passos = [i]
    while i != j:
        i = tabela.proximo[i][j]
        passos.append(i)
    return passos


@dataclass
class Rota:
    minutos: float
    vertices: list[int]
    embarques: int

    def trechos(self, g: Grafo, rede: Rede) -> list[str]:
        return descrever(self.vertices, g, rede)


def melhor_rota(g: Grafo, tabela: TabelaRotas, origem: int, destino: int) -> Rota | None:
    """Consulta a tabela já calculada: O(número de plataformas do destino)."""
    if destino in g.estacoes_bloqueadas or origem in g.estacoes_bloqueadas:
        return None
    i = g.indice[("E", origem)]
    melhor = min(destinos(g, destino), key=lambda j: tabela.dist[i][j], default=None)
    if melhor is None or tabela.dist[i][melhor] == INF:
        return None
    vs = caminho(tabela, i, melhor)
    return Rota(tabela.dist[i][melhor], vs, contar_embarques(g, vs))


def contar_embarques(g: Grafo, vs: list[int]) -> int:
    return sum(1 for a, b in zip(vs, vs[1:]) if g.vertices[a][0] == "E" and g.vertices[b][0] == "P")


def descrever(vs: list[int], g: Grafo, rede: Rede) -> list[str]:
    """Transforma a sequência de vértices em instruções para o passageiro."""
    pesos = {(u, v): p for u, v, p, _ in g.arestas}
    tipos = {(u, v): t for u, v, _, t in g.arestas}
    passos: list[str] = []
    viagem_inicio, minutos_viagem = None, 0.0
    for a, b in zip(vs, vs[1:]):
        tipo, peso = tipos[(a, b)], pesos[(a, b)]
        va, vb = g.vertices[a], g.vertices[b]
        if tipo == EMBARQUE:
            passos.append(f"Embarque na {rede.nome_linha(vb[2])} em {rede.estacoes[vb[1]]['nome']} "
                          f"(espera prevista {peso:.0f} min)")
            viagem_inicio, minutos_viagem = vb, 0.0
        elif tipo == DESEMBARQUE:
            passos.append(f"Siga até {rede.estacoes[va[1]]['nome']} ({minutos_viagem:.0f} min)")
            passos.append(f"Baldeação em {rede.estacoes[va[1]]['nome']} ({peso:.0f} min a pé)")
        else:
            minutos_viagem += peso
    if viagem_inicio is not None and g.vertices[vs[-1]][0] == "P":
        passos.append(f"Siga até {rede.estacoes[g.vertices[vs[-1]][1]]['nome']} ({minutos_viagem:.0f} min) e desembarque")
    return passos
