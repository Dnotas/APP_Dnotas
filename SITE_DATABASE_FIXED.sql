-- ============================================
-- SCHEMA DO SITE ADMINISTRATIVO DNOTAS (CORRIGIDO)
-- Sistema de gestão para funcionários
-- ============================================

-- Primeiro, vamos verificar e ajustar a estrutura da tabela filiais existente
-- Não vamos criar a tabela filiais se ela já existe, apenas garantir que tem os campos necessários

-- Adicionar campos à tabela filiais se não existirem
DO $$
BEGIN
    -- Adicionar campo tipo se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'tipo') THEN
        ALTER TABLE filiais ADD COLUMN tipo VARCHAR(20) DEFAULT 'filial';
    END IF;
    
    -- Adicionar outros campos se não existirem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'codigo') THEN
        ALTER TABLE filiais ADD COLUMN codigo VARCHAR(20) UNIQUE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'cnpj_empresa') THEN
        ALTER TABLE filiais ADD COLUMN cnpj_empresa VARCHAR(18);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'endereco') THEN
        ALTER TABLE filiais ADD COLUMN endereco TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'telefone') THEN
        ALTER TABLE filiais ADD COLUMN telefone VARCHAR(20);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'email') THEN
        ALTER TABLE filiais ADD COLUMN email VARCHAR(100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'responsavel') THEN
        ALTER TABLE filiais ADD COLUMN responsavel VARCHAR(100);
    END IF;
END $$;

-- Tabela de funcionários (adaptada para usar VARCHAR como FK)
CREATE TABLE IF NOT EXISTS funcionarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL, -- Hash bcrypt
  cpf VARCHAR(14) UNIQUE,
  telefone VARCHAR(20),
  cargo VARCHAR(50) NOT NULL,
  filial_id VARCHAR REFERENCES filiais(id) ON DELETE RESTRICT, -- Mudou para VARCHAR
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

-- Primeiro, vamos inserir filiais usando IDs simples (compatível com VARCHAR)
INSERT INTO filiais (id, nome, codigo, tipo, cnpj_empresa, ativo) VALUES
('matriz', 'Matriz DNOTAS', 'MATRIZ', 'matriz', '12.345.678/0001-90', true),
('filial_centro', 'Filial Centro', 'FIL001', 'filial', '12.345.678/0002-71', true),
('filial_norte', 'Filial Norte', 'FIL002', 'filial', '12.345.678/0003-52', true),
('filial_sul', 'Filial Sul', 'FIL003', 'filial', '12.345.678/0004-33', true)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  tipo = EXCLUDED.tipo,
  cnpj_empresa = EXCLUDED.cnpj_empresa,
  ativo = EXCLUDED.ativo;

-- Inserir funcionários iniciais (senhas serão 'admin123', 'gestor123', etc.)
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

-- Só criar triggers se as colunas updated_at existirem
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'filiais' AND column_name = 'updated_at') THEN
        DROP TRIGGER IF EXISTS update_filiais_updated_at ON filiais;
        CREATE TRIGGER update_filiais_updated_at BEFORE UPDATE ON filiais
          FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    DROP TRIGGER IF EXISTS update_funcionarios_updated_at ON funcionarios;
    CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios  
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
END $$;

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
CREATE OR REPLACE FUNCTION get_funcionarios_filial(p_filial_id VARCHAR)
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