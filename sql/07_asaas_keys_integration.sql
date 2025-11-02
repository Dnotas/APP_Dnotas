-- ====================================
-- INTEGRAÇÃO CHAVES ASAAS - DNOTAS
-- ====================================
-- Script para adicionar suporte a múltiplas chaves Asaas por organização
-- Permite que matriz e filiais tenham suas próprias chaves de API do Asaas

-- Verificar se existe tabela organizacoes, senão usar filiais
DO $$
BEGIN
    -- Se existe organizacoes, usar ela; senão usar filiais
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizacoes') THEN
        -- Adicionar campo JSON para múltiplas chaves Asaas na tabela organizacoes
        ALTER TABLE organizacoes 
        ADD COLUMN IF NOT EXISTS asaas_keys JSONB DEFAULT '[]'::jsonb;
        
        -- Adicionar comentário explicativo
        COMMENT ON COLUMN organizacoes.asaas_keys IS 'Array JSON com múltiplas chaves de API do Asaas: [{"nome": "Conta Principal", "key": "api_key_1", "ativo": true}, {"nome": "Conta Secundária", "key": "api_key_2", "ativo": false}]';
        
        -- Criar índice para busca eficiente nas chaves
        CREATE INDEX IF NOT EXISTS idx_organizacoes_asaas_keys ON organizacoes USING gin(asaas_keys);
        
        RAISE NOTICE 'Campo asaas_keys adicionado à tabela organizacoes';
        
    ELSEIF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'filiais') THEN
        -- Adicionar campo JSON para múltiplas chaves Asaas na tabela filiais
        ALTER TABLE filiais 
        ADD COLUMN IF NOT EXISTS asaas_keys JSONB DEFAULT '[]'::jsonb;
        
        -- Adicionar comentário explicativo
        COMMENT ON COLUMN filiais.asaas_keys IS 'Array JSON com múltiplas chaves de API do Asaas: [{"nome": "Conta Principal", "key": "api_key_1", "ativo": true}, {"nome": "Conta Secundária", "key": "api_key_2", "ativo": false}]';
        
        -- Criar índice para busca eficiente nas chaves
        CREATE INDEX IF NOT EXISTS idx_filiais_asaas_keys ON filiais USING gin(asaas_keys);
        
        RAISE NOTICE 'Campo asaas_keys adicionado à tabela filiais';
    ELSE
        RAISE EXCEPTION 'Nenhuma tabela de organizações/filiais encontrada';
    END IF;
END $$;

-- ====================================
-- FUNÇÕES AUXILIARES PARA GERENCIAR CHAVES ASAAS
-- ====================================

-- Função para adicionar nova chave Asaas a uma organização
CREATE OR REPLACE FUNCTION add_asaas_key(
    p_organizacao_id UUID,
    p_nome_conta VARCHAR(100),
    p_api_key TEXT,
    p_ativo BOOLEAN DEFAULT true
) RETURNS JSONB AS $$
DECLARE
    nova_chave JSONB;
    tabela_alvo TEXT;
BEGIN
    -- Determinar qual tabela usar
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizacoes') THEN
        tabela_alvo := 'organizacoes';
    ELSE
        tabela_alvo := 'filiais';
    END IF;
    
    -- Criar objeto JSON da nova chave
    nova_chave := jsonb_build_object(
        'id', uuid_generate_v4(),
        'nome', p_nome_conta,
        'key', p_api_key,
        'ativo', p_ativo,
        'criado_em', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
    );
    
    -- Adicionar chave ao array existente
    IF tabela_alvo = 'organizacoes' THEN
        UPDATE organizacoes 
        SET asaas_keys = COALESCE(asaas_keys, '[]'::jsonb) || nova_chave
        WHERE id = p_organizacao_id;
    ELSE
        UPDATE filiais 
        SET asaas_keys = COALESCE(asaas_keys, '[]'::jsonb) || nova_chave
        WHERE id = p_organizacao_id;
    END IF;
    
    RETURN nova_chave;
