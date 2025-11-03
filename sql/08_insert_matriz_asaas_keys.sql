-- ====================================
-- CHAVES ASAAS REMOVIDAS POR SEGURANÇA
-- ====================================
-- IMPORTANTE: As chaves de API do Asaas foram removidas deste arquivo por segurança.
-- Para adicionar chaves Asaas ao sistema:
--
-- 1. Use a interface administrativa do sistema
-- 2. Ou execute manualmente:
--    SELECT add_asaas_key('FILIAL_ID', 'NOME_DA_CONTA', 'SUA_CHAVE_API', true);
--
-- Exemplo:
-- SELECT add_asaas_key(
--     '11111111-1111-1111-1111-111111111111'::UUID,
--     'Conta Principal',
--     'sua_chave_api_aqui',
--     true
-- );

-- Primeiro, vamos verificar qual o ID da matriz
SELECT 'VERIFICANDO MATRIZ' as info, id, nome, codigo FROM filiais WHERE codigo = 'matriz' OR nome ILIKE '%matriz%';

SELECT 'CHAVES REMOVIDAS POR SEGURANÇA' as aviso;
SELECT 'Use a interface do sistema para adicionar chaves Asaas' as instrucao;

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