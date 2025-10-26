-- ====================================
-- DEBUG CLIENTE PARA CHAT
-- ====================================
-- Script para verificar se o cliente existe e está ativo

-- 1. Verificar se existe cliente com esse CNPJ (substitua pelo CNPJ real)
SELECT 
    cnpj,
    nome_empresa,
    filial_id,
    is_active,
    id
FROM clientes 
WHERE cnpj LIKE '%41678818000145%'  -- Substitua pelo seu CNPJ
   OR cnpj LIKE '%41.678.818/0001-45%'
   OR cnpj = '41678818000145';

-- 2. Verificar todos os CNPJs na tabela (primeiros 10)
SELECT 
    cnpj,
    nome_empresa,
    filial_id,
    is_active
FROM clientes 
WHERE is_active = true
LIMIT 10;

-- 3. Testar a função com o CNPJ que aparece no debug
-- Substitua '41678818000145' pelo CNPJ que você vê na consulta acima
DO $$
DECLARE
    v_filial_id VARCHAR;
    v_cliente_id UUID;
    teste_cnpj VARCHAR(14) := '41678818000145'; -- SUBSTITUA AQUI
BEGIN
    -- Buscar filial e ID do cliente (mesma lógica da função)
    SELECT filial_id, id INTO v_filial_id, v_cliente_id
    FROM clientes 
    WHERE cnpj = teste_cnpj AND is_active = true;
    
    IF v_filial_id IS NULL THEN
        RAISE NOTICE 'ERRO: Cliente não encontrado para CNPJ: %', teste_cnpj;
        
        -- Tentar variações do CNPJ
        SELECT filial_id, id INTO v_filial_id, v_cliente_id
        FROM clientes 
        WHERE cnpj LIKE '%' || teste_cnpj || '%' AND is_active = true;
        
        IF v_filial_id IS NOT NULL THEN
            RAISE NOTICE 'ENCONTRADO com LIKE: filial=%, cliente_id=%', v_filial_id, v_cliente_id;
        ELSE
            RAISE NOTICE 'NÃO ENCONTRADO nem com LIKE';
        END IF;
    ELSE
        RAISE NOTICE 'SUCESSO: filial=%, cliente_id=%', v_filial_id, v_cliente_id;
    END IF;
END $$;