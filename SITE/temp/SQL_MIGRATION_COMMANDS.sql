-- ===================================================================
-- MIGRAÇÃO SQL PARA SUPABASE - EXECUTAR NO SQL EDITOR
-- ===================================================================

-- 1. CRIAR TABELA ORGANIZACOES
CREATE TABLE IF NOT EXISTS organizacoes (
  id VARCHAR(50) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  tipo VARCHAR(20) CHECK (tipo IN ('matriz', 'filial')) NOT NULL,
  codigo VARCHAR(20),
  cnpj VARCHAR(18),
  endereco TEXT,
  telefone VARCHAR(20),
  email VARCHAR(100),
  responsavel VARCHAR(100),
  matriz_id VARCHAR(50),
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. INSERIR MATRIZ PRINCIPAL
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo) VALUES
('matriz', 'DNOTAS - Matriz', 'matriz', 'MATRIZ', '12.345.678/0001-90', true)
ON CONFLICT (id) DO NOTHING;

-- 3. MIGRAR FILIAIS EXISTENTES PARA ORGANIZACOES
INSERT INTO organizacoes (id, nome, tipo, matriz_id, ativo)
SELECT 
  id,
  nome,
  'filial' as tipo,
  'matriz' as matriz_id,
  ativo
FROM filiais
ON CONFLICT (id) DO NOTHING;

-- 4. INSERIR FILIAIS ADICIONAIS QUE OS FUNCIONÁRIOS REFERENCIAM
INSERT INTO organizacoes (id, nome, tipo, matriz_id, ativo) VALUES
('filial_centro', 'Filial Centro', 'filial', 'matriz', true),
('filial_norte', 'Filial Norte', 'filial', 'matriz', true),
('filial_sul', 'Filial Sul', 'filial', 'matriz', true)
ON CONFLICT (id) DO NOTHING;

-- 5. ADICIONAR COLUNA organizacao_id À TABELA funcionarios
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS organizacao_id VARCHAR(50);

-- 6. MIGRAR filial_id PARA organizacao_id
UPDATE funcionarios 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL AND filial_id IS NOT NULL;

-- 7. VERIFICAR USUÁRIO DNOTAS (já foi criado pelo script)
SELECT 'LOGIN DNOTAS CRIADO:' as status, * FROM funcionarios WHERE email = 'DNOTAS';

-- 8. VERIFICAR ORGANIZAÇÕES CRIADAS
SELECT 'ORGANIZAÇÕES CRIADAS:' as status, * FROM organizacoes ORDER BY tipo, id;

-- 9. VERIFICAR FUNCIONÁRIOS COM ORGANIZACAO_ID
SELECT 
  nome, 
  email, 
  filial_id, 
  organizacao_id, 
  cargo, 
  ativo 
FROM funcionarios 
ORDER BY nome;

-- ===================================================================
-- COMANDOS OPCIONAIS PARA LIMPEZA E AJUSTES
-- ===================================================================

-- Atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger na tabela organizacoes
DROP TRIGGER IF EXISTS update_organizacoes_updated_at ON organizacoes;
CREATE TRIGGER update_organizacoes_updated_at
  BEFORE UPDATE ON organizacoes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Aplicar trigger na tabela funcionarios (se não existir)
DROP TRIGGER IF EXISTS update_funcionarios_updated_at ON funcionarios;
CREATE TRIGGER update_funcionarios_updated_at
  BEFORE UPDATE ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ===================================================================
-- VERIFICAÇÕES FINAIS
-- ===================================================================

-- Verificar se todas as tabelas existem
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('funcionarios', 'filiais', 'organizacoes', 'clientes')
ORDER BY table_name;

-- Verificar colunas da tabela funcionarios
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'funcionarios'
ORDER BY ordinal_position;

-- Verificar colunas da tabela organizacoes
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'organizacoes'
ORDER BY ordinal_position;