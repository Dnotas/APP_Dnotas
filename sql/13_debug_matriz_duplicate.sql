-- ====================================
-- DEBUG: VERIFICAR DUPLICATAS DA MATRIZ
-- ====================================

-- 1. Verificar todas as filiais
SELECT 'TODAS AS FILIAIS' as info, id, nome, codigo, ativo FROM filiais ORDER BY created_at;

-- 2. Verificar clientes e suas filial_id
SELECT 'CLIENTES E FILIAIS' as info, cnpj, nome_empresa, filial_id FROM clientes LIMIT 10;

-- 3. Verificar se algum cliente está vinculado ao "matriz-id"
SELECT 'CLIENTES MATRIZ-ID' as info, COUNT(*) as total_clientes 
FROM clientes WHERE filial_id = 'matriz-id';

-- 4. Verificar se algum cliente está vinculado ao UUID da matriz
SELECT 'CLIENTES UUID MATRIZ' as info, COUNT(*) as total_clientes 
FROM clientes WHERE filial_id = '11111111-1111-1111-1111-111111111111';

-- 5. Verificar estrutura da tabela clientes
SELECT 
    'ESTRUTURA CLIENTES' as info,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 6. Verificar se existe tabela users
SELECT 
    'VERIFICAR USERS' as info,
    table_name
FROM information_schema.tables 
WHERE table_name = 'users';

-- 7. Se users existe, verificar estrutura
SELECT 
    'ESTRUTURA USERS' as info,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- 8. Verificar dados na tabela users (se existir)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
        RAISE NOTICE 'Tabela users existe, verificando dados...';
        -- Não podemos fazer SELECT dinâmico em DO block, mas podemos informar
    ELSE
        RAISE NOTICE 'Tabela users NÃO existe';
    END IF;
END $$;