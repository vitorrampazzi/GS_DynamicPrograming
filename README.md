# Embarque Certo · Dynamic Programming

**FIAP · Engenharia de Software · 2º ano · Global Solution 2026.2 (CitizenTech)**

| Integrante (ordem alfabética) | RM |
|---|---|
| Daniel Brito | 566236 |
| Gustavo Borsato | 564621 |
| Vitor Rampazzi Franco | 562270 |

Equipe: Embarque Certo

## A CitizenTech

Quem depende de trem, metrô e BRT em São Paulo planeja o dia sem saber o que vai encontrar.
Quem usa transporte público gasta, em média, 2h47 por dia se deslocando (Rede Nossa São
Paulo/Ipec, 2024). Quando um trem para, uma linha fica lenta ou um elevador quebra, o
passageiro só descobre na plataforma lotada.

O **Embarque Certo** junta os avisos oficiais das operadoras e os relatos dos passageiros
(confirmados por outros passageiros) e avisa cada pessoa antes de ela sair de casa. Nesta
disciplina implementamos o "cérebro" do aplicativo: **qual o melhor caminho agora**, e a
decisão da operadora sobre **onde colocar os trens reserva**.

Os dados são os mesmos da disciplina de Database Design: o programa lê o script
`dados/02_DML_EmbarqueCerto.sql` (linhas, estações, tempos entre estações, ocorrências e
registros de lotação). Não há dados pessoais reais; passageiros e relatos são simulados.

## Como executar

Precisa apenas de **Python 3.10 ou superior**, sem bibliotecas externas.

```bash
python main.py              # menu interativo
python main.py demo         # cenários de demonstração (recomendado para a correção)
python main.py eficiencia   # medição de eficiência das técnicas
python main.py estacoes     # lista as linhas e estações da rede do piloto
python main.py rota "Corinthians-Itaquera" "Paulista" --agora
python main.py rota "Brás" "Trianon-MASP" --max-embarques 2
python main.py rota "Brás" "Paulista" --agora --mobilidade-reduzida
python main.py reforco --trens 5
python -m unittest -v       # 11 testes automatizados
```

Os nomes das estações aceitam variações sem acento e sem hífen: `se`, `bras` e
`trianon masp` funcionam. A opção `--agora` usa a situação de 04/11/2026 às 08h30
registrada no banco: chuva deixando a Linha 3 lenta, superlotação no Tatuapé e elevador
parado na estação Paulista.

## Estrutura

```
embarque_certo_dp/
├── main.py                    menu, linha de comando, demonstração e medição de eficiência
├── dados/02_DML_EmbarqueCerto.sql   mesmo script entregue em Database Design
├── embarque_certo/
│   ├── dados.py               lê os INSERTs do script e monta a rede
│   ├── grafo.py               modelagem da rede como grafo ponderado
│   ├── rotas.py               Floyd-Warshall (grafos + tabulação)
│   ├── baldeacoes.py          rota com limite de embarques (memoização)
│   └── reforco.py             trens reserva: mochila 0/1 (tabulação)
└── tests/test_embarque_certo.py
```

## Modelagem: a rede como grafo

A rede do piloto tem 6 linhas (1-Azul, 2-Verde, 3-Vermelha, 4-Amarela, 9-Esmeralda e
10-Turquesa) e 15 estações. O grafo tem **37 vértices e 76 arestas**:

- **Vértice "estação"** `E(s)`: o passageiro está no saguão da estação, fora do trem.
- **Vértice "plataforma"** `P(s, L)`: o passageiro está no trem da linha L, parado em s.
- **Aresta de viagem** `P(s, L) → P(s', L)`: minutos até a estação vizinha, nos dois sentidos.
- **Aresta de embarque** `E(s) → P(s, L)`: espera média do trem (3 min no metrô, 5 min no
  trem metropolitano) mais os atrasos ativos da linha.
- **Aresta de desembarque** `P(s, L) → E(s)`: tempo de baldeação da estação.

Separar estação de plataforma permite cobrar a baldeação só quando o passageiro troca de
linha, e aplicar cada ocorrência no lugar certo:

| Ocorrência | Efeito no grafo |
|---|---|
| Atraso, trem parado, trem recolhido | soma o atraso ao embarque em toda a linha |
| Superlotação numa estação | soma o atraso só ao embarque naquela estação e linha |
| Elevador ou escada rolante parados | para quem tem mobilidade reduzida, a estação perde as arestas de embarque e desembarque: o trem passa, mas não dá para descer |
| Estação sem rota acessível | mesmo efeito, permanente |

Por padrão contam só as ocorrências **confirmadas**: aviso oficial ou duas confirmações de
passageiros, a mesma regra do banco. A opção `--incluir-abertas` considera também os relatos
ainda sem confirmação.

## Algoritmos de programação dinâmica

### 1. Grafos + tabulação: Floyd-Warshall (`rotas.py`)

**Problema:** o tempo mínimo de qualquer estação para qualquer outra, no cenário atual.

**Subproblema:** `dist[k][i][j]` é o menor tempo de i até j usando só os vértices
0..k-1 como intermediários.

```
dist[k][i][j] = min( dist[k-1][i][j],  dist[k-1][i][k] + dist[k-1][k][j] )
```

A tabela é preenchida de baixo para cima e reaproveita uma única matriz V × V. A matriz
`proximo` guarda a primeira decisão de cada caminho, para reconstruir a rota passo a passo.

