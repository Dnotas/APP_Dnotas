-- ============================================
-- COMANDO PARA INVESTIGAR ESTRUTURA COMPLETA DO BANCO
-- Execute este SQL no Supabase e me envie o resultado
-- ============================================

-- 1. LISTAR TODAS AS TABELAS
SELECT 'TABELAS EXISTENTES:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. ESTRUTURA DA TABELA FILIAIS (se existir)
SELECT 'ESTRUTURA TABELA FILIAIS:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'filiais' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. DADOS DA TABELA FILIAIS (se existir)
SELECT 'DADOS TABELA FILIAIS:' as info;
SELECT * FROM filiais LIMIT 5;

-- 4. ESTRUTURA DA TABELA FUNCIONARIOS (se existir)
SELECT 'ESTRUTURA TABELA FUNCIONARIOS:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'funcionarios' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. DADOS DA TABELA FUNCIONARIOS (se existir)
SELECT 'DADOS TABELA FUNCIONARIOS:' as info;
SELECT * FROM funcionarios LIMIT 5;

-- 6. ESTRUTURA DA TABELA ORGANIZACOES (se existir)
SELECT 'ESTRUTURA TABELA ORGANIZACOES:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'organizacoes' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 7. DADOS DA TABELA ORGANIZACOES (se existir)
SELECT 'DADOS TABELA ORGANIZACOES:' as info;
SELECT * FROM organizacoes LIMIT 5;

-- 8. VERIFICAR FOREIGN KEYS
SELECT 'FOREIGN KEYS:' as info;
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_schema = 'public';

-- 9. VERIFICAR FUNCIONÁRIO DNOTAS
SELECT 'FUNCIONÁRIO DNOTAS:' as info;
SELECT * FROM funcionarios WHERE email = 'DNOTAS';

-- 10. CONTAR REGISTROS
SELECT 'TOTAIS:' as info;
SELECT 
    'filiais' as tabela, 
    COUNT(*) as total 
FROM filiais
UNION ALL
SELECT 
    'funcionarios' as tabela, 
    COUNT(*) as total 
FROM funcionarios
UNION ALL
SELECT 
    'organizacoes' as tabela, 
    COUNT(*) as total 
FROM organizacoes;