-- ====================================
-- FUNÇÕES ESPECÍFICAS DO SISTEMA DE CHAT
-- ====================================

-- 1. FUNÇÃO PARA INICIAR NOVA CONVERSA (CLIENT-SIDE)
CREATE OR REPLACE FUNCTION iniciar_conversa_suporte(
    p_cliente_cnpj VARCHAR(14),
    p_titulo VARCHAR(200),
    p_descricao TEXT DEFAULT NULL,
    p_prioridade VARCHAR(10) DEFAULT 'normal'
) RETURNS UUID AS $$
DECLARE
    v_filial_id UUID;
    v_conversa_id UUID;
BEGIN
    -- Buscar filial do cliente
    SELECT filial_id INTO v_filial_id 
    FROM users 
    WHERE cnpj = p_cliente_cnpj AND ativo = true;
    
    IF v_filial_id IS NULL THEN
        RAISE EXCEPTION 'Cliente não encontrado ou inativo: %', p_cliente_cnpj;
    END IF;
    
    -- Criar nova conversa
    INSERT INTO chat_conversations (
        cliente_cnpj, 
        filial_id, 
        titulo, 
        descricao, 
        prioridade,
        status
    ) VALUES (
        p_cliente_cnpj,
        v_filial_id,
        p_titulo,
        p_descricao,
        p_prioridade,
        'aberto'
    ) RETURNING id INTO v_conversa_id;
    
    -- Criar mensagem inicial do sistema
    INSERT INTO chat_messages (
        conversa_id,
        remetente_tipo,
        remetente_id,
        remetente_nome,
        conteudo,
        tipo_conteudo
    ) VALUES (
        v_conversa_id,
        'sistema',
        'system',
        'Sistema DNOTAS',
        'Conversa iniciada. Em breve um de nossos atendentes irá responder.',
        'texto'
    );
    
    RETURN v_conversa_id;
END;
$$ LANGUAGE plpgsql;

