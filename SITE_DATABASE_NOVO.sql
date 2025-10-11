-- ============================================
-- SCHEMA SIMPLIFICADO DNOTAS - SISTEMA HIERÁRQUICO
-- Matriz → Filiais → Funcionários → Clientes
-- ============================================

-- 1. TABELA DE ORGANIZAÇÕES (Matriz + Filiais)
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
  matriz_id VARCHAR(50) REFERENCES organizacoes(id) ON DELETE RESTRICT, -- Filiais apontam para matriz
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABELA DE FUNCIONÁRIOS SIMPLIFICADA
CREATE TABLE IF NOT EXISTS funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  cargo VARCHAR(50) NOT NULL,
  organizacao_id VARCHAR(50) REFERENCES organizacoes(id) ON DELETE RESTRICT,
  role VARCHAR(20) DEFAULT 'operator' CHECK (role IN ('super_admin', 'admin', 'manager', 'operator')),
  ativo BOOLEAN DEFAULT true,
  ultimo_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABELA DE ATIVIDADES DOS FUNCIONÁRIOS
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL,
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}',
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- DADOS INICIAIS
-- ============================================

-- Inserir Matriz
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, ativo) VALUES
('matriz', 'DNOTAS - Matriz', 'matriz', 'MATRIZ', '12.345.678/0001-90', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  tipo = EXCLUDED.tipo,
  codigo = EXCLUDED.codigo,
  cnpj = EXCLUDED.cnpj,
  ativo = EXCLUDED.ativo;

-- Inserir algumas filiais de exemplo
INSERT INTO organizacoes (id, nome, tipo, codigo, cnpj, matriz_id, ativo) VALUES
('filial_centro', 'DNOTAS - Filial Centro', 'filial', 'FIL001', '12.345.678/0002-71', 'matriz', true),
('filial_norte', 'DNOTAS - Filial Norte', 'filial', 'FIL002', '12.345.678/0003-52', 'matriz', true),
('filial_sul', 'DNOTAS - Filial Sul', 'filial', 'FIL003', '12.345.678/0004-33', 'matriz', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  tipo = EXCLUDED.tipo,
  codigo = EXCLUDED.codigo,
  cnpj = EXCLUDED.cnpj,
  matriz_id = EXCLUDED.matriz_id,
  ativo = EXCLUDED.ativo;

-- Inserir funcionário da MATRIZ (super admin)
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
('Administrador DNOTAS', 'DNOTAS', 'D100*', 'Super Administrador', 'matriz', 'super_admin', true)
ON CONFLICT (email) DO UPDATE SET
  senha = EXCLUDED.senha,
  nome = EXCLUDED.nome,
  cargo = EXCLUDED.cargo,
  organizacao_id = EXCLUDED.organizacao_id,
  role = EXCLUDED.role,
  ativo = EXCLUDED.ativo;

-- Inserir funcionários de exemplo das filiais
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role, ativo) VALUES
-- Filial Centro
('Gestor Centro', 'gestor.centro@dnotas.com', 'centro123', 'Gerente', 'filial_centro', 'admin', true),
('João Santos', 'joao.santos@dnotas.com', 'funcionario123', 'Atendente', 'filial_centro', 'operator', true),

-- Filial Norte
('Gestor Norte', 'gestor.norte@dnotas.com', 'norte123', 'Gerente', 'filial_norte', 'admin', true),
('Ana Costa', 'ana.costa@dnotas.com', 'funcionario123', 'Atendente', 'filial_norte', 'operator', true),

-- Filial Sul
('Gestor Sul', 'gestor.sul@dnotas.com', 'sul123', 'Gerente', 'filial_sul', 'admin', true),
('Carlos Silva', 'carlos.silva@dnotas.com', 'funcionario123', 'Atendente', 'filial_sul', 'operator', true)

ON CONFLICT (email) DO NOTHING;

-- ============================================
-- ÍNDICES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_matriz ON organizacoes(matriz_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_ativo ON funcionarios(ativo);
CREATE INDEX IF NOT EXISTS idx_atividades_funcionario ON atividades_funcionarios(funcionario_id);

-- ============================================
-- FUNÇÕES ÚTEIS
-- ============================================

-- Função para listar filiais (só matriz pode ver todas)
CREATE OR REPLACE FUNCTION get_filiais_matriz()
RETURNS TABLE (
  id VARCHAR(50),
  nome VARCHAR(100),
  codigo VARCHAR(20),
  cnpj VARCHAR(18),
  ativo BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.id, o.nome, o.codigo, o.cnpj, o.ativo
  FROM organizacoes o
  WHERE o.tipo = 'filial' AND o.ativo = true
  ORDER BY o.nome;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para listar funcionários por organização
CREATE OR REPLACE FUNCTION get_funcionarios_organizacao(p_organizacao_id VARCHAR(50))
RETURNS TABLE (
  id UUID,
  nome VARCHAR(100),
  email VARCHAR(100),
  cargo VARCHAR(50),
  role VARCHAR(20),
  ativo BOOLEAN,
  ultimo_login TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT f.id, f.nome, f.email, f.cargo, f.role, f.ativo, f.ultimo_login
  FROM funcionarios f
  WHERE f.organizacao_id = p_organizacao_id
  ORDER BY f.nome;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;`