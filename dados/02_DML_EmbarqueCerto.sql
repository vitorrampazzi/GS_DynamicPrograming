-- =============================================================================
-- FIAP · Engenharia de Software · 2º ano · Global Solution 2026.2 (CitizenTech)
-- Disciplina : Database Design
-- Solução    : Embarque Certo
-- Integrantes: Daniel Brito          RM 566236
--              Gustavo Borsato       RM 564621
--              Vitor Rampazzi Franco RM 562270
--
-- Script 02 : DML (carga de dados de exemplo)
-- Pré-requisito: executar antes o 01_DDL_EmbarqueCerto.sql
--
-- Origem dos dados
--   * Linhas, estações, operadoras e cores: rede real de metrô e trem da Região
--     Metropolitana de São Paulo (informação pública). Tempos entre estações,
--     coordenadas e acessibilidade são aproximados para fins acadêmicos.
--   * Passageiros, relatos, confirmações, lotação, trajetos e alertas: dados
--     SIMULADOS. Nenhum dado pessoal real foi usado (e-mails no domínio
--     reservado example.com).
--   * Todas as tabelas têm 5 linhas ou mais; não há exceções a justificar.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 0. Limpeza (ordem inversa das chaves estrangeiras) para permitir reexecução
-- -----------------------------------------------------------------------------
DELETE FROM t_ec_alerta;
DELETE FROM t_ec_trajeto;
DELETE FROM t_ec_registro_lotacao;
DELETE FROM t_ec_confirmacao;
DELETE FROM t_ec_ocorrencia;
DELETE FROM t_ec_tipo_ocorrencia;
DELETE FROM t_ec_usuario;
DELETE FROM t_ec_linha_estacao;
DELETE FROM t_ec_estacao;
DELETE FROM t_ec_linha;
DELETE FROM t_ec_operadora;


-- -----------------------------------------------------------------------------
-- 1. T_EC_OPERADORA (5 linhas)
--    A Next Mobilidade (BRT-ABC) ainda não tem linhas no piloto: o BRT entra
--    na fase 2, por isso a operadora já existe no cadastro.
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_operadora (id_operadora, nm_operadora, sg_operadora, tp_gestao, ds_site)
VALUES (1, 'Companhia do Metropolitano de São Paulo', 'METRO', 'PUBLICA', 'www.metro.sp.gov.br');
INSERT INTO t_ec_operadora (id_operadora, nm_operadora, sg_operadora, tp_gestao, ds_site)
VALUES (2, 'Companhia Paulista de Trens Metropolitanos', 'CPTM', 'PUBLICA', 'www.cptm.sp.gov.br');
INSERT INTO t_ec_operadora (id_operadora, nm_operadora, sg_operadora, tp_gestao, ds_site)
VALUES (3, 'ViaQuatro', 'VIAQUATRO', 'CONCESSAO', 'www.viaquatro.com.br');
INSERT INTO t_ec_operadora (id_operadora, nm_operadora, sg_operadora, tp_gestao, ds_site)
VALUES (4, 'ViaMobilidade', 'VIAMOBILIDADE', 'CONCESSAO', 'www.viamobilidade.com.br');
INSERT INTO t_ec_operadora (id_operadora, nm_operadora, sg_operadora, tp_gestao, ds_site)
VALUES (5, 'Next Mobilidade (BRT-ABC)', 'NEXT', 'CONCESSAO', NULL);


-- -----------------------------------------------------------------------------
-- 2. T_EC_LINHA (6 linhas)
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (1, 1,  1, 'Azul',      'METRO', '#0455A1');
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (2, 1,  2, 'Verde',     'METRO', '#007E5E');
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (3, 1,  3, 'Vermelha',  'METRO', '#EE372F');
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (4, 3,  4, 'Amarela',   'METRO', '#FED304');
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (5, 4,  9, 'Esmeralda', 'TREM',  '#01A9A7');
INSERT INTO t_ec_linha (id_linha, id_operadora, nr_linha, nm_linha, tp_modal, ds_cor_hex)
VALUES (6, 2, 10, 'Turquesa',  'TREM',  '#008B8B');


