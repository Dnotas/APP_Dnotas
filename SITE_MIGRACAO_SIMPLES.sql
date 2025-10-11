-- ============================================
-- MIGRAÇÃO SIMPLES DNOTAS
-- Cria nova estrutura sem conflitos
-- ============================================

-- 1. CRIAR TABELA DE ORGANIZAÇÕES (se não existir)
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

-- 2. INSERIR MATRIZ
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo) VALUES
('matriz', 'DNOTAS - Matriz', 'matriz', 'MATRIZ', '12.345.678/0001-90', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  tipo = EXCLUDED.tipo,
  codigo = EXCLUDED.codigo,
  cnpj = EXCLUDED.cnpj,
  ativo = EXCLUDED.ativo;

-- 3. MIGRAR FILIAIS EXISTENTES (sem referenciar coluna tipo que não existe)
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, matriz_id, ativo)
SELECT 
  id,
  nome,
  'filial' as tipo,  -- Definir como filial diretamente
  NULL as codigo,    -- Será preenchido depois se necessário
  NULL as cnpj,      -- Será preenchido depois se necessário
  'matriz' as matriz_id,
  COALESCE(ativo, true) as ativo
FROM filiais
WHERE NOT EXISTS (SELECT 1 FROM organizacoes WHERE organizacoes.id = filiais.id);

-- 4. ADICIONAR COLUNA organizacao_id NA TABELA FUNCIONARIOS (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'organizacao_id') THEN
        ALTER TABLE funcionarios ADD COLUMN organizacao_id VARCHAR(50);
    END IF;
END $$;

-- 5. MIGRAR filial_id PARA organizacao_id
UPDATE funcionarios 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL AND filial_id IS NOT NULL;

-- 6. LIMPAR FUNCIONÁRIOS EXISTENTES COM EMAIL DNOTAS
DELETE FROM funcionarios WHERE email = 'DNOTAS';

-- 7. INSERIR FUNCIONÁRIO DA MATRIZ
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Administrador DNOTAS', 'DNOTAS', 'D100*', 'Super Administrador', 'matriz', 'admin', true);

-- 8. INSERIR ALGUNS FUNCIONÁRIOS DE EXEMPLO DAS FILIAIS
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Gestor Centro', 'gestor.centro@dnotas.com', 'centro123', 'Gerente', 'filial_centro', 'admin', true),
('Gestor Norte', 'gestor.norte@dnotas.com', 'norte123', 'Gerente', 'filial_norte', 'admin', true),
('Gestor Sul', 'gestor.sul@dnotas.com', 'sul123', 'Gerente', 'filial_sul', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- 9. CRIAR TABELA DE ATIVIDADES (se não existir)
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL,
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}',
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_matriz ON organizacoes(matriz_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);

-- 11. VERIFICAR RESULTADO
SELECT 'VERIFICAÇÃO DA MIGRAÇÃO:' AS status;
SELECT 'Organizações criadas:' AS item, COUNT(*) AS quantidade FROM organizacoes;
SELECT 'Funcionários com organizacao_id:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE organizacao_id IS NOT NULL;
SELECT 'Login DNOTAS criado:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE email = 'DNOTAS';