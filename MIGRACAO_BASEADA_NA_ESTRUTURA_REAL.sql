-- ============================================
-- MIGRAÇÃO BASEADA NA ESTRUTURA REAL DO BANCO
-- Investigação completa realizada via MCP
-- ============================================

-- 1. CRIAR TABELA ORGANIZACOES (não existe)
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

-- 4. INSERIR FILIAIS QUE OS FUNCIONÁRIOS REFERENCIAM (mas que não existem)
INSERT INTO organizacoes (id, nome, tipo, matriz_id, ativo) VALUES
('filial_centro', 'Filial Centro', 'filial', 'matriz', true),
('filial_norte', 'Filial Norte', 'filial', 'matriz', true),
('filial_sul', 'Filial Sul', 'filial', 'matriz', true)
ON CONFLICT (id) DO NOTHING;

-- 5. ADICIONAR COLUNA organizacao_id NA TABELA FUNCIONARIOS (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'organizacao_id') THEN
        ALTER TABLE funcionarios ADD COLUMN organizacao_id VARCHAR(50);
    END IF;
END $$;

-- 6. MIGRAR filial_id PARA organizacao_id
UPDATE funcionarios 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL AND filial_id IS NOT NULL;

-- 7. CRIAR USUÁRIO DNOTAS (não existe)
INSERT INTO funcionarios (nome, email, senha, cargo, filial_id, organizacao_id, role, ativo) VALUES
('Administrador DNOTAS', 'DNOTAS', 'D100*', 'Super Administrador', 'matriz', 'matriz', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- 8. CRIAR FOREIGN KEY CONSTRAINT (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'funcionarios_organizacao_id_fkey'
    ) THEN
        ALTER TABLE funcionarios 
        ADD CONSTRAINT funcionarios_organizacao_id_fkey 
        FOREIGN KEY (organizacao_id) REFERENCES organizacoes(id) ON DELETE RESTRICT;
    END IF;
END $$;

-- 9. ATUALIZAR CLIENTES PARA REFERENCIAR ORGANIZACOES
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'organizacao_id') THEN
        ALTER TABLE clientes ADD COLUMN organizacao_id VARCHAR(50);
    END IF;
END $$;

UPDATE clientes 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL AND filial_id IS NOT NULL;

-- 10. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_matriz ON organizacoes(matriz_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);
CREATE INDEX IF NOT EXISTS idx_clientes_organizacao ON clientes(organizacao_id);

-- 11. VERIFICAÇÃO FINAL
SELECT 'MIGRAÇÃO CONCLUÍDA COM SUCESSO!' as status;

SELECT 'Organizações criadas:' AS item, COUNT(*) AS quantidade FROM organizacoes
UNION ALL
SELECT 'Funcionários total:' AS item, COUNT(*) AS quantidade FROM funcionarios
UNION ALL
SELECT 'Login DNOTAS criado:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE email = 'DNOTAS'
UNION ALL
SELECT 'Funcionários com organizacao_id:' AS item, COUNT(*) AS quantidade FROM funcionarios WHERE organizacao_id IS NOT NULL
UNION ALL
SELECT 'Clientes com organizacao_id:' AS item, COUNT(*) AS quantidade FROM clientes WHERE organizacao_id IS NOT NULL;