-- 2. FUNÇÃO PARA ENVIAR MENSAGEM
CREATE OR REPLACE FUNCTION enviar_mensagem_chat(
    p_conversa_id UUID,
    p_remetente_tipo VARCHAR(20),
    p_remetente_id VARCHAR(50),
    p_remetente_nome VARCHAR(100),
    p_conteudo TEXT,
    p_tipo_conteudo VARCHAR(20) DEFAULT 'texto',
    p_arquivo_nome VARCHAR(255) DEFAULT NULL,
    p_arquivo_url TEXT DEFAULT NULL,
    p_arquivo_tamanho INTEGER DEFAULT NULL,
    p_arquivo_tipo VARCHAR(100) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_mensagem_id UUID;
BEGIN
    -- Inserir mensagem
    INSERT INTO chat_messages (
        conversa_id,
        remetente_tipo,
        remetente_id,
        remetente_nome,
        conteudo,
        tipo_conteudo,
        arquivo_nome,
        arquivo_url,
        arquivo_tamanho,
        arquivo_tipo,
        lida_cliente,
        lida_atendente
    ) VALUES (
        p_conversa_id,
        p_remetente_tipo,
        p_remetente_id,
        p_remetente_nome,
        p_conteudo,
        p_tipo_conteudo,
        p_arquivo_nome,
        p_arquivo_url,
        p_arquivo_tamanho,
        p_arquivo_tipo,
        CASE WHEN p_remetente_tipo = 'cliente' THEN true ELSE false END,
        CASE WHEN p_remetente_tipo = 'funcionario' THEN true ELSE false END
    ) RETURNING id INTO v_mensagem_id;
    
    -- Se funcionário enviou, atualizar status da conversa para "em_atendimento"
    IF p_remetente_tipo = 'funcionario' THEN
        UPDATE chat_conversations 
        SET 
            status = CASE WHEN status = 'aberto' THEN 'em_atendimento' ELSE status END,
            data_ultimo_atendimento = CURRENT_TIMESTAMP,
            atendente_id = CASE WHEN atendente_id IS NULL THEN p_remetente_id::UUID ELSE atendente_id END,
            atendente_nome = CASE WHEN atendente_nome IS NULL THEN p_remetente_nome ELSE atendente_nome END
        WHERE id = p_conversa_id;
    END IF;
    
    RETURN v_mensagem_id;
END;
$$ LANGUAGE plpgsql;

-- 3. FUNÇÃO PARA MARCAR MENSAGENS COMO LIDAS
CREATE OR REPLACE FUNCTION marcar_mensagens_lidas(
    p_conversa_id UUID,
    p_tipo_usuario VARCHAR(20) -- 'cliente' ou 'funcionario'
) RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_tipo_usuario = 'cliente' THEN
        UPDATE chat_messages 
        SET 
            lida_cliente = true,
            data_leitura_cliente = CURRENT_TIMESTAMP
        WHERE conversa_id = p_conversa_id 
        AND lida_cliente = false 
        AND remetente_tipo != 'cliente';
        
        GET DIAGNOSTICS v_count = ROW_COUNT;
        
    ELSIF p_tipo_usuario = 'funcionario' THEN
        UPDATE chat_messages 
        SET 
            lida_atendente = true,
            data_leitura_atendente = CURRENT_TIMESTAMP
        WHERE conversa_id = p_conversa_id 
        AND lida_atendente = false 
        AND remetente_tipo = 'cliente';
        
        GET DIAGNOSTICS v_count = ROW_COUNT;
    END IF;
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- 4. FUNÇÃO PARA ASSUMIR ATENDIMENTO
CREATE OR REPLACE FUNCTION assumir_atendimento(
    p_conversa_id UUID,
    p_funcionario_id UUID,
    p_funcionario_nome VARCHAR(100)
) RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar se conversa está disponível
    IF EXISTS (
        SELECT 1 FROM chat_conversations 
        WHERE id = p_conversa_id 
        AND status IN ('aberto', 'em_atendimento')
        AND (atendente_id IS NULL OR atendente_id = p_funcionario_id)
    ) THEN
        -- Assumir atendimento
        UPDATE chat_conversations 
        SET 
            atendente_id = p_funcionario_id,
            atendente_nome = p_funcionario_nome,
            status = 'em_atendimento',
            data_ultimo_atendimento = CURRENT_TIMESTAMP
        WHERE id = p_conversa_id;
        
        -- Incrementar contador do funcionário
        UPDATE funcionarios 
        SET conversas_ativas = conversas_ativas + 1
        WHERE id = p_funcionario_id;
        
        -- Mensagem do sistema
        INSERT INTO chat_messages (
            conversa_id,
            remetente_tipo,
            remetente_id,
            remetente_nome,
            conteudo,
            tipo_conteudo,
            lida_cliente,
            lida_atendente
        ) VALUES (
            p_conversa_id,
            'sistema',
            'system',
            'Sistema DNOTAS',
            p_funcionario_nome || ' assumiu o atendimento desta conversa.',
            'texto',
            false,
            true
        );
        
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- 5. FUNÇÃO PARA FINALIZAR CONVERSA
CREATE OR REPLACE FUNCTION finalizar_conversa(
    p_conversa_id UUID,
    p_funcionario_id UUID,
    p_mensagem_final TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar se funcionário pode finalizar
    IF EXISTS (
        SELECT 1 FROM chat_conversations 
        WHERE id = p_conversa_id 
        AND atendente_id = p_funcionario_id
        AND status != 'finalizado'
    ) THEN
        -- Finalizar conversa
        UPDATE chat_conversations 
        SET 
            status = 'finalizado',
            data_finalizacao = CURRENT_TIMESTAMP
        WHERE id = p_conversa_id;
        
        -- Decrementar contador do funcionário
        UPDATE funcionarios 
        SET 
            conversas_ativas = GREATEST(conversas_ativas - 1, 0),
            total_conversas_atendidas = total_conversas_atendidas + 1
        WHERE id = p_funcionario_id;
        
        -- Mensagem de finalização se fornecida
        IF p_mensagem_final IS NOT NULL THEN
            INSERT INTO chat_messages (
                conversa_id,
                remetente_tipo,
                remetente_id,
                remetente_nome,
                conteudo,
                tipo_conteudo,
                lida_cliente,
                lida_atendente
            ) VALUES (
                p_conversa_id,
                'sistema',
                'system',
                'Sistema DNOTAS',
                p_mensagem_final,
                'texto',
                false,
                true
            );
        END IF;
        
        -- Mensagem do sistema
        INSERT INTO chat_messages (
            conversa_id,
            remetente_tipo,
            remetente_id,
            remetente_nome,
            conteudo,
            tipo_conteudo,
            lida_cliente,
            lida_atendente
        ) VALUES (
            p_conversa_id,
            'sistema',
            'system',
            'Sistema DNOTAS',
            'Conversa finalizada pelo atendente.',
            'texto',
            false,
            true
        );
        
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- 6. FUNÇÃO PARA BUSCAR CONVERSAS (SITE - FUNCIONÁRIOS)
CREATE OR REPLACE FUNCTION buscar_conversas_atendimento(
    p_filial_id UUID,
    p_funcionario_id UUID DEFAULT NULL,
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
    total_mensagens BIGINT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.cliente_cnpj,
        u.nome as cliente_nome,
        c.titulo,
        c.status,
        c.prioridade,
        c.atendente_nome,
        c.ultima_mensagem_em,
        c.mensagens_nao_lidas_atendente as mensagens_nao_lidas,
        (SELECT COUNT(*) FROM chat_messages WHERE conversa_id = c.id) as total_mensagens,
        c.created_at
    FROM chat_conversations c
    JOIN users u ON c.cliente_cnpj = u.cnpj
    WHERE c.filial_id = p_filial_id
    AND (p_funcionario_id IS NULL OR c.atendente_id = p_funcionario_id OR c.atendente_id IS NULL)
    AND (p_status IS NULL OR c.status = p_status)
    ORDER BY 
        CASE WHEN c.status = 'aberto' THEN 1 
             WHEN c.status = 'em_atendimento' THEN 2 
             ELSE 3 END,
        c.prioridade DESC,
        c.ultima_mensagem_em DESC
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- 7. FUNÇÃO PARA BUSCAR CONVERSAS DO CLIENTE (APP)
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
        (SELECT conteudo FROM chat_messages WHERE conversa_id = c.id ORDER BY created_at DESC LIMIT 1) as ultima_mensagem,
        c.created_at
    FROM chat_conversations c
    WHERE c.cliente_cnpj = p_cliente_cnpj
    ORDER BY c.ultima_mensagem_em DESC
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- 8. FUNÇÃO PARA OBTER MENSAGENS DE UMA CONVERSA
CREATE OR REPLACE FUNCTION buscar_mensagens_conversa(
    p_conversa_id UUID,
    p_limite INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    remetente_tipo VARCHAR(20),
    remetente_nome VARCHAR(100),
    conteudo TEXT,
    tipo_conteudo VARCHAR(20),
    arquivo_nome VARCHAR(255),
    arquivo_url TEXT,
    arquivo_tamanho INTEGER,
    arquivo_tipo VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.remetente_tipo,
        m.remetente_nome,
        m.conteudo,
        m.tipo_conteudo,
        m.arquivo_nome,
        m.arquivo_url,
        m.arquivo_tamanho,
        m.arquivo_tipo,
        m.created_at
    FROM chat_messages m
    WHERE m.conversa_id = p_conversa_id
    ORDER BY m.created_at ASC
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- 9. FUNÇÃO PARA ESTATÍSTICAS DO FUNCIONÁRIO
CREATE OR REPLACE FUNCTION obter_stats_funcionario(
    p_funcionario_id UUID,
    p_data_inicio DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    p_data_fim DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    conversas_atendidas INTEGER,
    conversas_finalizadas INTEGER,
    tempo_medio_resposta_minutos NUMERIC,
    nota_media_avaliacao NUMERIC,
    conversas_ativas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT c.id)::INTEGER as conversas_atendidas,
        COUNT(DISTINCT CASE WHEN c.status = 'finalizado' THEN c.id END)::INTEGER as conversas_finalizadas,
        COALESCE(AVG(
            EXTRACT(EPOCH FROM (
                SELECT MIN(m.created_at) 
                FROM chat_messages m 
                WHERE m.conversa_id = c.id 
                AND m.remetente_tipo = 'funcionario'
            ) - c.created_at) / 60
        ), 0)::NUMERIC as tempo_medio_resposta_minutos,
        COALESCE(AVG(a.nota), 0)::NUMERIC as nota_media_avaliacao,
        (SELECT conversas_ativas FROM funcionarios WHERE id = p_funcionario_id) as conversas_ativas
    FROM chat_conversations c
    LEFT JOIN chat_avaliacoes a ON c.id = a.conversa_id
    WHERE c.atendente_id = p_funcionario_id
    AND c.created_at::DATE BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- 10. FUNÇÃO PARA LIMPAR CONVERSAS ANTIGAS
CREATE OR REPLACE FUNCTION limpar_conversas_antigas(
    p_dias_apos_finalizacao INTEGER DEFAULT 90
) RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    -- Deletar conversas finalizadas há mais de X dias
    DELETE FROM chat_conversations 
    WHERE status = 'finalizado' 
    AND data_finalizacao < CURRENT_TIMESTAMP - (p_dias_apos_finalizacao || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Log de criação das funções
DO $$
BEGIN
    RAISE NOTICE 'Funções do Sistema de Chat criadas com sucesso em %', CURRENT_TIMESTAMP;
END $$;