"""Embarque Certo · Dynamic Programming — Global Solution 2026.2 (FIAP).

Uso:
  python main.py                 menu interativo
  python main.py demo            roda os cenários de demonstração
  python main.py rota "Corinthians-Itaquera" "Paulista" [--agora] [--mobilidade-reduzida] [--max-embarques 2]
  python main.py reforco --trens 4
  python main.py eficiencia
  python main.py estacoes
"""
from __future__ import annotations

import argparse
import random
import sys
import time
from datetime import datetime

from embarque_certo.baldeacoes import recursao_sem_memo, rota_com_limite
from embarque_certo.dados import carregar_rede
from embarque_certo.grafo import montar_grafo
from embarque_certo.reforco import PASSAGEIROS_POR_PONTO, Reforco, candidatos, forca_bruta, mochila
from embarque_certo.rotas import floyd_warshall, melhor_rota

# Momento de referência: manhã de 04/11/2026, com as ocorrências do script DML.
AGORA = datetime(2026, 11, 4, 8, 30)


def linha(titulo: str = "") -> None:
    print("\n" + ("─" * 4 + f" {titulo} " if titulo else "") + "─" * max(0, 72 - len(titulo) - 6))


def mostrar_rota(rede, origem: str, destino: str, agora: bool, mobilidade: bool,
                 max_embarques: int | None = None, abertas: bool = False) -> None:
    o, d = rede.estacao_por_nome(origem), rede.estacao_por_nome(destino)
    g = montar_grafo(rede, AGORA if agora else None, mobilidade, abertas)
    if not agora:
        cenario = "operação normal"
    elif abertas:
        cenario = "agora (04/11/2026 08:30, incluindo relatos ainda não confirmados)"
    else:
        cenario = "agora (04/11/2026 08:30, com ocorrências confirmadas)"
    perfil = " · mobilidade reduzida" if mobilidade else ""
    limite = f" · no máximo {max_embarques} embarque(s)" if max_embarques else ""
    print(f"{rede.estacoes[o]['nome']} → {rede.estacoes[d]['nome']} | {cenario}{perfil}{limite}")
    if agora and g.avisos:
        print("  Ocorrências consideradas:")
        for aviso in dict.fromkeys(g.avisos):
            print("   •", aviso)
    if max_embarques:
        rota, resolvedor = rota_com_limite(g, o, d, max_embarques)
        print(f"  [memoização] {len(resolvedor.memo)} estados calculados, {resolvedor.chamadas} chamadas")
    else:
        rota = melhor_rota(g, floyd_warshall(g), o, d)
    if rota is None:
        motivo = ""
        if d in g.estacoes_bloqueadas or o in g.estacoes_bloqueadas:
            motivo = " (estação sem acesso acessível neste momento)"
        elif max_embarques:
            motivo = " (não há caminho com esse número de embarques)"
        print(f"  ✗ Nenhuma rota possível{motivo}.")
        return
    print(f"  ✓ Tempo estimado: {rota.minutos:.0f} min · {rota.embarques} embarque(s)")
    for i, passo in enumerate(rota.trechos(g, rede), 1):
        print(f"   {i}. {passo}")


def mostrar_reforco(rede, trens: int) -> None:
    itens = candidatos(rede)
    total, escolhidos, _ = mochila(itens, trens)
    print(f"Trens reserva disponíveis: {trens} · {len(itens)} pontos críticos no pico (dos registros de lotação)")
    for it in itens:
        marca = "✓" if it in escolhidos else " "
        print(f"  {marca} {rede.nome_linha(it.linha_id):22} sentido {it.sentido:22} {it.periodo:14}"
              f" custo {it.custo} · alívio {it.beneficio:2} ({', '.join(it.estacoes)})")
    usados = sum(i.custo for i in escolhidos)
    print(f"  Plano ótimo: {usados} trem(ns), alívio total {total} pontos "
          f"(~{total * PASSAGEIROS_POR_PONTO} passageiros/hora embarcando com mais conforto)")
    assert total == forca_bruta(itens, trens), "tabulação e força bruta divergiram"


