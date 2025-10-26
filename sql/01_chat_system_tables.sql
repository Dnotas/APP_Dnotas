-- ====================================
-- SISTEMA DE CHAT DE SUPORTE - DNOTAS
-- ====================================
-- Script para criar estrutura completa do sistema de chat
-- Site: Funcionários atendem e gerenciam conversas
-- App: Clientes iniciam e participam das conversas

-- Remover tabela antiga se existir
DROP TABLE IF EXISTS chat_messages CASCADE;

-- 1. TABELA DE CONVERSAS
-- Cada conversa representa um ticket de suporte entre cliente e empresa
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj) ON DELETE CASCADE,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    
    -- Informações da conversa
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    status VARCHAR(20) DEFAULT 'aberto' NOT NULL CHECK (status IN ('aberto', 'em_atendimento', 'aguardando_cliente', 'finalizado')),
    prioridade VARCHAR(10) DEFAULT 'normal' NOT NULL CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    
    -- Atendimento
    atendente_id UUID, -- ID do funcionário que está atendendo
    atendente_nome VARCHAR(100), -- Nome do atendente para histórico
    data_inicio TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_ultimo_atendimento TIMESTAMP WITH TIME ZONE,
    data_finalizacao TIMESTAMP WITH TIME ZONE,
    
    -- Controle de mensagens
    ultima_mensagem_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    mensagens_nao_lidas_cliente INTEGER DEFAULT 0,
    mensagens_nao_lidas_atendente INTEGER DEFAULT 0,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA DE MENSAGENS
-- Armazena todas as mensagens trocadas na conversa
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversa_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    
    -- Remetente (cliente ou funcionário)
    remetente_tipo VARCHAR(20) NOT NULL CHECK (remetente_tipo IN ('cliente', 'funcionario', 'sistema')),
    remetente_id VARCHAR(50), -- CNPJ do cliente ou ID do funcionário
    remetente_nome VARCHAR(100) NOT NULL,
    
    -- Conteúdo da mensagem
    conteudo TEXT NOT NULL,
    tipo_conteudo VARCHAR(20) DEFAULT 'texto' CHECK (tipo_conteudo IN ('texto', 'imagem', 'arquivo', 'link', 'audio')),
    
    -- Arquivos anexos
    arquivo_nome VARCHAR(255),
    arquivo_url TEXT,
    arquivo_tamanho INTEGER,
    arquivo_tipo VARCHAR(100),
    
    -- Controle de leitura
    lida_cliente BOOLEAN DEFAULT false,
    lida_atendente BOOLEAN DEFAULT false,
    data_leitura_cliente TIMESTAMP WITH TIME ZONE,
    data_leitura_atendente TIMESTAMP WITH TIME ZONE,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABELA DE FUNCIONÁRIOS (ATENDENTES)
-- Funcionários que podem atender conversas de chat
CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    
    -- Configurações de atendimento
    ativo BOOLEAN DEFAULT true,
    atendimento_ativo BOOLEAN DEFAULT false, -- Se está online para atender
    max_conversas_simultaneas INTEGER DEFAULT 5,
    conversas_ativas INTEGER DEFAULT 0,
    
    -- Notificações
    fcm_token TEXT,
    notificacoes_email BOOLEAN DEFAULT true,
    notificacoes_push BOOLEAN DEFAULT true,
    
    -- Estatísticas
    total_conversas_atendidas INTEGER DEFAULT 0,
    nota_avaliacao DECIMAL(3,2) DEFAULT 0.00,
    ultimo_acesso TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABELA DE TEMPLATES DE MENSAGENS
-- Mensagens prontas para agilizar o atendimento
CREATE TABLE IF NOT EXISTS chat_templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    filial_id UUID NOT NULL REFERENCES filiais(id),
    funcionario_id UUID REFERENCES funcionarios(id), -- NULL = template global da filial
    
    titulo VARCHAR(100) NOT NULL,
    conteudo TEXT NOT NULL,
    categoria VARCHAR(50), -- ex: 'saudacao', 'despedida', 'nfe', 'boletos'
    ativo BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABELA DE AVALIAÇÕES DE ATENDIMENTO
CREATE TABLE IF NOT EXISTS chat_avaliacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversa_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    cliente_cnpj VARCHAR(14) NOT NULL REFERENCES users(cnpj),
    funcionario_id UUID REFERENCES funcionarios(id),
    
    nota INTEGER NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================
-- ÍNDICES PARA PERFORMANCE
-- ====================================

