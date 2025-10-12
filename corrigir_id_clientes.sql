-- Corrigir problema do campo ID na tabela clientes

-- 1. Verificar estrutura atual da tabela
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Adicionar valor padrão para o campo ID (gerar UUID automaticamente)
ALTER TABLE clientes ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Verificar se a alteração funcionou
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND column_name = 'id'
    AND table_schema = 'public';