def demo(rede) -> None:
    linha("1. Joana: Itaquera → Av. Paulista (Floyd-Warshall)")
    mostrar_rota(rede, "Corinthians-Itaquera", "Paulista", agora=False, mobilidade=False)
    print()
    mostrar_rota(rede, "Corinthians-Itaquera", "Paulista", agora=True, mobilidade=False)
    linha("2. Thiago: Santo André → Sé, com trem parado ainda não confirmado")
    mostrar_rota(rede, "Santo André", "Sé", agora=True, mobilidade=False)
    print()
    mostrar_rota(rede, "Santo André", "Sé", agora=True, mobilidade=False, abertas=True)
    linha("3. Patrícia (cadeirante): Brás → Paulista com elevador fora de serviço")
    mostrar_rota(rede, "Brás", "Paulista", agora=False, mobilidade=True)
    print()
    mostrar_rota(rede, "Brás", "Paulista", agora=True, mobilidade=True)
    linha("4. Sueli (idosa): Brás → Trianon-MASP com uma baldeação só (memoização)")
    mostrar_rota(rede, "Brás", "Trianon-MASP", agora=False, mobilidade=False)
    print()
    mostrar_rota(rede, "Brás", "Trianon-MASP", agora=False, mobilidade=False, max_embarques=2)
    print()
    mostrar_rota(rede, "Brás", "Trianon-MASP", agora=False, mobilidade=False, max_embarques=1)
    linha("5. Operadora: onde colocar os trens reserva (mochila 0/1)")
    mostrar_reforco(rede, 2)
    print()
    mostrar_reforco(rede, 5)


def eficiencia(rede) -> None:
    g = montar_grafo(rede, AGORA)
    n = len(g.vertices)
    linha("Floyd-Warshall: uma tabela para todas as rotas")
    t0 = time.perf_counter()
    tabela = floyd_warshall(g)
    t_fw = time.perf_counter() - t0
    pares = len(rede.estacoes) * (len(rede.estacoes) - 1)
    t0 = time.perf_counter()
    for o in rede.estacoes:
        for d in rede.estacoes:
            if o != d:
                melhor_rota(g, tabela, o, d)
    t_consultas = time.perf_counter() - t0
    print(f"  Grafo: {n} vértices, {len(g.arestas)} arestas · V³ = {n ** 3} · células avaliadas: {tabela.operacoes}")
    print(f"  Montar a tabela: {t_fw * 1000:.1f} ms · responder as {pares} rotas possíveis: {t_consultas * 1000:.2f} ms")

    linha("Memoização: mesma recorrência com e sem memo")
    o, d = rede.estacao_por_nome("Corinthians-Itaquera"), rede.estacao_por_nome("Paulista")
    print(f"  {'k (arestas)':>12} {'sem memo':>14} {'com memo':>12}")
    for k in (6, 8, 10, 12, 14):
        t0 = time.perf_counter()
        tempo_puro, chamadas_puro = recursao_sem_memo(g, o, d, k, 3)
        t_puro = time.perf_counter() - t0
        from embarque_certo.baldeacoes import ResolvedorMemo
        from embarque_certo.grafo import destinos
        r = ResolvedorMemo(g, o)
        t0 = time.perf_counter()
        tempo_memo = min(r.melhor(j, k, 3)[0] for j in destinos(g, d))
        t_memo = time.perf_counter() - t0
        assert tempo_puro == tempo_memo
        print(f"  {k:>12} {chamadas_puro:>9} chamadas {r.chamadas:>7} chamadas"
              f"   ({t_puro * 1000:7.1f} ms × {t_memo * 1000:5.2f} ms)")

    linha("Mochila 0/1: tabulação × força bruta")
    itens = candidatos(rede)
    for nome, lista, cap in [("dados do piloto", itens, 4), ("rede ampliada (simulada)", _itens_sinteticos(20), 15)]:
        t0 = time.perf_counter()
        valor_tab, _, _ = mochila(lista, cap)
        t_tab = time.perf_counter() - t0
        t0 = time.perf_counter()
        valor_bf = forca_bruta(lista, cap)
        t_bf = time.perf_counter() - t0
        assert valor_tab == valor_bf
        print(f"  {nome:26} n={len(lista):2} C={cap:2}: tabela {(len(lista) + 1) * (cap + 1):4} células em "
              f"{t_tab * 1000:6.2f} ms · força bruta 2^{len(lista)} = {2 ** len(lista):>9} combinações em {t_bf * 1000:9.1f} ms")


