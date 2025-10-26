-- ====================================
-- CORREÇÃO DA FUNÇÃO INICIAR CONVERSA
-- ====================================
-- Função que aceita CNPJ em qualquer formato (com ou sem pontuação)

CREATE OR REPLACE FUNCTION iniciar_conversa_suporte(
    p_cliente_cnpj VARCHAR(14),
    p_titulo VARCHAR(200),
    p_descricao TEXT DEFAULT NULL,
    p_prioridade VARCHAR(10) DEFAULT 'normal'
) RETURNS UUID AS $$
DECLARE
    v_filial_id VARCHAR;
    v_cliente_id UUID;
    v_conversa_id UUID;
    v_cnpj_limpo VARCHAR(14);
BEGIN
    -- Limpar CNPJ removendo pontos, traços e barras
    v_cnpj_limpo := REGEXP_REPLACE(p_cliente_cnpj, '[^0-9]', '', 'g');
    
    -- Debug: mostrar o CNPJ que está sendo usado
    RAISE NOTICE 'CNPJ recebido: %, CNPJ limpo: %', p_cliente_cnpj, v_cnpj_limpo;
    
    -- Buscar filial e ID do cliente usando CNPJ limpo
    SELECT filial_id, id INTO v_filial_id, v_cliente_id
    FROM clientes 
    WHERE cnpj = v_cnpj_limpo AND is_active = true;
    
    -- Se não encontrou, tentar buscar com o CNPJ original
    IF v_filial_id IS NULL THEN
        RAISE NOTICE 'Não encontrou com CNPJ limpo, tentando original';
        SELECT filial_id, id INTO v_filial_id, v_cliente_id
        FROM clientes 
        WHERE cnpj = p_cliente_cnpj AND is_active = true;
    END IF;
    
    -- Se ainda não encontrou, tentar buscar com LIKE
    IF v_filial_id IS NULL THEN
        RAISE NOTICE 'Não encontrou com CNPJ original, tentando LIKE';
        SELECT filial_id, id INTO v_filial_id, v_cliente_id
        FROM clientes 
        WHERE cnpj LIKE '%' || v_cnpj_limpo || '%' AND is_active = true;
    END IF;
    
    IF v_filial_id IS NULL THEN
        RAISE EXCEPTION 'Cliente não encontrado ou inativo: % (limpo: %)', p_cliente_cnpj, v_cnpj_limpo;
    END IF;
    
    RAISE NOTICE 'Cliente encontrado: filial=%, id=%', v_filial_id, v_cliente_id;
    
    -- Criar nova conversa
    INSERT INTO chat_conversations (
        cliente_cnpj,
        cliente_id,
        filial_id, 
        titulo, 
        descricao, 
        prioridade,
        status
    ) VALUES (
        v_cnpj_limpo,  -- Usar CNPJ limpo para consistência
        v_cliente_id,
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
    
    RAISE NOTICE 'Conversa criada com sucesso: %', v_conversa_id;
    
    RETURN v_conversa_id;
END;
$$ LANGUAGE plpgsql;