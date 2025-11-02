-- ====================================
-- DEBUG E CORREÇÃO DA TABELA FILIAIS
-- ====================================

-- 1. Verificar estrutura da tabela filiais
SELECT 
    'ESTRUTURA FILIAIS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'filiais'
ORDER BY ordinal_position;

-- 2. Verificar se existe a coluna asaas_keys
SELECT 
    'VERIFICAR ASAAS_KEYS' as info,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'filiais' AND column_name = 'asaas_keys';

-- 3. Verificar dados existentes na tabela filiais
SELECT 'DADOS FILIAIS' as info, id, nome, codigo FROM filiais;

-- 4. Verificar o tipo do campo id
SELECT 
    'TIPO DO ID' as info,
    pg_typeof(id) as tipo_id
FROM filiais 
LIMIT 1;

-- 5. Se o campo id for VARCHAR, vamos corrigir a função
DROP FUNCTION IF EXISTS add_asaas_key(UUID, VARCHAR, TEXT, BOOLEAN);

-- Função corrigida considerando que id pode ser VARCHAR
CREATE OR REPLACE FUNCTION add_asaas_key(
    p_filial_id TEXT,  -- Mudando para TEXT para aceitar VARCHAR ou UUID
    p_nome_conta VARCHAR(100),
    p_api_key TEXT,
    p_ativo BOOLEAN DEFAULT true
) RETURNS JSONB AS $$
DECLARE
    nova_chave JSONB;
    rows_affected INTEGER;
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
    WHERE id::text = p_filial_id::text;  -- Cast explícito para TEXT
    
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    
    -- Verificar se a filial existe
    IF rows_affected = 0 THEN
        RAISE EXCEPTION 'Filial com ID % não encontrada', p_filial_id;
    END IF;
    
    RAISE NOTICE 'Chave Asaas % adicionada com sucesso para filial %', p_nome_conta, p_filial_id;
    
    RETURN nova_chave;
END;
$$ LANGUAGE plpgsql;

-- Função corrigida para listar chaves ativas
CREATE OR REPLACE FUNCTION get_active_asaas_keys(p_filial_id TEXT) 
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
    SELECT asaas_keys INTO chaves_json FROM filiais WHERE id::text = p_filial_id::text;
    
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

-- Log de correção
DO $$
BEGIN
    RAISE NOTICE 'Funções Asaas corrigidas para aceitar qualquer tipo de ID em %', CURRENT_TIMESTAMP;
END $$;