-- Criar tabelas necessárias no Supabase para o SITE administrativo

-- Tabela de organizações (matriz e filiais)
CREATE TABLE IF NOT EXISTS organizacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(10) CHECK (tipo IN ('matriz', 'filial')) NOT NULL,
    codigo VARCHAR(20) UNIQUE,
    cnpj VARCHAR(14),
    endereco TEXT,
    telefone VARCHAR(20),
    email VARCHAR(100),
    responsavel VARCHAR(100),
    matriz_id VARCHAR(50),
    ativo BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Inserir organizações padrão
INSERT INTO organizacoes (nome, tipo, codigo, matriz_id) VALUES 
('Matriz DNOTAS', 'matriz', 'matriz', null),
('Filial 1', 'filial', 'filial01', 'matriz'),
('Filial 2', 'filial', 'filial02', 'matriz')
ON CONFLICT (codigo) DO NOTHING;

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cargo VARCHAR(100),
    organizacao_id UUID REFERENCES organizacoes(id),
    role VARCHAR(20) CHECK (role IN ('super_admin', 'admin', 'manager', 'operator')) DEFAULT 'operator',
    cpf VARCHAR(11),
    telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT true NOT NULL,
    ultimo_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Inserir funcionários padrão
INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role) 
SELECT 
    'Administrador Sistema',
    'admin@dnotas.com',
    'admin123',
    'Administrador',
    org.id,
    'admin'
FROM organizacoes org 
WHERE org.codigo = 'matriz'
ON CONFLICT (email) DO NOTHING;

INSERT INTO funcionarios (nome, email, senha, cargo, organizacao_id, role) 
SELECT 
    'Gestor Matriz',
    'gestor@dnotas.com',
    'gestor123',
    'Gestor',
    org.id,
    'manager'
FROM organizacoes org 
WHERE org.codigo = 'matriz'
ON CONFLICT (email) DO NOTHING;

-- Tabela de atividades dos funcionários
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    funcionario_id UUID REFERENCES funcionarios(id),
    tipo_atividade VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    dados_extras JSONB,
    cliente_cnpj VARCHAR(14),
    resultado VARCHAR(20) CHECK (resultado IN ('success', 'error', 'warning')) DEFAULT 'success',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_organizacao ON funcionarios(organizacao_id);
CREATE INDEX IF NOT EXISTS idx_organizacoes_codigo ON organizacoes(codigo);
CREATE INDEX IF NOT EXISTS idx_organizacoes_tipo ON organizacoes(tipo);
CREATE INDEX IF NOT EXISTS idx_atividades_funcionario ON atividades_funcionarios(funcionario_id);

-- Comentários
COMMENT ON TABLE organizacoes IS 'Tabela de organizações (matriz e filiais)';
COMMENT ON TABLE funcionarios IS 'Tabela de funcionários do sistema administrativo';
COMMENT ON TABLE atividades_funcionarios IS 'Tabela de atividades/logs dos funcionários';