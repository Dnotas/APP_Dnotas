-- ====================================
-- CORREÇÃO DE FUNÇÕES DO SISTEMA DE CHAT
-- ====================================
-- Correção para resolver ambiguidade de colunas created_at

-- 6. FUNÇÃO PARA BUSCAR CONVERSAS (SITE - FUNCIONÁRIOS) - CORRIGIDA
CREATE OR REPLACE FUNCTION buscar_conversas_atendimento(
    p_filial_id VARCHAR,
    p_funcionario_id VARCHAR DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    cliente_cnpj VARCHAR(14),
    cliente_nome VARCHAR(100),
    titulo VARCHAR(200),
    status VARCHAR(20),
    prioridade VARCHAR(10),
    atendente_nome VARCHAR(100),
    ultima_mensagem_em TIMESTAMP WITH TIME ZONE,
    mensagens_nao_lidas INTEGER,
    ultima_mensagem TEXT,
    total_mensagens BIGINT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.cliente_cnpj,
        cl.nome_empresa as cliente_nome,
        c.titulo,
        c.status,
        c.prioridade,
        c.atendente_nome,
        c.ultima_mensagem_em,
        c.mensagens_nao_lidas_atendente as mensagens_nao_lidas,
        (SELECT m.conteudo FROM chat_messages m WHERE m.conversa_id = c.id ORDER BY m.created_at DESC LIMIT 1) as ultima_mensagem,
        (SELECT COUNT(*) FROM chat_messages WHERE conversa_id = c.id) as total_mensagens,
        c.created_at
    FROM chat_conversations c
    JOIN clientes cl ON c.cliente_cnpj = cl.cnpj
    WHERE c.filial_id = p_filial_id
    AND (p_funcionario_id IS NULL OR c.atendente_id = p_funcionario_id OR c.atendente_id IS NULL)
    AND (p_status IS NULL OR c.status = p_status)
    ORDER BY 
        CASE WHEN c.status = 'aberto' THEN 1 
             WHEN c.status = 'em_atendimento' THEN 2 
             ELSE 3 END,
        CASE WHEN c.prioridade = 'urgente' THEN 1
             WHEN c.prioridade = 'alta' THEN 2
             WHEN c.prioridade = 'normal' THEN 3
             ELSE 4 END,
        c.ultima_mensagem_em DESC
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- 7. FUNÇÃO PARA BUSCAR CONVERSAS DO CLIENTE (APP) - CORRIGIDA
CREATE OR REPLACE FUNCTION buscar_conversas_cliente(
    p_cliente_cnpj VARCHAR(14),
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    titulo VARCHAR(200),
    status VARCHAR(20),
    prioridade VARCHAR(10),
    atendente_nome VARCHAR(100),
    ultima_mensagem_em TIMESTAMP WITH TIME ZONE,
    mensagens_nao_lidas INTEGER,
    ultima_mensagem TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.titulo,
        c.status,
        c.prioridade,
        c.atendente_nome,
        c.ultima_mensagem_em,
        c.mensagens_nao_lidas_cliente as mensagens_nao_lidas,
        (SELECT m.conteudo FROM chat_messages m WHERE m.conversa_id = c.id ORDER BY m.created_at DESC LIMIT 1) as ultima_mensagem,
        c.created_at
    FROM chat_conversations c
    WHERE c.cliente_cnpj = p_cliente_cnpj
    ORDER BY c.ultima_mensagem_em DESC
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Log de correção
DO $$
BEGIN
    RAISE NOTICE 'Funções do Sistema de Chat corrigidas em %', CURRENT_TIMESTAMP;
END $$;