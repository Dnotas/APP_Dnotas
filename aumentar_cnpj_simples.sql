-- Comando simples para aumentar o tamanho do campo CNPJ

-- 1. Primeiro: Dropar a view que está bloqueando
DROP VIEW IF EXISTS vw_inatividade_clientes;

-- 2. Alterar o tamanho do campo CNPJ
ALTER TABLE clientes ALTER COLUMN cnpj TYPE VARCHAR(20);

-- 3. Recriar a view básica (você pode ajustar depois se necessário)
CREATE VIEW vw_inatividade_clientes AS 
SELECT 
    id,
    cnpj,
    nome_empresa,
    last_login,
    created_at,
    is_active
FROM clientes;

-- 4. Verificar se funcionou
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND column_name = 'cnpj'
    AND table_schema = 'public';