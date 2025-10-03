-- VERIFICAR SE O CLIENTE JÁ EXISTE E ESTÁ FUNCIONAL
SELECT 
    c.cnpj,
    c.nome_empresa,
    c.email,
    c.filial_id,
    f.nome as nome_filial,
    c.is_active,
    c.created_at
FROM clientes c
JOIN filiais f ON c.filial_id = f.id
WHERE c.cnpj = '12345678000195';

-- SE O CLIENTE ACIMA EXISTE, VOCÊ PODE FAZER LOGIN COM:
-- CNPJ: 12.345.678/0001-95
-- Senha: 123456

-- OU CRIAR OUTRO CLIENTE DE TESTE COM CNPJ DIFERENTE:
SELECT criar_cliente(
    '98765432000106',           -- CNPJ diferente
    'Empresa Teste 2 LTDA',     -- Nome
    'teste2@cliente.com',       -- Email diferente
    '123456',                   -- Senha
    '11888888888',              -- Telefone
    'matriz'                    -- Matriz
);

-- Dados para login do segundo cliente:
-- CNPJ: 98.765.432/0001-06
-- Senha: 123456