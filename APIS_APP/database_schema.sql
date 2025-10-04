-- DNOTAS API - Schema do Banco de Dados PostgreSQL
-- Versão: 1.0.0
-- Data: 2024

-- Configurações iniciais
SET timezone = 'America/Sao_Paulo';

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Tabela de Filiais (Matriz e Filiais)
CREATE TABLE IF NOT EXISTS filiais (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    endereco TEXT,
    telefone VARCHAR(20),
    email VARCHAR(100),
    ativo BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Inserir filiais padrão
INSERT INTO filiais (id, nome, codigo) VALUES 
('11111111-1111-1111-1111-111111111111', 'Matriz', 'matriz'),
('22222222-2222-2222-2222-222222222222', 'Filial 1', 'filial01'),
('33333333-3333-3333-3333-333333333333', 'Filial 2', 'filial02')
ON CONFLICT (codigo) DO NOTHING;

-- Tabela de Usuários (Clientes)
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    fcm_token TEXT,
    reset_token VARCHAR(255),
    reset_token_expiry TIMESTAMP WITH TIME ZONE,
    ultimo_acesso TIMESTAMP WITH TIME ZONE,
    ativo BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Relatórios de Vendas
CREATE TABLE IF NOT EXISTS relatorios_vendas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj) ON DELETE CASCADE,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    data_relatorio DATE NOT NULL,
    vendas_debito DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_credito DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_dinheiro DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_pix DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    vendas_vale DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    total_vendas DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint para garantir apenas um relatório por cliente por dia
    UNIQUE(cliente_cnpj, data_relatorio)
);

-- Tabela de Boletos
CREATE TABLE IF NOT EXISTS boletos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj) ON DELETE CASCADE,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    numero_boleto VARCHAR(50) UNIQUE NOT NULL,
    valor DECIMAL(15,2) NOT NULL CHECK (valor > 0),
    data_vencimento DATE NOT NULL,
    data_pagamento TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pendente' NOT NULL CHECK (status IN ('pendente', 'pago', 'vencido', 'cancelado')),
    linha_digitavel TEXT NOT NULL,
    codigo_barras TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Notificações
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj) ON DELETE CASCADE,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('relatorio', 'boleto', 'inatividade', 'geral')),
    titulo VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    lida BOOLEAN DEFAULT false NOT NULL,
    data_envio TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Chat/Mensagens (para futura implementação)
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj) ON DELETE CASCADE,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    remetente_tipo VARCHAR(20) NOT NULL CHECK (remetente_tipo IN ('cliente', 'empresa')),
    remetente_id UUID,
    conteudo TEXT NOT NULL,
    tipo_conteudo VARCHAR(20) DEFAULT 'texto' CHECK (tipo_conteudo IN ('texto', 'imagem', 'arquivo', 'audio')),
    arquivo_url TEXT,
    lida BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_users_cnpj ON users(cnpj);