END;
$$ LANGUAGE plpgsql;

-- Função para listar todas as chaves ativas de uma organização
CREATE OR REPLACE FUNCTION get_active_asaas_keys(p_organizacao_id UUID) 
RETURNS TABLE(
    key_id UUID,
    nome VARCHAR(100),
    api_key TEXT,
    ativo BOOLEAN,
    criado_em TIMESTAMP
) AS $$
DECLARE
    tabela_alvo TEXT;
    chaves_json JSONB;
    chave JSONB;
BEGIN
    -- Determinar qual tabela usar
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizacoes') THEN
        tabela_alvo := 'organizacoes';
        SELECT asaas_keys INTO chaves_json FROM organizacoes WHERE id = p_organizacao_id;
    ELSE
        tabela_alvo := 'filiais';
        SELECT asaas_keys INTO chaves_json FROM filiais WHERE id = p_organizacao_id;
    END IF;
    
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

-- Função para desativar uma chave específica
CREATE OR REPLACE FUNCTION deactivate_asaas_key(
    p_organizacao_id UUID,
    p_key_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    tabela_alvo TEXT;
    chaves_atualizadas JSONB;
BEGIN
    -- Determinar qual tabela usar
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizacoes') THEN
        tabela_alvo := 'organizacoes';
    ELSE
        tabela_alvo := 'filiais';
    END IF;
    
    -- Atualizar o status da chave para inativo
    IF tabela_alvo = 'organizacoes' THEN
        UPDATE organizacoes 
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
        WHERE id = p_organizacao_id;
    ELSE
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
        WHERE id = p_organizacao_id;
    END IF;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- EXEMPLOS DE USO
-- ====================================

-- Exemplo 1: Adicionar chave para Matriz (ID: 11111111-1111-1111-1111-111111111111)
/*
SELECT add_asaas_key(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'Conta Principal Matriz',
    '$aact_YTU5YTE0M2M2N2I4MTIzZTVhZmY3ZjEzMjQwYzY5ZDQ6OjAwMDAwMDAwMDAwMDA2MTcyOGE5N2Y5NGViZGI5NDJjNDA4MzI2MzQ2MjYwMTU4NmE=',
    true
);

SELECT add_asaas_key(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'Conta Secundária Matriz',
    '$aact_ABU5YTE0M2M2N2I4MTIzZTVhZmY3ZjEzMjQwYzY5ZDQ6OjAwMDAwMDAwMDAwMDA2MTcyOGE5N2Y5NGViZGI5NDJjNDA4MzI2MzQ2MjYwMTU4NmE=',
    false
);
*/

-- Exemplo 2: Listar chaves ativas
/*
SELECT * FROM get_active_asaas_keys('11111111-1111-1111-1111-111111111111'::UUID);
*/

-- Exemplo 3: Desativar uma chave
/*
SELECT deactivate_asaas_key(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'ID_DA_CHAVE_AQUI'::UUID
);
*/

-- ====================================
-- DOCUMENTAÇÃO E COMENTÁRIOS
-- ====================================

COMMENT ON FUNCTION add_asaas_key IS 'Adiciona nova chave API do Asaas para uma organização. Permite múltiplas chaves por organização.';
COMMENT ON FUNCTION get_active_asaas_keys IS 'Retorna todas as chaves ativas do Asaas para uma organização específica.';
COMMENT ON FUNCTION deactivate_asaas_key IS 'Desativa uma chave específica do Asaas sem removê-la do banco (soft delete).';

-- Log de execução
DO $$
BEGIN
    RAISE NOTICE 'Script de integração com chaves Asaas executado com sucesso em %', CURRENT_TIMESTAMP;
    RAISE NOTICE 'Estrutura JSON das chaves: {"id": "uuid", "nome": "string", "key": "string", "ativo": boolean, "criado_em": "timestamp"}';
    RAISE NOTICE 'Use as funções add_asaas_key(), get_active_asaas_keys() e deactivate_asaas_key() para gerenciar as chaves';
END $$;