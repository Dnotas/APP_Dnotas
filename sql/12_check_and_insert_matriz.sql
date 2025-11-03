-- ====================================
-- VERIFICAR E CRIAR MATRIZ SE NECESSÁRIO
-- ====================================

-- 1. Verificar filiais existentes
SELECT 'FILIAIS EXISTENTES' as info, id, nome, codigo FROM filiais ORDER BY nome;

-- 2. Se não existir matriz, vamos criar
INSERT INTO filiais (id, nome, codigo, ativo) VALUES 
('11111111-1111-1111-1111-111111111111', 'Matriz', 'matriz', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Verificar se matriz foi criada/existe
SELECT 'MATRIZ VERIFICADA' as info, id, nome, codigo FROM filiais WHERE codigo = 'matriz' OR nome ILIKE '%matriz%';

-- 4. CHAVES REMOVIDAS POR SEGURANÇA
-- As chaves Asaas devem ser inseridas manualmente pelo administrador
-- usando a interface do sistema ou chamadas diretas à função add_asaas_key()

SELECT 'CHAVES ASAAS REMOVIDAS' as info;
SELECT 'Use a interface do sistema para adicionar as chaves de API do Asaas' as instrucao;

-- 5. Verificar chaves inseridas
SELECT 'CHAVES ATIVAS' as info;
SELECT * FROM get_active_asaas_keys('11111111-1111-1111-1111-111111111111');

-- 6. Ver JSON formatado
SELECT 'JSON FORMATADO' as info;
SELECT nome, jsonb_pretty(asaas_keys) as chaves_formatadas
FROM filiais 
WHERE id = '11111111-1111-1111-1111-111111111111';

-- Log final
DO $$
DECLARE
    total_chaves INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_chaves FROM get_active_asaas_keys('11111111-1111-1111-1111-111111111111');
    RAISE NOTICE 'Processo concluído! Total de chaves ativas na matriz: %', total_chaves;
END $$;