CREATE INDEX IF NOT EXISTS idx_users_filial_id ON users(filial_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_ultimo_acesso ON users(ultimo_acesso);

CREATE INDEX IF NOT EXISTS idx_relatorios_cliente_data ON relatorios_vendas(cliente_cnpj, data_relatorio DESC);
CREATE INDEX IF NOT EXISTS idx_relatorios_filial_id ON relatorios_vendas(filial_id);
CREATE INDEX IF NOT EXISTS idx_relatorios_data ON relatorios_vendas(data_relatorio DESC);

CREATE INDEX IF NOT EXISTS idx_boletos_cliente_status ON boletos(cliente_cnpj, status);
CREATE INDEX IF NOT EXISTS idx_boletos_filial_id ON boletos(filial_id);
CREATE INDEX IF NOT EXISTS idx_boletos_vencimento ON boletos(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_boletos_numero ON boletos(numero_boleto);
CREATE INDEX IF NOT EXISTS idx_boletos_status ON boletos(status);

CREATE INDEX IF NOT EXISTS idx_notifications_cliente_lida ON notifications(cliente_cnpj, lida);
CREATE INDEX IF NOT EXISTS idx_notifications_filial_id ON notifications(filial_id);
CREATE INDEX IF NOT EXISTS idx_notifications_data_envio ON notifications(data_envio DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_tipo ON notifications(tipo);

CREATE INDEX IF NOT EXISTS idx_chat_cliente_data ON chat_messages(cliente_cnpj, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_filial_id ON chat_messages(filial_id);

-- Índices de busca textual
CREATE INDEX IF NOT EXISTS idx_users_nome_trgm ON users USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_notifications_titulo_trgm ON notifications USING gin (titulo gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_notifications_mensagem_trgm ON notifications USING gin (mensagem gin_trgm_ops);

-- Triggers para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger nas tabelas necessárias
CREATE TRIGGER update_filiais_updated_at BEFORE UPDATE ON filiais 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_relatorios_updated_at BEFORE UPDATE ON relatorios_vendas 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_boletos_updated_at BEFORE UPDATE ON boletos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para calcular total_vendas automaticamente
CREATE OR REPLACE FUNCTION calculate_total_vendas()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_vendas = NEW.vendas_debito + NEW.vendas_credito + NEW.vendas_dinheiro + NEW.vendas_pix + NEW.vendas_vale;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER calculate_relatorios_total BEFORE INSERT OR UPDATE ON relatorios_vendas 
    FOR EACH ROW EXECUTE FUNCTION calculate_total_vendas();

-- RLS (Row Level Security) para segurança de dados por filial
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE relatorios_vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE boletos ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Políticas RLS (serão configuradas conforme necessário em produção)
-- Exemplo de política para users (desabilitada por padrão)
-- CREATE POLICY users_filial_policy ON users FOR ALL TO authenticated_role 
--     USING (filial_id = current_setting('app.current_filial_id')::uuid);

-- Views úteis para relatórios
CREATE OR REPLACE VIEW v_relatorios_resumo AS
SELECT 
    r.cliente_cnpj,
    u.nome as cliente_nome,
    f.nome as filial_nome,
    DATE_TRUNC('month', r.data_relatorio) as mes,
    SUM(r.total_vendas) as total_mes,
    AVG(r.total_vendas) as media_diaria,
    COUNT(*) as dias_com_vendas
FROM relatorios_vendas r
JOIN users u ON r.cliente_cnpj = u.cnpj
JOIN filiais f ON r.filial_id = f.id
GROUP BY r.cliente_cnpj, u.nome, f.nome, DATE_TRUNC('month', r.data_relatorio);

CREATE OR REPLACE VIEW v_boletos_resumo AS
SELECT 
    b.cliente_cnpj,
    u.nome as cliente_nome,
    f.nome as filial_nome,
    b.status,
    COUNT(*) as quantidade,
    SUM(b.valor) as valor_total
FROM boletos b
JOIN users u ON b.cliente_cnpj = u.cnpj
JOIN filiais f ON b.filial_id = f.id
GROUP BY b.cliente_cnpj, u.nome, f.nome, b.status;

-- Funções úteis
CREATE OR REPLACE FUNCTION get_vendas_periodo(
    p_cliente_cnpj VARCHAR(14),
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
    WHERE cliente_cnpj = p_cliente_cnpj 
    AND data_relatorio BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- Limpar dados antigos (função para uso em cronjobs)
CREATE OR REPLACE FUNCTION cleanup_old_data() RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Remover notificações lidas com mais de 90 dias
    DELETE FROM notifications 
    WHERE lida = true 
    AND created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Comentários nas tabelas para documentação
COMMENT ON TABLE filiais IS 'Tabela de filiais/unidades da empresa (matriz e filiais)';
COMMENT ON TABLE users IS 'Tabela de usuários/clientes do sistema';
COMMENT ON TABLE relatorios_vendas IS 'Tabela de relatórios diários de vendas por cliente';
COMMENT ON TABLE boletos IS 'Tabela de boletos/cobranças dos clientes';
COMMENT ON TABLE notifications IS 'Tabela de notificações enviadas aos clientes';
COMMENT ON TABLE chat_messages IS 'Tabela de mensagens do chat entre empresa e clientes';

-- Inserir dados de exemplo para desenvolvimento (opcional)
-- Descomente as linhas abaixo apenas em ambiente de desenvolvimento

/*
-- Usuário de exemplo
INSERT INTO users (cnpj, nome, email, telefone, senha, filial_id) VALUES 
('12345678901234', 'Cliente Exemplo', 'cliente@exemplo.com', '11999999999', 
 '$2a$12$example_hashed_password', '11111111-1111-1111-1111-111111111111')
ON CONFLICT (cnpj) DO NOTHING;

-- Relatório de exemplo
INSERT INTO relatorios_vendas (cliente_cnpj, filial_id, data_relatorio, vendas_debito, vendas_credito, vendas_dinheiro, vendas_pix, vendas_vale) VALUES 
('12345678901234', '11111111-1111-1111-1111-111111111111', CURRENT_DATE, 500.00, 300.00, 200.00, 150.00, 50.00)
ON CONFLICT (cliente_cnpj, data_relatorio) DO NOTHING;
*/

-- Configurações finais
ANALYZE;

-- Log de criação do schema
DO $$
BEGIN
    RAISE NOTICE 'Schema DNOTAS API criado com sucesso em %', CURRENT_TIMESTAMP;
END $$;