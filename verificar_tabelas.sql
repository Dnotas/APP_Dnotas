-- Execute este comando no SQL Editor do Supabase para ver a estrutura das tabelas

-- Ver todas as tabelas existentes
SELECT 
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Ver estrutura da tabela clientes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver estrutura da tabela filiais
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'filiais' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver estrutura da tabela funcionarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'funcionarios' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver dados de exemplo (apenas alguns registros)
SELECT 'clientes' as tabela, count(*) as total FROM clientes
UNION ALL
SELECT 'filiais' as tabela, count(*) as total FROM filiais  
UNION ALL
SELECT 'funcionarios' as tabela, count(*) as total FROM funcionarios;