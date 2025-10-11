-- ============================================
-- SCHEMA SIMPLIFICADO PARA FUNCIONÁRIOS
-- ============================================

-- Tabela de funcionários (versão simplificada)
CREATE TABLE IF NOT EXISTS funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  cargo VARCHAR(50) NOT NULL,
  filial_id VARCHAR NOT NULL,
  role VARCHAR(20) DEFAULT 'operator' CHECK (role IN ('admin', 'manager', 'operator', 'viewer')),
  ativo BOOLEAN DEFAULT true,
  ultimo_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de atividades dos funcionários
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL,
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}',
  cliente_cnpj VARCHAR(18),
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INSERIR FUNCIONÁRIOS
-- ============================================

-- Inserir funcionários iniciais
INSERT INTO funcionarios (nome, email, senha, cargo, filial_id, role, ativo) VALUES
-- Matriz
('Administrador Sistema', 'admin@dnotas.com', 'admin123', 'Administrador', 'matriz', 'admin', true),
('Gestor Matriz', 'gestor@dnotas.com', 'gestor123', 'Gerente', 'matriz', 'manager', true),
('Maria Silva', 'maria.silva@dnotas.com', 'funcionario123', 'Analista Contábil', 'matriz', 'operator', true),

-- Filial Centro
('João Santos', 'joao.santos@dnotas.com', 'funcionario123', 'Atendente', 'filial_centro', 'operator', true),
('Ana Costa', 'ana.costa@dnotas.com', 'funcionario123', 'Supervisora', 'filial_centro', 'manager', true),

-- Filial Norte  
('Carlos Oliveira', 'carlos.oliveira@dnotas.com', 'funcionario123', 'Atendente', 'filial_norte', 'operator', true),

-- Filial Sul
('Paula Lima', 'paula.lima@dnotas.com', 'funcionario123', 'Atendente', 'filial_sul', 'operator', true)

ON CONFLICT (email) DO NOTHING;

-- ============================================
-- ÍNDICES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_filial ON funcionarios(filial_id);
CREATE INDEX IF NOT EXISTS idx_atividades_funcionario ON atividades_funcionarios(funcionario_id);

-- ============================================
-- TRIGGER PARA UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_funcionarios_updated_at ON funcionarios;
CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios  
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNÇÃO PARA REGISTRAR ATIVIDADES
-- ============================================

CREATE OR REPLACE FUNCTION registrar_atividade_funcionario(
  p_funcionario_id UUID,
  p_tipo_atividade VARCHAR(50),
  p_descricao TEXT,
  p_dados_extras JSONB DEFAULT '{}'::jsonb,
  p_cliente_cnpj VARCHAR(18) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  atividade_id UUID;
BEGIN
  INSERT INTO atividades_funcionarios (
    funcionario_id, tipo_atividade, descricao, dados_extras, cliente_cnpj
  ) VALUES (
    p_funcionario_id, p_tipo_atividade, p_descricao, p_dados_extras, p_cliente_cnpj
  ) RETURNING id INTO atividade_id;
  
  RETURN atividade_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;