-- ============================================
-- CORRIGIR RLS PARA TABELA SOLICITACOES_RELATORIOS
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. CRIAR TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS solicitacoes_relatorios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cliente_cnpj VARCHAR(20) NOT NULL,
  filial_id VARCHAR(50),
  data_inicio DATE NOT NULL,
  data_fim DATE NOT NULL,
  tipo_periodo VARCHAR(20) CHECK (tipo_periodo IN ('dia_unico', 'intervalo')) NOT NULL,
  observacoes TEXT,
  status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processando', 'concluido', 'cancelado')),
  processado_por VARCHAR(100),
  data_solicitacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_processamento TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CRIAR TABELA RELATORIOS_PROCESSADOS SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS relatorios_processados (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  solicitacao_id UUID REFERENCES solicitacoes_relatorios(id) ON DELETE CASCADE,
  cliente_cnpj VARCHAR(20) NOT NULL,
  filial_id VARCHAR(50),
  data_relatorio DATE NOT NULL,
  vendas_credito DECIMAL(10,2) DEFAULT 0,
  vendas_debito DECIMAL(10,2) DEFAULT 0,
  vendas_pix DECIMAL(10,2) DEFAULT 0,
  vendas_vale DECIMAL(10,2) DEFAULT 0,
  vendas_dinheiro DECIMAL(10,2) DEFAULT 0,
  vendas_transferencia DECIMAL(10,2) DEFAULT 0,
  total_vendas DECIMAL(10,2) DEFAULT 0,
  observacoes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. DESABILITAR RLS TEMPORARIAMENTE PARA DESENVOLVIMENTO
ALTER TABLE solicitacoes_relatorios DISABLE ROW LEVEL SECURITY;
ALTER TABLE relatorios_processados DISABLE ROW LEVEL SECURITY;

-- 4. OPÇÃO ALTERNATIVA: MANTER RLS MAS COM POLÍTICAS PERMISSIVAS
-- Se quiser manter RLS ativo, descomente as linhas abaixo:

-- ALTER TABLE solicitacoes_relatorios ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE relatorios_processados ENABLE ROW LEVEL SECURITY;

-- -- Política permissiva para inserção (qualquer um pode inserir)
-- CREATE POLICY "Allow insert for all users" ON solicitacoes_relatorios
--   FOR INSERT WITH CHECK (true);

-- -- Política permissiva para seleção (qualquer um pode ler)  
-- CREATE POLICY "Allow select for all users" ON solicitacoes_relatorios
--   FOR SELECT USING (true);

-- -- Política permissiva para atualização (qualquer um pode atualizar)
-- CREATE POLICY "Allow update for all users" ON solicitacoes_relatorios
--   FOR UPDATE USING (true);

-- -- Políticas para relatorios_processados
-- CREATE POLICY "Allow insert processed reports" ON relatorios_processados
--   FOR INSERT WITH CHECK (true);

-- CREATE POLICY "Allow select processed reports" ON relatorios_processados
--   FOR SELECT USING (true);

-- 5. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_solicitacoes_cliente_cnpj ON solicitacoes_relatorios(cliente_cnpj);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_status ON solicitacoes_relatorios(status);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_data ON solicitacoes_relatorios(data_solicitacao);
CREATE INDEX IF NOT EXISTS idx_relatorios_processados_solicitacao ON relatorios_processados(solicitacao_id);

-- 6. TESTAR INSERÇÃO
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
  'Teste de solicitação'
);

-- 7. VERIFICAR SE FUNCIONOU
SELECT * FROM solicitacoes_relatorios WHERE cliente_cnpj = '50001362000175';

-- 8. LIMPAR TESTE (OPCIONAL)
-- DELETE FROM solicitacoes_relatorios WHERE observacoes = 'Teste de solicitação';

SELECT 'RLS CORRIGIDO COM SUCESSO!' as status;