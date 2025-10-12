-- Correção do campo CNPJ com problema de VIEW

-- 1. PRIMEIRO: Verificar se a view existe e qual sua definição
SELECT 
    table_name, 
    view_definition 
FROM information_schema.views 
WHERE table_schema = 'public' 
    AND table_name = 'vw_inatividade_clientes';

-- 2. Salvar a definição da view (copie o resultado acima)
-- Execute os próximos comandos APENAS depois de ver a definição da view

-- 3. Dropar a view temporariamente
DROP VIEW IF EXISTS vw_inatividade_clientes;

-- 4. Agora alterar o tipo da coluna CNPJ
ALTER TABLE clientes ALTER COLUMN cnpj TYPE VARCHAR(20);

-- 5. Recriar a view (substitua pela definição real da view)
-- IMPORTANTE: Cole aqui a definição original da view que apareceu no passo 1
-- Exemplo genérico (SUBSTITUA pela definição real):
/*
CREATE VIEW vw_inatividade_clientes AS 
SELECT 
    id,
    cnpj,
    nome_empresa,
    last_login,
    created_at,
    CASE 
        WHEN last_login IS NULL THEN EXTRACT(DAY FROM (NOW() - created_at))
        ELSE EXTRACT(DAY FROM (NOW() - last_login))
    END as dias_inativo
FROM clientes 
WHERE is_active = true;
*/

-- 6. Verificar se a alteração funcionou
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND column_name = 'cnpj'
    AND table_schema = 'public';