-- -----------------------------------------------------------------------------
-- 3. T_EC_ESTACAO (15 linhas)
--    nr_min_baldeacao = tempo médio para trocar de linha dentro da estação.
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 1, 'Luz',                  'S', 6, -23.535200, -46.635300);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 2, 'Sé',                   'S', 4, -23.550300, -46.633100);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 3, 'Paraíso',              'S', 2, -23.575900, -46.640900);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 4, 'Consolação',           'S', 0, -23.557900, -46.660500);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 5, 'Trianon-MASP',         'S', 0, -23.561400, -46.656200);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 6, 'Tamanduateí',          'S', 5, -23.592900, -46.589500);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 7, 'República',            'S', 6, -23.544000, -46.642500);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 8, 'Brás',                 'S', 5, -23.545300, -46.616200);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES ( 9, 'Tatuapé',              'S', 4, -23.540400, -46.576300);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (10, 'Corinthians-Itaquera', 'S', 4, -23.542400, -46.471200);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (11, 'Paulista',             'S', 0, -23.555100, -46.662000);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (12, 'Pinheiros',            'S', 5, -23.567400, -46.701900);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (13, 'Vila Olímpia',         'S', 0, -23.593400, -46.692300);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (14, 'Berrini',              'S', 0, -23.608300, -46.697000);
INSERT INTO t_ec_estacao (id_estacao, nm_estacao, st_acessivel, nr_min_baldeacao, nr_latitude, nr_longitude)
VALUES (15, 'Santo André',          'N', 0, -23.656800, -46.529600);


-- -----------------------------------------------------------------------------
-- 4. T_EC_LINHA_ESTACAO (22 linhas) — estações de cada linha, em ordem.
--    nr_min_proxima = minutos até a próxima estação do recorte (NULL na última).
-- -----------------------------------------------------------------------------
-- Linha 1-Azul: Luz -> Sé -> Paraíso
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (1,  1, 1, 4);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (1,  2, 2, 8);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (1,  3, 3, NULL);
-- Linha 2-Verde: Consolação -> Trianon-MASP -> Paraíso -> Tamanduateí
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (2,  4, 1, 2);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (2,  5, 2, 4);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (2,  3, 3, 14);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (2,  6, 4, NULL);
-- Linha 3-Vermelha: República -> Sé -> Brás -> Tatuapé -> Corinthians-Itaquera
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (3,  7, 1, 4);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (3,  2, 2, 4);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (3,  8, 3, 6);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (3,  9, 4, 14);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (3, 10, 5, NULL);
-- Linha 4-Amarela: Luz -> República -> Paulista -> Pinheiros
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (4,  1, 1, 2);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (4,  7, 2, 4);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (4, 11, 3, 7);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (4, 12, 4, NULL);
-- Linha 9-Esmeralda: Pinheiros -> Vila Olímpia -> Berrini
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (5, 12, 1, 7);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (5, 13, 2, 3);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (5, 14, 3, NULL);
-- Linha 10-Turquesa: Brás -> Tamanduateí -> Santo André
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (6,  8, 1, 8);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (6,  6, 2, 12);
INSERT INTO t_ec_linha_estacao (id_linha, id_estacao, nr_ordem, nr_min_proxima) VALUES (6, 15, 3, NULL);


