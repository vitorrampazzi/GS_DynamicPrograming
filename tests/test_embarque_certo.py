"""Testes automatizados. Rodar na pasta do projeto: python -m unittest -v"""
import unittest

from embarque_certo.baldeacoes import ResolvedorMemo, recursao_sem_memo, rota_com_limite
from embarque_certo.dados import carregar_rede, normalizar
from embarque_certo.grafo import destinos, montar_grafo
from embarque_certo.reforco import candidatos, forca_bruta, mochila
from embarque_certo.rotas import floyd_warshall, melhor_rota
from main import AGORA

REDE = carregar_rede()


def rota(o, d, agora=False, mobilidade=False, abertas=False):
    g = montar_grafo(REDE, AGORA if agora else None, mobilidade, abertas)
    return melhor_rota(g, floyd_warshall(g), REDE.estacao_por_nome(o), REDE.estacao_por_nome(d))


class TestDados(unittest.TestCase):
    def test_le_o_mesmo_dml_do_banco(self):
        self.assertEqual(len(REDE.linhas), 6)
        self.assertEqual(len(REDE.estacoes), 15)
        self.assertEqual(sum(len(p) for p in REDE.sequencias.values()), 22)
        self.assertEqual(len(REDE.ocorrencias), 12)
        self.assertEqual(len(REDE.lotacao), 20)

    def test_nome_sem_acento(self):
        self.assertEqual(REDE.estacoes[REDE.estacao_por_nome("se")]["nome"], "Sé")
        self.assertEqual(normalizar("  Trianon-MASP "), "trianon masp")
        with self.assertRaises(KeyError):
            REDE.estacao_por_nome("Estação que não existe")

    def test_ocorrencias_ativas_no_momento(self):
        ativas = {o["id_ocorrencia"] for o in REDE.ocorrencias_ativas(AGORA)}
        self.assertEqual(ativas, {8, 9, 11})
        self.assertIn(10, {o["id_ocorrencia"] for o in REDE.ocorrencias_ativas(AGORA, incluir_abertas=True)})


class TestRotas(unittest.TestCase):
    def test_tempos_conhecidos(self):
        self.assertEqual(rota("Corinthians-Itaquera", "Paulista").minutos, 44)
        self.assertEqual(rota("Corinthians-Itaquera", "Paulista", agora=True).minutos, 54)
        self.assertEqual(rota("Santo André", "Sé", agora=True).minutos, 47)
        self.assertEqual(rota("Santo André", "Sé", agora=True, abertas=True).minutos, 67)

    def test_acessibilidade(self):
        self.assertIsNotNone(rota("Brás", "Paulista", mobilidade=True))
        self.assertIsNone(rota("Brás", "Paulista", agora=True, mobilidade=True))  # elevador parado
        self.assertIsNone(rota("Santo André", "Sé", mobilidade=True))  # estação sem rota acessível
        self.assertIsNotNone(rota("Santo André", "Sé"))

    def test_rota_e_simetrica_em_operacao_normal(self):
        g = montar_grafo(REDE)
        t = floyd_warshall(g)
        for o in REDE.estacoes:
            for d in REDE.estacoes:
                if o != d:
                    self.assertEqual(melhor_rota(g, t, o, d).minutos, melhor_rota(g, t, d, o).minutos)


class TestMemoizacao(unittest.TestCase):
    def test_memo_concorda_com_floyd_sem_limite(self):
        for momento in (None, AGORA):
            g = montar_grafo(REDE, momento)
            t = floyd_warshall(g)
            for o in REDE.estacoes:
                for d in REDE.estacoes:
                    if o != d:
                        r, _ = rota_com_limite(g, o, d, max_embarques=10)
                        self.assertAlmostEqual(r.minutos, melhor_rota(g, t, o, d).minutos)

    def test_limite_de_embarques_troca_a_rota(self):
        g = montar_grafo(REDE)
        o, d = REDE.estacao_por_nome("Brás"), REDE.estacao_por_nome("Trianon-MASP")
        livre, _ = rota_com_limite(g, o, d, 3)
        limitada, _ = rota_com_limite(g, o, d, 2)
        self.assertEqual((livre.minutos, livre.embarques), (31, 3))
        self.assertEqual((limitada.minutos, limitada.embarques), (39, 2))
        self.assertIsNone(rota_com_limite(g, o, d, 1)[0])

    def test_sem_memo_da_o_mesmo_resultado_com_muito_mais_chamadas(self):
        g = montar_grafo(REDE)
        o, d = REDE.estacao_por_nome("Corinthians-Itaquera"), REDE.estacao_por_nome("Paulista")
        tempo, chamadas = recursao_sem_memo(g, o, d, 9, 3)
        r = ResolvedorMemo(g, o)
        self.assertEqual(tempo, min(r.melhor(j, 9, 3)[0] for j in destinos(g, d)))
        self.assertGreater(chamadas, 50 * r.chamadas)


class TestReforco(unittest.TestCase):
    def test_tabulacao_igual_a_forca_bruta(self):
        itens = candidatos(REDE)
        self.assertEqual(len(itens), 6)
        for trens in range(0, 10):
            total, escolhidos, _ = mochila(itens, trens)
            self.assertEqual(total, forca_bruta(itens, trens))
            self.assertLessEqual(sum(i.custo for i in escolhidos), trens)
            self.assertEqual(sum(i.beneficio for i in escolhidos), total)

    def test_prioriza_linha_3_no_pico_da_manha(self):
        _, escolhidos, _ = mochila(candidatos(REDE), 1)
        self.assertEqual(REDE.linhas[escolhidos[0].linha_id]["numero"], 3)
        self.assertEqual(escolhidos[0].periodo, "pico da manhã")


if __name__ == "__main__":
    unittest.main()
