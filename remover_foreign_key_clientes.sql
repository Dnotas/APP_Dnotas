-- Remover constraint de chave estrangeira problemática

-- 1. Verificar quais constraints existem na tabela clientes
SELECT 
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'clientes' 
    AND table_schema = 'public'
    AND constraint_type = 'FOREIGN KEY';

-- 2. Remover a constraint problemática
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_id_fkey;

-- 3. Verificar se foi removida
SELECT 
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'clientes' 
    AND table_schema = 'public'
    AND constraint_type = 'FOREIGN KEY';