-- SQL SIMPLIFICADO para Supabase - Execute cada bloco separadamente

-- 1. PRIMEIRO: Criar tabela de organizações
CREATE TABLE IF NOT EXISTS organizacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
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

-- 2. SEGUNDO: Inserir organizações (execute separadamente)
INSERT INTO organizacoes (id, nome, tipo, codigo, matriz_id) VALUES 
('11111111-1111-1111-1111-111111111111', 'Matriz DNOTAS', 'matriz', 'matriz', null);

INSERT INTO organizacoes (id, nome, tipo, codigo, matriz_id) VALUES 
('22222222-2222-2222-2222-222222222222', 'Filial 1', 'filial', 'filial01', 'matriz');

INSERT INTO organizacoes (id, nome, tipo, codigo, matriz_id) VALUES 
('33333333-3333-3333-3333-333333333333', 'Filial 2', 'filial', 'filial02', 'matriz');

-- 3. TERCEIRO: Criar tabela de funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
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

-- 4. QUARTO: Inserir funcionários (execute separadamente)
INSERT INTO funcionarios (id, nome, email, senha, cargo, organizacao_id, role) VALUES 
('aaaa1111-1111-1111-1111-111111111111', 'Administrador Sistema', 'admin@dnotas.com', 'admin123', 'Administrador', '11111111-1111-1111-1111-111111111111', 'admin');

INSERT INTO funcionarios (id, nome, email, senha, cargo, organizacao_id, role) VALUES 
('bbbb2222-2222-2222-2222-222222222222', 'Gestor Matriz', 'gestor@dnotas.com', 'gestor123', 'Gestor', '11111111-1111-1111-1111-111111111111', 'manager');

-- 5. QUINTO: Criar tabela de atividades
CREATE TABLE IF NOT EXISTS atividades_funcionarios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    funcionario_id UUID REFERENCES funcionarios(id),
    tipo_atividade VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    dados_extras JSONB,
    cliente_cnpj VARCHAR(14),
    resultado VARCHAR(20) CHECK (resultado IN ('success', 'error', 'warning')) DEFAULT 'success',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);