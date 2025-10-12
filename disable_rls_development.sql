-- DESABILITAR TODAS AS RLS PARA DESENVOLVIMENTO
-- Execute este script no Supabase para remover todas as restrições durante o desenvolvimento

-- Tabelas principais do sistema
ALTER TABLE organizacoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;

-- Tabelas do sistema de clientes (se existirem)
ALTER TABLE filiais DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE relatorios_vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE boletos DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages DISABLE ROW LEVEL SECURITY;

-- Tabelas de atividades e logs
ALTER TABLE atividades_funcionarios DISABLE ROW LEVEL SECURITY;

-- Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Permitir leitura organizacoes" ON organizacoes;
DROP POLICY IF EXISTS "Permitir escrita organizacoes" ON organizacoes;
DROP POLICY IF EXISTS "Permitir leitura funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Permitir escrita funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Permitir leitura atividades" ON atividades_funcionarios;
DROP POLICY IF EXISTS "Permitir escrita atividades" ON atividades_funcionarios;

-- Confirmar que RLS está desabilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Se o resultado estiver vazio, todas as RLS foram desabilitadas com sucesso!