def _itens_sinteticos(n: int) -> list[Reforco]:
    aleatorio = random.Random(2026)
    return [Reforco(1, f"s{i}", "pico", ("X",), aleatorio.choice([1, 2]), aleatorio.randint(1, 12)) for i in range(n)]


def menu(rede) -> None:
    opcoes = {
        "1": "Melhor rota agora",
        "2": "Melhor rota em operação normal",
        "3": "Rota acessível (mobilidade reduzida), agora",
        "4": "Rota com limite de embarques",
        "5": "Planejar trens reserva",
        "6": "Cenários de demonstração",
        "7": "Comparação de eficiência",
        "8": "Listar estações",
        "0": "Sair",
    }
    while True:
        linha("Embarque Certo")
        for k, v in opcoes.items():
            print(f"  {k} · {v}")
        try:
            escolha = input("Opção: ").strip()
            if escolha == "0":
                return
            if escolha in {"1", "2", "3", "4"}:
                origem = input("Estação de origem: ")
                destino = input("Estação de destino: ")
                limite = int(input("Máximo de embarques: ")) if escolha == "4" else None
                mostrar_rota(rede, origem, destino, agora=escolha != "2", mobilidade=escolha == "3", max_embarques=limite)
            elif escolha == "5":
                mostrar_reforco(rede, int(input("Quantos trens reserva? ")))
            elif escolha == "6":
                demo(rede)
            elif escolha == "7":
                eficiencia(rede)
            elif escolha == "8":
                listar(rede)
        except (KeyError, ValueError) as erro:
            print("  !", erro.args[0] if erro.args else erro)
        except EOFError:
            return


def listar(rede) -> None:
    for linha_id, paradas in rede.sequencias.items():
        nomes = " → ".join(rede.estacoes[e]["nome"] for e, _ in paradas)
        print(f"  {rede.nome_linha(linha_id):22} {nomes}")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Embarque Certo: rotas e planejamento com programação dinâmica")
    sub = parser.add_subparsers(dest="comando")
    sub.add_parser("demo")
    sub.add_parser("eficiencia")
    sub.add_parser("estacoes")
    p_rota = sub.add_parser("rota")
    p_rota.add_argument("origem")
    p_rota.add_argument("destino")
    p_rota.add_argument("--agora", action="store_true", help="considera as ocorrências ativas em 04/11/2026 08:30")
    p_rota.add_argument("--incluir-abertas", action="store_true", help="considera também relatos ainda não confirmados")
    p_rota.add_argument("--mobilidade-reduzida", action="store_true")
    p_rota.add_argument("--max-embarques", type=int)
    p_ref = sub.add_parser("reforco")
    p_ref.add_argument("--trens", type=int, default=4)
    args = parser.parse_args(argv)

    if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
        sys.stdout.reconfigure(encoding="utf-8")  # acentos e setas no terminal do Windows
    rede = carregar_rede()
    if args.comando == "demo":
        demo(rede)
    elif args.comando == "eficiencia":
        eficiencia(rede)
    elif args.comando == "estacoes":
        listar(rede)
    elif args.comando == "rota":
        mostrar_rota(rede, args.origem, args.destino, args.agora, args.mobilidade_reduzida,
                     args.max_embarques, args.incluir_abertas)
    elif args.comando == "reforco":
        mostrar_reforco(rede, args.trens)
    else:
        menu(rede)


if __name__ == "__main__":
    main()
