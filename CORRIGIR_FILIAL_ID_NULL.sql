-- ============================================
-- CORRIGIR COLUNA FILIAL_ID PARA ACEITAR NULL
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. PERMITIR NULL NA COLUNA filial_id
ALTER TABLE solicitacoes_relatorios 
ALTER COLUMN filial_id DROP NOT NULL;

-- 2. TAMBÉM CORRIGIR NA TABELA relatorios_processados SE NECESSÁRIO
ALTER TABLE relatorios_processados 
ALTER COLUMN filial_id DROP NOT NULL;

-- 3. VERIFICAR A ESTRUTURA ATUAL DA TABELA
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'solicitacoes_relatorios' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. TESTAR INSERÇÃO SEM filial_id
INSERT INTO solicitacoes_relatorios (
  cliente_cnpj, 
  data_inicio, 
  data_fim, 
  tipo_periodo, 
  observacoes
) VALUES (
  '50001362000175',
  '2025-10-17',
  '2025-10-17', 
  'dia_unico',
  'Teste sem filial_id'
);

-- 5. VERIFICAR SE FUNCIONOU
SELECT id, cliente_cnpj, filial_id, data_inicio, data_fim, tipo_periodo, status
FROM solicitacoes_relatorios 
WHERE observacoes = 'Teste sem filial_id';

-- 6. LIMPAR TESTE
DELETE FROM solicitacoes_relatorios WHERE observacoes = 'Teste sem filial_id';

SELECT 'FILIAL_ID CORRIGIDO - AGORA ACEITA NULL!' as status;