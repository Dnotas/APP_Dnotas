-- Criar tabelas necessárias para o sistema DNOTAS

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    nome_empresa VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    filial_id VARCHAR(50) DEFAULT 'matriz-id',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela de filiais
CREATE TABLE IF NOT EXISTS filiais (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    endereco TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    filial_id VARCHAR(50) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Desabilitar RLS temporariamente para desenvolvimento
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE filiais DISABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;

-- Inserir dados de teste
INSERT INTO clientes (cnpj, nome_empresa, senha) VALUES 
('12345678000100', 'Empresa Teste 1', '123456'),
('98765432000199', 'Empresa Teste 2', 'senha123')
ON CONFLICT (cnpj) DO NOTHING;

INSERT INTO filiais (nome, codigo, cidade, estado) VALUES 
('Filial São Paulo', 'SP001', 'São Paulo', 'SP'),
('Filial Rio de Janeiro', 'RJ001', 'Rio de Janeiro', 'RJ')
ON CONFLICT (codigo) DO NOTHING;