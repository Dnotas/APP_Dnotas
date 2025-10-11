-- ============================================
-- SCHEMA DO SITE ADMINISTRATIVO DNOTAS
-- Sistema de gestão para funcionários
-- ============================================

-- Tabela de filiais (já existe, mas vamos garantir)
CREATE TABLE IF NOT EXISTS filiais (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  codigo VARCHAR(20) UNIQUE NOT NULL,
  tipo VARCHAR(20) DEFAULT 'filial' CHECK (tipo IN ('matriz', 'filial')),
  cnpj_empresa VARCHAR(18),
  endereco TEXT,
  telefone VARCHAR(20),
  email VARCHAR(100),
  responsavel VARCHAR(100),
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de funcionários (para login no site administrativo)
CREATE TABLE IF NOT EXISTS funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL, -- Hash bcrypt
  cpf VARCHAR(14) UNIQUE,
  telefone VARCHAR(20),
  cargo VARCHAR(50) NOT NULL,
  filial_id UUID REFERENCES filiais(id) ON DELETE RESTRICT,
  role VARCHAR(20) DEFAULT 'operator' CHECK (role IN ('admin', 'manager', 'operator', 'viewer')),
  permissoes JSONB DEFAULT '{}',
  foto_url TEXT,
  data_admissao DATE,
  salario DECIMAL(10,2),
  ativo BOOLEAN DEFAULT true,
  ultimo_login TIMESTAMP WITH TIME ZONE,
  reset_token VARCHAR(255),
  reset_token_expiry TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de atividades/logs dos funcionários
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  tipo_atividade VARCHAR(50) NOT NULL, -- 'login', 'logout', 'create_client', 'send_message', 'generate_report', etc.
  descricao TEXT NOT NULL,
  dados_extras JSONB DEFAULT '{}', -- Para armazenar detalhes específicos
  ip_address INET,
  user_agent TEXT,
  cliente_cnpj VARCHAR(18), -- Se a atividade foi relacionada a um cliente específico
  resultado VARCHAR(20) DEFAULT 'success' CHECK (resultado IN ('success', 'error', 'warning')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de sessões ativas dos funcionários
CREATE TABLE IF NOT EXISTS sessoes_funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INSERIR DADOS INICIAIS
-- ============================================

-- Inserir filiais (matriz e filiais)
INSERT INTO filiais (nome, codigo, tipo, cnpj_empresa, ativo) VALUES
('Matriz DNOTAS', 'MATRIZ', 'matriz', '12.345.678/0001-90', true),
('Filial Centro', 'FIL001', 'filial', '12.345.678/0002-71', true),
('Filial Norte', 'FIL002', 'filial', '12.345.678/0003-52', true),
('Filial Sul', 'FIL003', 'filial', '12.345.678/0004-33', true)
ON CONFLICT (codigo) DO NOTHING;

-- Inserir funcionários iniciais (senhas serão 'admin123', 'gestor123', etc. - hash bcrypt)
INSERT INTO funcionarios (nome, email, senha, cargo, filial_id, role, ativo) VALUES
-- Matriz
('Administrador Sistema', 'admin@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Administrador', (SELECT id FROM filiais WHERE codigo = 'MATRIZ'), 'admin', true),
('Gestor Matriz', 'gestor@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Gerente', (SELECT id FROM filiais WHERE codigo = 'MATRIZ'), 'manager', true),
('Maria Silva', 'maria.silva@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Analista Contábil', (SELECT id FROM filiais WHERE codigo = 'MATRIZ'), 'operator', true),

-- Filial Centro
('João Santos', 'joao.santos@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Atendente', (SELECT id FROM filiais WHERE codigo = 'FIL001'), 'operator', true),
('Ana Costa', 'ana.costa@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Supervisora', (SELECT id FROM filiais WHERE codigo = 'FIL001'), 'manager', true),

-- Filial Norte  
('Carlos Oliveira', 'carlos.oliveira@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Atendente', (SELECT id FROM filiais WHERE codigo = 'FIL002'), 'operator', true),

-- Filial Sul
('Paula Lima', 'paula.lima@dnotas.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/Nv/5aBCmn6QVhXJ6O', 'Atendente', (SELECT id FROM filiais WHERE codigo = 'FIL003'), 'operator', true)

ON CONFLICT (email) DO NOTHING;

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_filial ON funcionarios(filial_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_ativo ON funcionarios(ativo);
CREATE INDEX IF NOT EXISTS idx_atividades_funcionario ON atividades_funcionarios(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_atividades_created_at ON atividades_funcionarios(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessoes_funcionario ON sessoes_funcionarios(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_sessoes_token ON sessoes_funcionarios(token_hash);

-- ============================================
-- TRIGGERS PARA UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_filiais_updated_at BEFORE UPDATE ON filiais
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios  
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- RLS (ROW LEVEL SECURITY)
-- ============================================

-- Habilitar RLS nas tabelas
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE atividades_funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessoes_funcionarios ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança (funcionários só veem dados da sua filial)
CREATE POLICY "Funcionarios podem ver apenas da sua filial" ON funcionarios
  FOR ALL USING (
    auth.uid() IN (
      SELECT id::text FROM funcionarios 
      WHERE filial_id = funcionarios.filial_id
    )
  );

-- Políticas para atividades
CREATE POLICY "Funcionarios podem ver suas atividades" ON atividades_funcionarios
  FOR ALL USING (
    funcionario_id IN (
      SELECT id FROM funcionarios 
      WHERE id::text = auth.uid()
    )
  );

-- ============================================
-- FUNÇÕES ÚTEIS
-- ============================================

-- Função para registrar atividade do funcionário
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

-- Função para listar funcionários da filial
CREATE OR REPLACE FUNCTION get_funcionarios_filial(p_filial_id UUID)
RETURNS TABLE (
  id UUID,
  nome VARCHAR(100),
  email VARCHAR(100),
  cargo VARCHAR(50),
  role VARCHAR(20),
  ativo BOOLEAN,
  ultimo_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT f.id, f.nome, f.email, f.cargo, f.role, f.ativo, f.ultimo_login, f.created_at
  FROM funcionarios f
  WHERE f.filial_id = p_filial_id
  ORDER BY f.nome;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;