-- -----------------------------------------------------------------------------
-- 5. T_EC_USUARIO (8 linhas) — passageiros fictícios
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (1, 'Joana Ribeiro',         'joana.ribeiro@example.com',    'N', 85, TO_DATE('2026-08-03', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (2, 'Marcos Vinícius Alves', 'marcos.alves@example.com',     'N', 70, TO_DATE('2026-08-10', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (3, 'Patrícia Gomes',        'patricia.gomes@example.com',   'S', 75, TO_DATE('2026-08-15', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (4, 'Rafael Toledo',         'rafael.toledo@example.com',    'N', 60, TO_DATE('2026-09-01', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (5, 'Sueli Matos',           'sueli.matos@example.com',      'S', 65, TO_DATE('2026-09-12', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (6, 'Thiago Nunes',          'thiago.nunes@example.com',     'N', 55, TO_DATE('2026-09-20', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (7, 'Larissa Campos',        'larissa.campos@example.com',   'N', 50, TO_DATE('2026-10-02', 'YYYY-MM-DD'));
INSERT INTO t_ec_usuario (id_usuario, nm_usuario, ds_email, st_mobilidade_reduzida, nr_reputacao, dt_cadastro)
VALUES (8, 'Wellington Prado',      'wellington.prado@example.com', 'N', 20, TO_DATE('2026-10-25', 'YYYY-MM-DD'));


-- -----------------------------------------------------------------------------
-- 6. T_EC_TIPO_OCORRENCIA (6 linhas)
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (1, 'Atraso ou velocidade reduzida', 'Trens com intervalos maiores que o normal ou circulando devagar', 'N');
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (2, 'Trem parado', 'Trem parado na via ou na plataforma por tempo acima do normal', 'N');
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (3, 'Superlotação', 'Plataforma ou trem acima da capacidade; passageiros não conseguem embarcar', 'N');
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (4, 'Elevador fora de serviço', 'Elevador de acesso ou de plataforma inoperante', 'S');
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (5, 'Escada rolante parada', 'Escada rolante desligada ou em manutenção', 'S');
INSERT INTO t_ec_tipo_ocorrencia (id_tipo_ocorrencia, nm_tipo, ds_tipo, st_afeta_acessibilidade)
VALUES (6, 'Trem recolhido por falha', 'Trem retirado de circulação por falha de porta, freio ou ar-condicionado', 'N');


-- -----------------------------------------------------------------------------
-- 7. T_EC_OCORRENCIA (12 linhas)
--    Situações: ABERTA (aguarda confirmação), CONFIRMADA (2 confirmações ou
--    aviso oficial), ENCERRADA (normalizada) e DESCARTADA (não procedeu).
--    Avisos oficiais (tp_fonte = OPERADORA) não têm usuário autor.
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (1, 1, 3, 8, NULL, 'OPERADORA', 'Velocidade reduzida entre Brás e Tatuapé por falha de sinalização', 12, 'ENCERRADA',
        TO_DATE('2026-10-26 07:12', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-26 08:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (2, 3, 3, 9, 1, 'USUARIO', 'Plataforma sentido Palmeiras-Barra Funda lotada; deixei passar dois trens', 10, 'ENCERRADA',
        TO_DATE('2026-10-26 07:20', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-26 08:30', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (3, 2, 6, 6, 6, 'USUARIO', 'Trem parado na plataforma há 10 minutos com as portas abertas', 15, 'ENCERRADA',
        TO_DATE('2026-10-27 18:05', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-27 18:40', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (4, 4, 4, 7, 3, 'USUARIO', 'Elevador de acesso à plataforma da Linha 4 fora de serviço', 0, 'ENCERRADA',
        TO_DATE('2026-10-28 08:40', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-29 10:00', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (5, 1, 6, NULL, NULL, 'OPERADORA', 'Intervalos maiores entre trens em toda a linha por manutenção na via', 8, 'ENCERRADA',
        TO_DATE('2026-10-29 06:50', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-29 09:00', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (6, 5, 1, 2, 5, 'USUARIO', 'Escada rolante da transferência para a Linha 3 parada', 0, 'ENCERRADA',
        TO_DATE('2026-10-30 17:55', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-30 20:00', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (7, 3, 3, 2, 4, 'USUARIO', 'Plataforma da Linha 3 muito cheia na transferência', 5, 'ENCERRADA',
        TO_DATE('2026-11-03 07:05', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-03 08:10', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (8, 1, 3, NULL, NULL, 'OPERADORA', 'Velocidade reduzida em toda a linha devido à chuva forte', 10, 'CONFIRMADA',
        TO_DATE('2026-11-04 07:10', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (9, 3, 3, 9, 1, 'USUARIO', 'Plataforma sentido Palmeiras-Barra Funda superlotada; embarque só no terceiro trem', 12, 'CONFIRMADA',
        TO_DATE('2026-11-04 07:25', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (10, 2, 6, 8, 6, 'USUARIO', 'Trem parado antes da plataforma do Brás', 20, 'ABERTA',
        TO_DATE('2026-11-04 07:30', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (11, 4, 4, 11, 3, 'USUARIO', 'Elevador da saída Rua da Consolação fora de serviço', 0, 'CONFIRMADA',
        TO_DATE('2026-11-04 08:15', 'YYYY-MM-DD HH24:MI'), NULL);
INSERT INTO t_ec_ocorrencia (id_ocorrencia, id_tipo_ocorrencia, id_linha, id_estacao, id_usuario, tp_fonte, ds_ocorrencia, nr_atraso_min, st_ocorrencia, dt_inicio, dt_fim)
VALUES (12, 6, 2, 4, 8, 'USUARIO', 'Trem recolhido por falha de porta', 5, 'DESCARTADA',
        TO_DATE('2026-11-04 10:20', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-04 10:40', 'YYYY-MM-DD HH24:MI'));


-- -----------------------------------------------------------------------------
-- 8. T_EC_CONFIRMACAO (17 linhas) — st_confirma: S = confirma, N = desmente
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 2, 4, 'S', TO_DATE('2026-10-26 07:28', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 2, 2, 'S', TO_DATE('2026-10-26 07:31', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 3, 8, 'S', TO_DATE('2026-10-27 18:12', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 4, 7, 'S', TO_DATE('2026-10-28 08:52', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 4, 5, 'S', TO_DATE('2026-10-28 09:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 5, 6, 'S', TO_DATE('2026-10-29 07:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 6, 4, 'S', TO_DATE('2026-10-30 18:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 6, 2, 'S', TO_DATE('2026-10-30 18:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 7, 1, 'S', TO_DATE('2026-11-03 07:31', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 7, 2, 'S', TO_DATE('2026-11-03 07:46', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 8, 1, 'S', TO_DATE('2026-11-04 07:24', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 9, 2, 'S', TO_DATE('2026-11-04 07:27', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 9, 4, 'S', TO_DATE('2026-11-04 07:31', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES ( 9, 7, 'S', TO_DATE('2026-11-04 07:42', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES (11, 1, 'S', TO_DATE('2026-11-04 08:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES (11, 7, 'S', TO_DATE('2026-11-04 08:22', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_confirmacao (id_ocorrencia, id_usuario, st_confirma, dt_confirmacao) VALUES (12, 5, 'N', TO_DATE('2026-11-04 10:25', 'YYYY-MM-DD HH24:MI'));


-- -----------------------------------------------------------------------------
-- 9. T_EC_REGISTRO_LOTACAO (20 linhas)
--    nr_nivel: 1 vazia · 2 tranquila · 3 moderada · 4 cheia · 5 superlotada
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 1, 4, 3, 10, 5, 'Palmeiras-Barra Funda', TO_DATE('2026-11-03 06:40', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 2, 6, 6,  6, 4, 'Brás',                  TO_DATE('2026-11-03 07:15', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 3, 1, 3,  9, 5, 'Palmeiras-Barra Funda', TO_DATE('2026-11-03 07:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 4, 2, 3,  2, 4, 'Palmeiras-Barra Funda', TO_DATE('2026-11-03 07:45', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 5, 7, 4, 11, 3, 'Vila Sônia',            TO_DATE('2026-11-03 08:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 6, 3, 4,  7, 2, 'Luz',                   TO_DATE('2026-11-03 11:40', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 7, 8, 3,  9, 2, 'Corinthians-Itaquera',  TO_DATE('2026-11-03 14:10', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 8, 4, 3,  2, 5, 'Corinthians-Itaquera',  TO_DATE('2026-11-03 18:10', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES ( 9, 5, 4, 11, 4, 'Luz',                   TO_DATE('2026-11-03 18:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (10, 2, 5, 14, 3, 'Osasco',                TO_DATE('2026-11-03 18:40', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (11, 8, 3, 10, 5, 'Palmeiras-Barra Funda', TO_DATE('2026-11-04 06:50', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (12, 6, 6, 15, 4, 'Brás',                  TO_DATE('2026-11-04 07:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (13, 1, 3,  9, 5, 'Palmeiras-Barra Funda', TO_DATE('2026-11-04 07:22', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (14, 4, 3,  9, 4, 'Palmeiras-Barra Funda', TO_DATE('2026-11-04 07:30', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (15, 2, 3,  8, 4, 'Palmeiras-Barra Funda', TO_DATE('2026-11-04 07:40', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (16, 2, 3,  2, 4, 'Palmeiras-Barra Funda', TO_DATE('2026-11-04 07:50', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (17, 3, 4,  7, 3, 'Vila Sônia',            TO_DATE('2026-11-04 08:05', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (18, 7, 4, 12, 4, 'Vila Sônia',            TO_DATE('2026-11-04 08:30', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (19, 5, 2,  3, 2, 'Vila Madalena',         TO_DATE('2026-11-04 10:15', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_registro_lotacao (id_registro, id_usuario, id_linha, id_estacao, nr_nivel, ds_sentido, dt_registro)
VALUES (20, 5, 2,  5, 2, 'Vila Prudente',         TO_DATE('2026-11-04 11:30', 'YYYY-MM-DD HH24:MI'));


-- -----------------------------------------------------------------------------
-- 10. T_EC_TRAJETO (8 linhas) — trajetos frequentes dos passageiros
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (1, 1, 10, 11, 'Casa - Trabalho',    '06:30', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (2, 1, 11, 10, 'Trabalho - Casa',    '18:00', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (3, 2,  9, 14, 'Ida para o estágio', '07:00', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (4, 3,  8, 11, 'Faculdade',          '07:30', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (5, 4, 10,  7, 'Trabalho',           '06:35', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (6, 5,  2,  5, 'Consulta médica',    '09:30', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (7, 6, 15,  2, 'Casa - Faculdade',   '06:45', 'S');
INSERT INTO t_ec_trajeto (id_trajeto, id_usuario, id_estacao_origem, id_estacao_destino, nm_trajeto, hr_partida, st_alerta_ativo)
VALUES (8, 7,  9, 12, 'Trabalho',           '07:35', 'N');


-- -----------------------------------------------------------------------------
-- 11. T_EC_ALERTA (13 linhas)
--     Só ocorrências CONFIRMADAS geram alerta (a nº 10 ainda está ABERTA).
-- -----------------------------------------------------------------------------
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (1,  1, 'PUSH',  'S', TO_DATE('2026-10-26 07:13', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (3,  1, 'PUSH',  'S', TO_DATE('2026-10-26 07:13', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (5,  1, 'SMS',   'S', TO_DATE('2026-10-26 07:13', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (3,  2, 'PUSH',  'S', TO_DATE('2026-10-26 07:32', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (1,  4, 'PUSH',  'S', TO_DATE('2026-10-29 06:00', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (4,  4, 'PUSH',  'S', TO_DATE('2026-10-29 07:00', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (1,  8, 'PUSH',  'S', TO_DATE('2026-11-04 07:11', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (3,  8, 'PUSH',  'S', TO_DATE('2026-11-04 07:11', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (5,  8, 'SMS',   'N', TO_DATE('2026-11-04 07:11', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (7,  8, 'PUSH',  'S', TO_DATE('2026-11-04 07:11', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (3,  9, 'PUSH',  'S', TO_DATE('2026-11-04 07:32', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (5,  9, 'SMS',   'N', TO_DATE('2026-11-04 07:32', 'YYYY-MM-DD HH24:MI'));
INSERT INTO t_ec_alerta (id_trajeto, id_ocorrencia, tp_canal, st_lido, dt_envio) VALUES (2, 11, 'EMAIL', 'N', TO_DATE('2026-11-04 17:30', 'YYYY-MM-DD HH24:MI'));


COMMIT;


-- -----------------------------------------------------------------------------
-- Conferência opcional: quantidade de linhas em cada tabela (todas >= 5).
-- Descomente e execute para conferir.
-- -----------------------------------------------------------------------------
-- SELECT 'T_EC_OPERADORA'        AS tabela, COUNT(*) AS linhas FROM t_ec_operadora        UNION ALL
-- SELECT 'T_EC_LINHA',                      COUNT(*)           FROM t_ec_linha            UNION ALL
-- SELECT 'T_EC_ESTACAO',                    COUNT(*)           FROM t_ec_estacao          UNION ALL
-- SELECT 'T_EC_LINHA_ESTACAO',              COUNT(*)           FROM t_ec_linha_estacao    UNION ALL
-- SELECT 'T_EC_USUARIO',                    COUNT(*)           FROM t_ec_usuario          UNION ALL
-- SELECT 'T_EC_TIPO_OCORRENCIA',            COUNT(*)           FROM t_ec_tipo_ocorrencia  UNION ALL
-- SELECT 'T_EC_OCORRENCIA',                 COUNT(*)           FROM t_ec_ocorrencia       UNION ALL
-- SELECT 'T_EC_CONFIRMACAO',                COUNT(*)           FROM t_ec_confirmacao      UNION ALL
-- SELECT 'T_EC_REGISTRO_LOTACAO',           COUNT(*)           FROM t_ec_registro_lotacao UNION ALL
-- SELECT 'T_EC_TRAJETO',                    COUNT(*)           FROM t_ec_trajeto          UNION ALL
-- SELECT 'T_EC_ALERTA',                     COUNT(*)           FROM t_ec_alerta;
