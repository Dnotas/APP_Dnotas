-- LISTAR TODOS OS CLIENTES EXISTENTES
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
ORDER BY c.created_at;

-- CRIAR UM NOVO CLIENTE COM CNPJ ÚNICO
SELECT criar_cliente(
    '11223344000155',           -- CNPJ novo
    'Empresa Teste 3 LTDA',     -- Nome
    'teste3@cliente.com',       -- Email novo
    '123456',                   -- Senha
    '11777777777',              -- Telefone
    'matriz'                    -- Matriz
);

-- Dados para login do novo cliente:
-- CNPJ: 11.223.344/0001-55
-- Senha: 123456