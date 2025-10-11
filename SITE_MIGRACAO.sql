-- ============================================
-- MIGRAÇÃO PARA NOVA ESTRUTURA DNOTAS
-- Atualiza tabelas existentes para nova hierarquia
-- ============================================

-- 1. CRIAR TABELA DE ORGANIZAÇÕES (se não existir)
CREATE TABLE IF NOT EXISTS organizacoes (
  id VARCHAR(50) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  tipo VARCHAR(20) CHECK (tipo IN ('matriz', 'filial')) NOT NULL,
  codigo VARCHAR(20) UNIQUE,
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

-- 2. MIGRAR DADOS DA TABELA FILIAIS PARA ORGANIZACOES
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo)
SELECT 
  id,
  nome,
  COALESCE(tipo, 'filial') as tipo,
  codigo,
  cnpj,
  ativo
FROM filiais
WHERE NOT EXISTS (SELECT 1 FROM organizacoes WHERE organizacoes.id = filiais.id);

-- 3. ADICIONAR MATRIZ SE NÃO EXISTIR
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo) VALUES
('matriz', 'DNOTAS - Matriz', 'matriz', 'MATRIZ', '12.345.678/0001-90', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  tipo = EXCLUDED.tipo,
  codigo = EXCLUDED.codigo,
  cnpj = EXCLUDED.cnpj,
  ativo = EXCLUDED.ativo;

-- 4. ATUALIZAR FILIAIS PARA APONTAR PARA MATRIZ
UPDATE organizacoes 
SET matriz_id = 'matriz' 
WHERE tipo = 'filial' AND matriz_id IS NULL;

-- 5. ADICIONAR COLUNA organizacao_id NA TABELA FUNCIONARIOS
DO $$
BEGIN
    -- Adicionar organizacao_id se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'organizacao_id') THEN
        ALTER TABLE funcionarios ADD COLUMN organizacao_id VARCHAR(50);
    END IF;
END $$;

-- 6. MIGRAR DADOS DE filial_id PARA organizacao_id
UPDATE funcionarios 
SET organizacao_id = filial_id 
WHERE organizacao_id IS NULL AND filial_id IS NOT NULL;

-- 7. ADICIONAR FOREIGN KEY CONSTRAINT (se não existir)
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

-- 8. LIMPAR E INSERIR FUNCIONÁRIO DA MATRIZ
-- Primeiro deletar se existir
DELETE FROM funcionarios WHERE email = 'DNOTAS';

-- Inserir funcionário da MATRIZ
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Administrador DNOTAS', 'DNOTAS', 'D100*', 'Super Administrador', 'matriz', 'admin', true);

-- 9. ATUALIZAR FUNCIONÁRIOS EXISTENTES PARA NOVA ESTRUTURA DE ROLES
UPDATE funcionarios SET role = 'admin' WHERE role = 'super_admin' OR email = 'admin@dnotas.com';
UPDATE funcionarios SET role = 'admin' WHERE role = 'manager' AND cargo LIKE '%Gerente%';
UPDATE funcionarios SET role = 'operator' WHERE role NOT IN ('admin', 'manager');

-- 10. CRIAR TABELA DE ATIVIDADES SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL,
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}',
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. CRIAR ÍNDICES NECESSÁRIOS
CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_matriz ON organizacoes(matriz_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);

-- 12. FUNÇÃO PARA LISTAR ORGANIZAÇÕES
CREATE OR REPLACE FUNCTION get_organizacoes_ativas()
RETURNS TABLE (
  id VARCHAR(50),
  nome VARCHAR(100),
  tipo VARCHAR(20),
  codigo VARCHAR(20),
  cnpj VARCHAR(18),
  ativo BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.id, o.nome, o.tipo, o.codigo, o.cnpj, o.ativo
  FROM organizacoes o
  WHERE o.ativo = true
  ORDER BY o.tipo DESC, o.nome; -- Matriz primeiro, depois filiais
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. VERIFICAR MIGRAÇÃO
SELECT 'ORGANIZAÇÕES:' as tabela, count(*) as total FROM organizacoes
UNION ALL
SELECT 'FUNCIONÁRIOS:' as tabela, count(*) as total FROM funcionarios
UNION ALL
SELECT 'FUNCIONÁRIO MATRIZ:' as tabela, count(*) as total FROM funcionarios WHERE email = 'DNOTAS';