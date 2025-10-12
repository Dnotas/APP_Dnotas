-- Alternativa: Remover constraint de filial_id (mais simples)

-- Opção 1: Remover a constraint de foreign key
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_filial_id_fkey;

-- Opção 2: Ou tornar filial_id opcional
ALTER TABLE clientes ALTER COLUMN filial_id DROP NOT NULL;