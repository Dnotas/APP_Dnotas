-- ============================================
-- MIGRAÇÃO FINAL CORRIGIDA - DNOTAS
-- Resolve problema da constraint NOT NULL em filial_id
-- ============================================

-- 1. PRIMEIRO: Remover constraint NOT NULL de filial_id (se existir)
ALTER TABLE funcionarios ALTER COLUMN filial_id DROP NOT NULL;

-- 2. CRIAR TABELA ORGANIZACOES (se não existir)
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

-- 3. INSERIR MATRIZ PRINCIPAL
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo) VALUES
('matriz', 'DNOTAS - Matriz', 'matriz', 'MATRIZ', '12.345.678/0001-90', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  tipo = EXCLUDED.tipo,
  codigo = EXCLUDED.codigo,
  cnpj = EXCLUDED.cnpj,
  ativo = EXCLUDED.ativo;

-- 4. MIGRAR DADOS DE FILIAIS PARA ORGANIZACOES (sem conflito)
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, matriz_id, ativo)
SELECT 
  f.id,
  f.nome,
  'filial' as tipo,
  NULL as codigo,
  NULL as cnpj,
  'matriz' as matriz_id,
  COALESCE(f.ativo, true) as ativo
FROM filiais f
WHERE NOT EXISTS (
  SELECT 1 FROM organizacoes o WHERE o.id = f.id
);

-- 5. ADICIONAR COLUNA organizacao_id SE NÃO EXISTIR
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'organizacao_id') THEN
        ALTER TABLE funcionarios ADD COLUMN organizacao_id VARCHAR(50);
    END IF;
END $$;

-- 6. MIGRAR filial_id PARA organizacao_id (somente onde não estiver preenchido)
UPDATE funcionarios 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL 
  AND filial_id IS NOT NULL;

-- 7. DELETAR FUNCIONÁRIO DNOTAS EXISTENTE (para recriar)
DELETE FROM funcionarios WHERE email = 'DNOTAS';

-- 8. CRIAR FUNCIONÁRIO ADMINISTRADOR DA MATRIZ
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Administrador DNOTAS', 'DNOTAS', 'D100*', 'Super Administrador', 'matriz', 'admin', true);

-- 9. CRIAR ALGUNS GESTORES DE FILIAIS DE EXEMPLO
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Gestor Centro', 'gestor.centro@dnotas.com', 'centro123', 'Gerente', 'filial_centro', 'admin', true),
('Gestor Norte', 'gestor.norte@dnotas.com', 'norte123', 'Gerente', 'filial_norte', 'admin', true),
('Gestor Sul', 'gestor.sul@dnotas.com', 'sul123', 'Gerente', 'filial_sul', 'admin', true),
('João Atendente', 'joao@dnotas.com', 'joao123', 'Atendente', 'filial_centro', 'operator', true)
ON CONFLICT (email) DO NOTHING;

-- 10. CRIAR TABELA DE ATIVIDADES (se não existir)
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL,
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}',
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_matriz ON organizacoes(matriz_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_atividades_funcionario ON atividades_funcionarios(funcionario_id);

-- 12. VERIFICAÇÃO FINAL
SELECT 'VERIFICAÇÃO DA MIGRAÇÃO COMPLETA:' AS status;

SELECT 'Total organizações:' AS item, COUNT(*) AS quantidade FROM organizacoes
UNION ALL
SELECT 'Total funcionários:' AS item, COUNT(*) AS quantidade FROM funcionarios
UNION ALL
SELECT 'Login DNOTAS existe:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE email = 'DNOTAS'
UNION ALL
SELECT 'Funcionários com organizacao_id:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE organizacao_id IS NOT NULL;