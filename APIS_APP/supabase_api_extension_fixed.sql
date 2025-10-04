-- EXTENSÃO DO SUPABASE PARA AS APIS (VERSÃO CORRIGIDA)
-- Este script adiciona as tabelas necessárias para as APIs
-- SEM conflitar com o schema existente do Supabase
-- Execute no SQL Editor do Supabase

-- ===================================================================
-- ADICIONAR COLUNAS NECESSÁRIAS ÀS TABELAS EXISTENTES
-- ===================================================================

-- 1. Adicionar campos necessários na tabela clientes para compatibilidade com APIs
ALTER TABLE clientes 
ADD COLUMN IF NOT EXISTS senha VARCHAR(255),
ADD COLUMN IF NOT EXISTS fcm_token TEXT,
ADD COLUMN IF NOT EXISTS reset_token VARCHAR(255),
ADD COLUMN IF NOT EXISTS reset_token_expiry TIMESTAMP WITH TIME ZONE;

-- 2. Atualizar filiais com campos adicionais
ALTER TABLE filiais 
ADD COLUMN IF NOT EXISTS codigo VARCHAR(20),
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true;

-- Atualizar códigos das filiais existentes
UPDATE filiais SET codigo = id WHERE codigo IS NULL;
UPDATE filiais SET ativo = true WHERE ativo IS NULL;

-- ===================================================================
-- CRIAR TABELAS ESPECÍFICAS DAS APIS
-- ===================================================================

-- 3. Tabela de Relatórios de Vendas (nova funcionalidade)
CREATE TABLE IF NOT EXISTS relatorios_vendas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    cliente_cnpj VARCHAR(14) NOT NULL,
    filial_id VARCHAR(50) NOT NULL REFERENCES filiais(id),
    data_relatorio DATE NOT NULL,
    vendas_debito DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_credito DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_dinheiro DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_pix DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_vale DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    total_vendas DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint para garantir apenas um relatório por cliente por dia
    UNIQUE(cliente_id, data_relatorio)
);

-- 4. Tabela de Boletos (área financeira)
CREATE TABLE IF NOT EXISTS boletos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    cliente_cnpj VARCHAR(14) NOT NULL,
    filial_id VARCHAR(50) NOT NULL REFERENCES filiais(id),
    numero_boleto VARCHAR(50) UNIQUE NOT NULL,
    valor DECIMAL(15,2) NOT NULL CHECK (valor > 0),
    data_vencimento DATE NOT NULL,
    data_pagamento TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pendente' NOT NULL CHECK (status IN ('pendente', 'pago', 'vencido', 'cancelado')),
    linha_digitavel TEXT NOT NULL,
    codigo_barras TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabela de Notificações Push (estrutura estendida)
