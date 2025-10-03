-- CRIAR CLIENTE DE TESTE - MATRIZ
-- Execute este SQL no SQL Editor do Supabase

-- Criar cliente de teste da Matriz
SELECT criar_cliente(
    '12345678000195',           -- CNPJ do cliente
    'Empresa Teste LTDA',       -- Nome da empresa
    'teste@cliente.com',        -- Email
    '123456',                   -- Senha
    '11999999999',              -- Telefone
    'matriz'                    -- Filial (Matriz)
);

-- Dados para login no APP:
-- CNPJ: 12.345.678/0001-95
-- Senha: 123456