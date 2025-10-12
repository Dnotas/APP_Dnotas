-- Corrigir tamanho do campo CNPJ para suportar formatação (XX.XXX.XXX/XXXX-XX = 18 caracteres)

-- 1. Alterar tamanho do campo CNPJ na tabela clientes
ALTER TABLE clientes ALTER COLUMN cnpj TYPE VARCHAR(20);

-- 2. Verificar se a alteração foi aplicada
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND column_name = 'cnpj'
    AND table_schema = 'public';

-- 3. Verificar dados existentes
SELECT cnpj, LENGTH(cnpj) as tamanho_atual FROM clientes;