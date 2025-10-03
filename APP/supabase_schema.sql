-- ESQUEMAS SQL PARA SUPABASE
-- Execute estes comandos no SQL Editor do Supabase

-- 1. Tabela de Filiais (Matriz e Filiais)
CREATE TABLE IF NOT EXISTS filiais (
    id VARCHAR(50) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir filiais padrão
INSERT INTO filiais (id, nome) VALUES 
('matriz', 'Matriz'),
('filial_1', 'Filial 1'),
('filial_2', 'Filial 2')
ON CONFLICT (id) DO NOTHING;

-- 2. Tabela de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    nome_empresa VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(15),
    filial_id VARCHAR(50) NOT NULL REFERENCES filiais(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_clientes_cnpj ON clientes(cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_filial ON clientes(filial_id);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);

-- 3. Tabela de Mensagens (Chat)
CREATE TABLE IF NOT EXISTS mensagens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    remetente VARCHAR(50) NOT NULL CHECK (remetente IN ('cliente', 'empresa')),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('texto', 'imagem', 'pdf', 'notificacao')),
    conteudo TEXT NOT NULL,
    arquivo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lida BOOLEAN DEFAULT false
);

-- Índices para mensagens
CREATE INDEX IF NOT EXISTS idx_mensagens_cliente ON mensagens(cliente_id);
CREATE INDEX IF NOT EXISTS idx_mensagens_data ON mensagens(created_at DESC);

-- 4. Tabela de Solicitações de NF
CREATE TABLE IF NOT EXISTS solicitacoes_nf (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('NFE', 'NFCE')),
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'processando', 'concluido', 'cancelado')),
    dados_solicitacao JSONB NOT NULL,
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para solicitações
CREATE INDEX IF NOT EXISTS idx_solicitacoes_cliente ON solicitacoes_nf(cliente_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_status ON solicitacoes_nf(status);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_data ON solicitacoes_nf(created_at DESC);

-- 5. Tabela de Documentos/Arquivos
CREATE TABLE IF NOT EXISTS documentos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('relatorio', 'nota_fiscal', 'boleto', 'comprovante')),
    nome_arquivo VARCHAR(255) NOT NULL,
    arquivo_url TEXT NOT NULL,
    tamanho_bytes BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para documentos
CREATE INDEX IF NOT EXISTS idx_documentos_cliente ON documentos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos(tipo);

-- 6. Tabela de Notificações
CREATE TABLE IF NOT EXISTS notificacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    titulo VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    lida BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para notificações
CREATE INDEX IF NOT EXISTS idx_notificacoes_cliente ON notificacoes(cliente_id);
CREATE INDEX IF NOT EXISTS idx_notificacoes_lida ON notificacoes(lida);

-- 7. Tabela de Inatividade (Para controle PARTE 5)
CREATE TABLE IF NOT EXISTS logs_atividade (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo_atividade VARCHAR(50) NOT NULL,
    detalhes JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para logs de atividade
CREATE INDEX IF NOT EXISTS idx_logs_cliente ON logs_atividade(cliente_id);
CREATE INDEX IF NOT EXISTS idx_logs_data ON logs_atividade(created_at DESC);

-- 8. Políticas RLS (Row Level Security)
-- Habilitar RLS nas tabelas
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE solicitacoes_nf ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs_atividade ENABLE ROW LEVEL SECURITY;

-- Políticas para clientes (acesso apenas aos próprios dados)
CREATE POLICY "Clientes podem ver apenas seus dados" ON clientes
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Clientes podem ver apenas suas mensagens" ON mensagens
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes podem ver apenas suas solicitações" ON solicitacoes_nf
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes podem ver apenas seus documentos" ON documentos
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes podem ver apenas suas notificações" ON notificacoes
    FOR ALL USING (cliente_id = auth.uid());

CREATE POLICY "Clientes podem ver apenas seus logs" ON logs_atividade
    FOR ALL USING (cliente_id = auth.uid());

-- 9. Funções úteis
-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at em solicitacoes_nf
CREATE TRIGGER update_solicitacoes_nf_updated_at 
    BEFORE UPDATE ON solicitacoes_nf 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para registrar atividade do usuário
CREATE OR REPLACE FUNCTION registrar_atividade(
    p_cliente_id UUID,
    p_tipo_atividade VARCHAR(50),
    p_detalhes JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO logs_atividade (cliente_id, tipo_atividade, detalhes)
    VALUES (p_cliente_id, p_tipo_atividade, p_detalhes);
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar login automático
CREATE OR REPLACE FUNCTION trigger_registrar_login()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.last_login IS DISTINCT FROM OLD.last_login THEN
        PERFORM registrar_atividade(NEW.id, 'login', '{"timestamp": "' || NEW.last_login || '"}');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registrar_login_trigger
    AFTER UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION trigger_registrar_login();

-- View para relatório de inatividade
CREATE OR REPLACE VIEW vw_inatividade_clientes AS
SELECT 
    c.id,
    c.cnpj,
    c.nome_empresa,
    c.email,
    c.filial_id,
    c.last_login,
    CASE 
        WHEN c.last_login IS NULL THEN EXTRACT(DAYS FROM (NOW() - c.created_at))
        ELSE EXTRACT(DAYS FROM (NOW() - c.last_login))
    END as dias_inativo
FROM clientes c
WHERE c.is_active = true
ORDER BY dias_inativo DESC;