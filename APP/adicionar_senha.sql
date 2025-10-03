-- ADICIONAR COLUNA SENHA E ATUALIZAR CLIENTES EXISTENTES
-- Execute este SQL no Supabase

-- 1. Adicionar coluna senha na tabela clientes
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS senha VARCHAR(255);

-- 2. Atualizar clientes existentes com senha padrão
UPDATE clientes SET senha = '123456' WHERE senha IS NULL;

-- 3. Tornar a coluna senha obrigatória
ALTER TABLE clientes ALTER COLUMN senha SET NOT NULL;

-- 4. Verificar se os clientes foram atualizados
SELECT 
    cnpj,
    nome_empresa,
    email,
    senha,
    filial_id,
    is_active
FROM clientes
ORDER BY created_at;