CREATE TABLE IF NOT EXISTS notifications_api (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    cliente_cnpj VARCHAR(14) NOT NULL,
    filial_id VARCHAR(50) NOT NULL REFERENCES filiais(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('relatorio', 'boleto', 'inatividade', 'geral')),
    titulo VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    lida BOOLEAN DEFAULT false NOT NULL,
    data_envio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- ===================================================================

-- Índices para relatórios
CREATE INDEX IF NOT EXISTS idx_relatorios_cliente_data ON relatorios_vendas(cliente_id, data_relatorio DESC);
CREATE INDEX IF NOT EXISTS idx_relatorios_cnpj ON relatorios_vendas(cliente_cnpj);
CREATE INDEX IF NOT EXISTS idx_relatorios_filial ON relatorios_vendas(filial_id);

-- Índices para boletos
CREATE INDEX IF NOT EXISTS idx_boletos_cliente_status ON boletos(cliente_id, status);
CREATE INDEX IF NOT EXISTS idx_boletos_cnpj ON boletos(cliente_cnpj);
CREATE INDEX IF NOT EXISTS idx_boletos_vencimento ON boletos(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_boletos_numero ON boletos(numero_boleto);

-- Índices para notificações da API
CREATE INDEX IF NOT EXISTS idx_notifications_api_cliente ON notifications_api(cliente_id, lida);
CREATE INDEX IF NOT EXISTS idx_notifications_api_cnpj ON notifications_api(cliente_cnpj);
CREATE INDEX IF NOT EXISTS idx_notifications_api_data ON notifications_api(data_envio DESC);

-- ===================================================================
-- CRIAR FUNÇÕES
-- ===================================================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Função para calcular total_vendas automaticamente
CREATE OR REPLACE FUNCTION calculate_total_vendas()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_vendas = NEW.vendas_debito + NEW.vendas_credito + NEW.vendas_dinheiro + NEW.vendas_pix + NEW.vendas_vale;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Função para sincronizar CNPJ automaticamente
CREATE OR REPLACE FUNCTION sync_cliente_cnpj()
RETURNS TRIGGER AS $$
BEGIN
    -- Buscar CNPJ do cliente
    SELECT cnpj INTO NEW.cliente_cnpj 
    FROM clientes 
    WHERE id = NEW.cliente_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ===================================================================
-- CRIAR TRIGGERS (SEM IF NOT EXISTS)
-- ===================================================================

-- Remover triggers existentes se houver
DROP TRIGGER IF EXISTS update_relatorios_updated_at ON relatorios_vendas;
DROP TRIGGER IF EXISTS update_boletos_updated_at ON boletos;
DROP TRIGGER IF EXISTS calculate_relatorios_total ON relatorios_vendas;
DROP TRIGGER IF EXISTS sync_relatorios_cnpj ON relatorios_vendas;
DROP TRIGGER IF EXISTS sync_boletos_cnpj ON boletos;
DROP TRIGGER IF EXISTS sync_notifications_cnpj ON notifications_api;

-- Criar triggers
CREATE TRIGGER update_relatorios_updated_at 
    BEFORE UPDATE ON relatorios_vendas 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_boletos_updated_at 
    BEFORE UPDATE ON boletos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER calculate_relatorios_total 
    BEFORE INSERT OR UPDATE ON relatorios_vendas 
    FOR EACH ROW EXECUTE FUNCTION calculate_total_vendas();

CREATE TRIGGER sync_relatorios_cnpj 
    BEFORE INSERT OR UPDATE ON relatorios_vendas 
    FOR EACH ROW EXECUTE FUNCTION sync_cliente_cnpj();

CREATE TRIGGER sync_boletos_cnpj 
    BEFORE INSERT OR UPDATE ON boletos 
    FOR EACH ROW EXECUTE FUNCTION sync_cliente_cnpj();

CREATE TRIGGER sync_notifications_cnpj 
    BEFORE INSERT OR UPDATE ON notifications_api 
    FOR EACH ROW EXECUTE FUNCTION sync_cliente_cnpj();

-- ===================================================================
-- FUNÇÕES PARA AS APIS
-- ===================================================================

-- Função para obter dados do cliente por CNPJ (compatibilidade com API)
CREATE OR REPLACE FUNCTION get_cliente_by_cnpj(p_cnpj VARCHAR(14))
RETURNS TABLE (
    id UUID,
    cnpj VARCHAR(14),
    nome VARCHAR(255),
    email VARCHAR(255),
    telefone VARCHAR(15),
    filial_id VARCHAR(50),
    senha VARCHAR(255),
    fcm_token TEXT,
    ultimo_acesso TIMESTAMP WITH TIME ZONE,
    ativo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.cnpj,
        c.nome_empresa as nome,
        c.email,
        c.telefone,
        c.filial_id,
        c.senha,
        c.fcm_token,
        c.last_login as ultimo_acesso,
        c.is_active as ativo
    FROM clientes c
    WHERE c.cnpj = p_cnpj AND c.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Função para obter vendas por período
CREATE OR REPLACE FUNCTION get_vendas_periodo(
    p_cliente_id UUID,
    p_data_inicio DATE,
    p_data_fim DATE
) RETURNS TABLE (
    total_periodo DECIMAL(15,2),
    media_diaria DECIMAL(15,2),
    dias_com_vendas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(total_vendas), 0) as total_periodo,
        COALESCE(AVG(total_vendas), 0) as media_diaria,
        COUNT(*)::INTEGER as dias_com_vendas
    FROM relatorios_vendas 
    WHERE cliente_id = p_cliente_id 
    AND data_relatorio BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- VIEWS PARA COMPATIBILIDADE COM APIS
-- ===================================================================

-- View que simula a tabela users para compatibilidade
CREATE OR REPLACE VIEW users_api AS
SELECT 
    c.id,
    c.cnpj,
    c.nome_empresa as nome,
    c.email,
    c.telefone,
    c.senha,
    c.filial_id,
    c.fcm_token,
    c.reset_token,
    c.reset_token_expiry,
    c.last_login as ultimo_acesso,
    c.is_active as ativo,
    c.created_at,
    NOW() as updated_at
FROM clientes c;

-- ===================================================================
-- CONFIGURAR RLS PARA NOVAS TABELAS
-- ===================================================================

-- Habilitar RLS
ALTER TABLE relatorios_vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE boletos ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications_api ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS "Clientes veem apenas seus relatórios" ON relatorios_vendas;
DROP POLICY IF EXISTS "Clientes veem apenas seus boletos" ON boletos;
DROP POLICY IF EXISTS "Clientes veem apenas suas notificações" ON notifications_api;

-- Criar políticas RLS
CREATE POLICY "Clientes veem apenas seus relatórios" ON relatorios_vendas
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes veem apenas seus boletos" ON boletos
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes veem apenas suas notificações" ON notifications_api
    FOR ALL USING (cliente_id = auth.uid());

-- ===================================================================
-- DADOS DE EXEMPLO
-- ===================================================================

-- Inserir senhas padrão para clientes existentes (hash para '123456')
UPDATE clientes 
SET senha = '$2a$12$LQv3c1yqBw8S.XzPNZ7Dw.fvDq4K5hF9bHf5QKqYdYOzqTgvZJ1C2'
WHERE senha IS NULL;

-- ===================================================================
-- VERIFICAÇÕES FINAIS
-- ===================================================================

-- Verificar se tudo foi criado corretamente
SELECT 
    'relatorios_vendas' as tabela, 
    COUNT(*) as registros 
FROM relatorios_vendas
UNION ALL
SELECT 
    'boletos' as tabela, 
    COUNT(*) as registros 
FROM boletos
UNION ALL
SELECT 
    'notifications_api' as tabela, 
    COUNT(*) as registros 
FROM notifications_api
UNION ALL
SELECT 
    'clientes_com_senha' as tabela, 
    COUNT(*) as registros 
FROM clientes 
WHERE senha IS NOT NULL;