-- ====================================
-- CORREÇÃO DA FUNÇÃO ADD_ASAAS_KEY
-- ====================================
-- Corrige a função para usar apenas a tabela filiais

-- Remover função antiga
DROP FUNCTION IF EXISTS add_asaas_key(UUID, VARCHAR, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS get_active_asaas_keys(UUID);
DROP FUNCTION IF EXISTS deactivate_asaas_key(UUID, UUID);

-- Função corrigida para adicionar nova chave Asaas
CREATE OR REPLACE FUNCTION add_asaas_key(
    p_filial_id UUID,
    p_nome_conta VARCHAR(100),
    p_api_key TEXT,
    p_ativo BOOLEAN DEFAULT true
) RETURNS JSONB AS $$
DECLARE
    nova_chave JSONB;
BEGIN
    -- Criar objeto JSON da nova chave
    nova_chave := jsonb_build_object(
        'id', uuid_generate_v4(),
        'nome', p_nome_conta,
        'key', p_api_key,
        'ativo', p_ativo,
        'criado_em', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
    );
    
    -- Adicionar chave ao array existente na tabela filiais
    UPDATE filiais 
    SET asaas_keys = COALESCE(asaas_keys, '[]'::jsonb) || nova_chave
    WHERE id = p_filial_id;
    
    -- Verificar se a filial existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Filial com ID % não encontrada', p_filial_id;
    END IF;
    
    RETURN nova_chave;
END;
$$ LANGUAGE plpgsql;

-- Função corrigida para listar chaves ativas
CREATE OR REPLACE FUNCTION get_active_asaas_keys(p_filial_id UUID) 
RETURNS TABLE(
    key_id UUID,
    nome VARCHAR(100),
    api_key TEXT,
    ativo BOOLEAN,
    criado_em TIMESTAMP
) AS $$
DECLARE
    chaves_json JSONB;
    chave JSONB;
BEGIN
    -- Buscar chaves da filial
    SELECT asaas_keys INTO chaves_json FROM filiais WHERE id = p_filial_id;
    
    -- Se não tem chaves, retorna vazio
    IF chaves_json IS NULL OR jsonb_array_length(chaves_json) = 0 THEN
        RETURN;
    END IF;
    
    -- Iterar pelas chaves e retornar apenas as ativas
    FOR chave IN SELECT * FROM jsonb_array_elements(chaves_json)
    LOOP
        IF (chave->>'ativo')::boolean = true THEN
            key_id := (chave->>'id')::UUID;
            nome := chave->>'nome';
            api_key := chave->>'key';
            ativo := (chave->>'ativo')::boolean;
            criado_em := (chave->>'criado_em')::timestamp;
            RETURN NEXT;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Função corrigida para desativar chave
CREATE OR REPLACE FUNCTION deactivate_asaas_key(
    p_filial_id UUID,
    p_key_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    -- Atualizar o status da chave para inativo
    UPDATE filiais 
    SET asaas_keys = (
        SELECT jsonb_agg(
            CASE 
                WHEN (elem->>'id')::UUID = p_key_id THEN 
                    jsonb_set(elem, '{ativo}', 'false'::jsonb)
                ELSE elem 
            END
        )
        FROM jsonb_array_elements(asaas_keys) elem
    )
    WHERE id = p_filial_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Comentários atualizados
COMMENT ON FUNCTION add_asaas_key IS 'Adiciona nova chave API do Asaas para uma filial/organização. Permite múltiplas chaves por filial.';
COMMENT ON FUNCTION get_active_asaas_keys IS 'Retorna todas as chaves ativas do Asaas para uma filial específica.';
COMMENT ON FUNCTION deactivate_asaas_key IS 'Desativa uma chave específica do Asaas sem removê-la do banco (soft delete).';

-- Log de correção
DO $$
BEGIN
    RAISE NOTICE 'Funções Asaas corrigidas para usar tabela filiais em %', CURRENT_TIMESTAMP;
END $$;