-- Conversas
CREATE INDEX IF NOT EXISTS idx_conversations_cliente_status ON chat_conversations(cliente_cnpj, status);
CREATE INDEX IF NOT EXISTS idx_conversations_filial_status ON chat_conversations(filial_id, status);
CREATE INDEX IF NOT EXISTS idx_conversations_atendente ON chat_conversations(atendente_id);
CREATE INDEX IF NOT EXISTS idx_conversations_ultima_mensagem ON chat_conversations(ultima_mensagem_em DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON chat_conversations(created_at DESC);

-- Mensagens
CREATE INDEX IF NOT EXISTS idx_messages_conversa_data ON chat_messages(conversa_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_remetente ON chat_messages(remetente_tipo, remetente_id);
CREATE INDEX IF NOT EXISTS idx_messages_lida_cliente ON chat_messages(lida_cliente);
CREATE INDEX IF NOT EXISTS idx_messages_lida_atendente ON chat_messages(lida_atendente);

-- Funcionários
CREATE INDEX IF NOT EXISTS idx_funcionarios_filial_ativo ON funcionarios(filial_id, ativo);
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_atendimento_ativo ON funcionarios(atendimento_ativo);

-- Templates
CREATE INDEX IF NOT EXISTS idx_templates_filial_categoria ON chat_templates(filial_id, categoria);
CREATE INDEX IF NOT EXISTS idx_templates_funcionario ON chat_templates(funcionario_id);

-- ====================================
-- TRIGGERS E FUNÇÕES
-- ====================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON chat_conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para atualizar contadores de mensagens não lidas
CREATE OR REPLACE FUNCTION update_conversation_counters()
RETURNS TRIGGER AS $$
BEGIN
    -- Se é uma nova mensagem
    IF TG_OP = 'INSERT' THEN
        -- Atualizar data da última mensagem
        UPDATE chat_conversations 
        SET ultima_mensagem_em = NEW.created_at
        WHERE id = NEW.conversa_id;
        
        -- Incrementar contador baseado no remetente
        IF NEW.remetente_tipo = 'cliente' THEN
            UPDATE chat_conversations 
            SET mensagens_nao_lidas_atendente = mensagens_nao_lidas_atendente + 1
            WHERE id = NEW.conversa_id;
        ELSIF NEW.remetente_tipo = 'funcionario' THEN
            UPDATE chat_conversations 
            SET mensagens_nao_lidas_cliente = mensagens_nao_lidas_cliente + 1
            WHERE id = NEW.conversa_id;
        END IF;
    END IF;
    
    -- Se mensagem foi lida
    IF TG_OP = 'UPDATE' THEN
        -- Cliente leu mensagem do funcionário
        IF OLD.lida_cliente = false AND NEW.lida_cliente = true THEN
            UPDATE chat_conversations 
            SET mensagens_nao_lidas_cliente = GREATEST(mensagens_nao_lidas_cliente - 1, 0)
            WHERE id = NEW.conversa_id;
        END IF;
        
        -- Funcionário leu mensagem do cliente
        IF OLD.lida_atendente = false AND NEW.lida_atendente = true THEN
            UPDATE chat_conversations 
            SET mensagens_nao_lidas_atendente = GREATEST(mensagens_nao_lidas_atendente - 1, 0)
            WHERE id = NEW.conversa_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger para contadores
CREATE TRIGGER update_conversation_counters_trigger
    AFTER INSERT OR UPDATE ON chat_messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_counters();

-- ====================================
-- RLS (ROW LEVEL SECURITY)
-- ====================================

ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_avaliacoes ENABLE ROW LEVEL SECURITY;

-- ====================================
-- VIEWS ÚTEIS
-- ====================================

-- View de conversas com informações do cliente
CREATE OR REPLACE VIEW v_chat_conversations_full AS
SELECT 
    c.id,
    c.cliente_cnpj,
    u.nome as cliente_nome,
    u.email as cliente_email,
    u.telefone as cliente_telefone,
    c.filial_id,
    f.nome as filial_nome,
    c.titulo,
    c.descricao,
    c.status,
    c.prioridade,
    c.atendente_id,
    c.atendente_nome,
    c.data_inicio,
    c.data_ultimo_atendimento,
    c.data_finalizacao,
    c.ultima_mensagem_em,
    c.mensagens_nao_lidas_cliente,
    c.mensagens_nao_lidas_atendente,
    c.created_at,
    c.updated_at,
    -- Última mensagem
    (SELECT conteudo FROM chat_messages WHERE conversa_id = c.id ORDER BY created_at DESC LIMIT 1) as ultima_mensagem,
    -- Total de mensagens
    (SELECT COUNT(*) FROM chat_messages WHERE conversa_id = c.id) as total_mensagens
FROM chat_conversations c
JOIN users u ON c.cliente_cnpj = u.cnpj
JOIN filiais f ON c.filial_id = f.id;

-- View de estatísticas de atendimento
CREATE OR REPLACE VIEW v_chat_stats AS
SELECT 
    f.id as filial_id,
    f.nome as filial_nome,
    COUNT(c.id) as total_conversas,
    COUNT(CASE WHEN c.status = 'aberto' THEN 1 END) as conversas_abertas,
    COUNT(CASE WHEN c.status = 'em_atendimento' THEN 1 END) as conversas_em_atendimento,
    COUNT(CASE WHEN c.status = 'finalizado' THEN 1 END) as conversas_finalizadas,
    AVG(CASE WHEN c.data_finalizacao IS NOT NULL THEN 
        EXTRACT(EPOCH FROM (c.data_finalizacao - c.data_inicio))/3600 
    END) as tempo_medio_resolucao_horas,
    COUNT(DISTINCT c.atendente_id) as atendentes_ativos
FROM filiais f
LEFT JOIN chat_conversations c ON f.id = c.filial_id 
    AND c.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY f.id, f.nome;

-- ====================================
-- DADOS INICIAIS
-- ====================================

-- Inserir funcionário admin para cada filial
INSERT INTO funcionarios (id, nome, email, senha, filial_id, ativo, atendimento_ativo) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'Admin Matriz', 
    'admin@matriz.dnotas.com', 
    '$2a$12$example_hashed_password', 
    '11111111-1111-1111-1111-111111111111',
    true,
    true
),
(
    '88888888-8888-8888-8888-888888888888', 
    'Admin Filial 1', 
    'admin@filial1.dnotas.com', 
    '$2a$12$example_hashed_password', 
    '22222222-2222-2222-2222-222222222222',
    true,
    true
),
(
    '77777777-7777-7777-7777-777777777777', 
    'Admin Filial 2', 
    'admin@filial2.dnotas.com', 
    '$2a$12$example_hashed_password', 
    '33333333-3333-3333-3333-333333333333',
    true,
    true
)
ON CONFLICT (email) DO NOTHING;

-- Templates básicos por filial
INSERT INTO chat_templates (filial_id, titulo, conteudo, categoria) VALUES 
-- Matriz
('11111111-1111-1111-1111-111111111111', 'Saudação Inicial', 'Olá! Sou da equipe de suporte da DNOTAS. Como posso ajudá-lo hoje?', 'saudacao'),
('11111111-1111-1111-1111-111111111111', 'Aguardar Documentos', 'Por favor, envie os documentos necessários para que possamos prosseguir com sua solicitação.', 'documentos'),
('11111111-1111-1111-1111-111111111111', 'Finalização', 'Sua solicitação foi concluída! Se precisar de mais alguma coisa, não hesite em entrar em contato.', 'despedida'),

-- Filial 1
('22222222-2222-2222-2222-222222222222', 'Saudação Inicial', 'Olá! Sou da equipe de suporte da DNOTAS Filial 1. Como posso ajudá-lo hoje?', 'saudacao'),
('22222222-2222-2222-2222-222222222222', 'Aguardar Documentos', 'Por favor, envie os documentos necessários para que possamos prosseguir com sua solicitação.', 'documentos'),
('22222222-2222-2222-2222-222222222222', 'Finalização', 'Sua solicitação foi concluída! Se precisar de mais alguma coisa, não hesite em entrar em contato.', 'despedida'),

-- Filial 2
('33333333-3333-3333-3333-333333333333', 'Saudação Inicial', 'Olá! Sou da equipe de suporte da DNOTAS Filial 2. Como posso ajudá-lo hoje?', 'saudacao'),
('33333333-3333-3333-3333-333333333333', 'Aguardar Documentos', 'Por favor, envie os documentos necessários para que possamos prosseguir com sua solicitação.', 'documentos'),
('33333333-3333-3333-3333-333333333333', 'Finalização', 'Sua solicitação foi concluída! Se precisar de mais alguma coisa, não hesite em entrar em contato.', 'despedida');

-- ====================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- ====================================

COMMENT ON TABLE chat_conversations IS 'Conversas de suporte entre clientes e funcionários';
COMMENT ON TABLE chat_messages IS 'Mensagens trocadas nas conversas de suporte';
COMMENT ON TABLE funcionarios IS 'Funcionários que atendem o chat de suporte';
COMMENT ON TABLE chat_templates IS 'Templates de mensagens para agilizar atendimento';
COMMENT ON TABLE chat_avaliacoes IS 'Avaliações dos atendimentos realizados';

-- Log de criação
DO $$
BEGIN
    RAISE NOTICE 'Sistema de Chat de Suporte criado com sucesso em %', CURRENT_TIMESTAMP;
END $$;