**Por que esta escolha:** o aplicativo precisa responder rotas para milhares de pessoas
ao mesmo tempo. Uma tabela calculada uma vez por cenário (O(V³), cerca de 1 ms aqui)
responde as 210 combinações de origem e destino em menos de 1 ms. Quando chega uma
ocorrência nova, recalcula-se a tabela uma vez, em vez de rodar um algoritmo por usuário.

### 2. Memoização: rota com limite de embarques (`baldeacoes.py`)

**Problema:** idosos, gestantes e quem carrega bagagem preferem uma viagem um pouco mais
longa a fazer várias baldeações. "O caminho mais rápido com no máximo B embarques" não cabe
no Floyd-Warshall, então o estado ganha mais duas dimensões.

```
melhor(v, k, b) = menor tempo da origem até v usando no máximo k arestas e b embarques

melhor(origem, k, b) = 0
melhor(v, 0, b)      = infinito                        (v ≠ origem)
melhor(v, k, b)      = min( melhor(v, k-1, b),
                            min sobre arestas u→v de melhor(u, k-1, b - [u→v é embarque]) + peso )
```

É um Bellman-Ford escrito de cima para baixo (recursivo). Sem memo, a recursão recalcula
os mesmos subproblemas um número exponencial de vezes. Com um dicionário `memo[(v, k, b)]`,
cada estado é resolvido uma vez só: O(V · K · B) estados, cada um percorrendo as arestas
que chegam em v. A decisão guardada em cada estado permite reconstruir o caminho.

Exemplo da demonstração: de Brás a Trianon-MASP, a rota mais rápida leva **31 min com 3
embarques** (Linha 3 → Linha 1 → Linha 2). Com no máximo 2 embarques, o algoritmo encontra
**39 min** pela Linha 10 e pela Linha 2. Com 1 embarque, informa que não existe caminho.

### 3. Tabulação: onde colocar os trens reserva (`reforco.py`)

**Problema:** os registros de lotação mostram onde a rede fica cheia nos horários de pico.
A operadora tem poucos trens reserva e precisa escolher onde usá-los para aliviar o maior
número de passageiros. É a **mochila 0/1**:

- **item:** reforçar uma linha num sentido e período (ex.: Linha 3, sentido
  Palmeiras-Barra Funda, pico da manhã);
- **custo:** trens reserva necessários (1 para metrô; 2 para trem metropolitano, cujas
  composições são maiores);
- **benefício:** pontos de alívio = soma de (nível de lotação − 2) dos registros do grupo.

```
tabela[i][c] = max( tabela[i-1][c],  tabela[i-1][c - custo_i] + beneficio_i )   se custo_i ≤ c
```

A tabela (n+1) × (C+1) é preenchida linha a linha, em O(n · C). A reconstrução volta pela
tabela para listar os reforços escolhidos. Com 2 trens, o plano ótimo reforça a Linha 3 e
a Linha 4 no pico da manhã. Com 5 trens, entra também a Linha 10, trocando um reforço menor.

## Funcionalidades implementadas

1. **Melhor rota agora**, considerando atrasos e superlotação confirmados.
2. **Melhor rota em operação normal**, para comparar com a situação atual.
3. **Rota acessível**, que evita estações sem acessibilidade ou com elevador ou escada
   rolante parados, e avisa quando o destino está sem acesso.
4. **Rota com limite de embarques**, para quem quer menos baldeações.
5. **Plano de trens reserva** para a operadora, com orçamento escolhido pelo usuário.
6. **Instruções passo a passo**: embarque, até onde seguir e onde fazer baldeação, com o
   tempo de cada trecho.
7. **Demonstração e medição de eficiência**, com conferência automática dos resultados.

## Eficiência medida (`python main.py eficiencia`)

| Técnica | Sem programação dinâmica | Com programação dinâmica |
|---|---|---|
| Rota com limite (k = 14 arestas, b = 3) | 26.759.859 chamadas recursivas, ~4,4 s | 2.096 chamadas, < 1 ms |
| Mochila, 20 reforços e 15 trens | 2²⁰ = 1.048.576 combinações, ~0,6 s | tabela de 336 células, < 0,1 ms |
| Floyd-Warshall | — | 1 tabela (~1 ms) responde as 210 rotas em < 1 ms |

Os tempos variam conforme o computador; o número de chamadas e de células não varia.
O programa confere, em cada medição, que as duas versões chegam ao mesmo resultado.

## Testes

`python -m unittest -v` roda 11 testes, que verificam:

- a leitura do DML (6 linhas, 15 estações, 22 paradas, 12 ocorrências, 20 registros);
- tempos conhecidos, calculados à mão: Itaquera → Paulista leva 44 min normal e 54 min agora;
- a acessibilidade: com o elevador parado, não há rota até a Paulista;
- a simetria das rotas em operação normal;
- a memoização igual ao Floyd-Warshall em todos os pares quando não há limite;
- a recursão sem memo com o mesmo resultado e muito mais chamadas;
- a mochila tabulada igual à força bruta para orçamentos de 0 a 9 trens.

## Hipóteses e limites do protótipo

- Tempos entre estações e esperas médias são aproximados; o recorte usa só estações de
  integração e de grande movimento.
- Paulista (Linha 4) e Consolação (Linha 2) são ligadas por túnel na rede real, mas não no
  modelo, que não tem transferências a pé entre estações diferentes.
- O BRT-ABC ainda não tem linhas no piloto; o modelo aceita o modal `BRT` para a fase 2.
- Os "pontos de alívio" da mochila são uma estimativa simples a partir da lotação informada.
