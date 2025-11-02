-- ====================================
-- INSERIR CHAVES ASAAS DA MATRIZ
-- ====================================
-- Script para adicionar as chaves Asaas da matriz no banco de dados

-- Primeiro, vamos verificar qual o ID da matriz
SELECT 'VERIFICANDO MATRIZ' as info, id, nome, codigo FROM filiais WHERE codigo = 'matriz' OR nome ILIKE '%matriz%';

-- Inserir as duas chaves Asaas para a matriz
-- Usando o ID padrão da matriz: 11111111-1111-1111-1111-111111111111

-- Chave 1 (CPF)
SELECT add_asaas_key(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'Conta CPF - Matriz',
    '$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmRlOTdhM2E5LTVmYjQtNDA4MS04OWMwLTdhZDZmYTE4MzQxNjo6JGFhY2hfYWEyMTAxN2QtZWE0Yi00YWI2LThmMWItYThiMTdiYThkMGI4',
    true
) as "Chave CPF Adicionada";

-- Chave 2 (CNPJ)
SELECT add_asaas_key(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'Conta CNPJ - Matriz', 
    '$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmIzNGI0YWNjLWZkZmYtNDM2Yy04NWJiLWJiYTk0YzAyYjljODo6JGFhY2hfZWIzMmFiZmMtNzQ3OS00N2ZlLWI0NDEtYmMwZjhmNGQ4YWU2',
    true
) as "Chave CNPJ Adicionada";

-- Verificar se as chaves foram inseridas corretamente
SELECT 'CHAVES ATIVAS DA MATRIZ' as info;
SELECT * FROM get_active_asaas_keys('11111111-1111-1111-1111-111111111111'::UUID);

-- Verificar o campo JSON diretamente na tabela
SELECT 
    'VERIFICAÇÃO FINAL' as info,
    nome,
    jsonb_pretty(asaas_keys) as chaves_formatadas
FROM filiais 
WHERE id = '11111111-1111-1111-1111-111111111111'::UUID;

-- Log de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Chaves Asaas da matriz inseridas com sucesso em %', CURRENT_TIMESTAMP;
    RAISE NOTICE 'Total de chaves ativas: %', (
        SELECT COUNT(*) 
        FROM get_active_asaas_keys('11111111-1111-1111-1111-111111111111'::UUID)
    );
END $$;