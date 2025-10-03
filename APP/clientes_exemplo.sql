-- CADASTRO DE CLIENTES - FEITO PELA EMPRESA
-- Execute este SQL no SQL Editor do Supabase

-- 1. Primeiro, vamos definir os CNPJs das filiais da empresa
UPDATE filiais SET 
    nome = 'Matriz - DNOTAS',
    cnpj_empresa = '47824624000197'
WHERE id = 'matriz';

UPDATE filiais SET 
    nome = 'Filial 1 - DNOTAS',
    cnpj_empresa = '47824624000278' -- Exemplo de CNPJ da filial 1
WHERE id = 'filial_1';

UPDATE filiais SET 
    nome = 'Filial 2 - DNOTAS', 
    cnpj_empresa = '47824624000359' -- Exemplo de CNPJ da filial 2
WHERE id = 'filial_2';

-- 2. Adicionar coluna CNPJ da empresa nas filiais (se não existir)
ALTER TABLE filiais ADD COLUMN IF NOT EXISTS cnpj_empresa VARCHAR(14);

-- 3. Criar clientes de exemplo para a MATRIZ
-- Cliente 1 - Matriz
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role
) VALUES (
    gen_random_uuid(),
    'cliente1@empresa.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    'authenticated'
);

-- Pegar o ID do usuário criado e inserir na tabela clientes
-- (Você precisará copiar o ID do usuário criado acima)

-- EXEMPLO DE CLIENTES PARA CADASTRAR:

-- CLIENTES DA MATRIZ (47.824.624/0001-97):
INSERT INTO clientes (
    id, 
    cnpj, 
    nome_empresa, 
    email, 
    telefone, 
    filial_id, 
    created_at, 
    is_active
) VALUES 
-- Cliente 1 da Matriz
('USER_ID_1', '12345678000195', 'Empresa ABC LTDA', 'cliente1@abc.com', '11999999999', 'matriz', NOW(), true),
-- Cliente 2 da Matriz  
('USER_ID_2', '98765432000106', 'Comércio XYZ EIRELI', 'contato@xyz.com', '11888888888', 'matriz', NOW(), true),
-- Cliente 3 da Matriz
('USER_ID_3', '11223344000155', 'Indústria 123 S/A', 'financeiro@123.com', '11777777777', 'matriz', NOW(), true);

-- CLIENTES DA FILIAL 1:
INSERT INTO clientes (
    id, 
    cnpj, 
    nome_empresa, 
    email, 
    telefone, 
    filial_id, 
    created_at, 
    is_active
) VALUES 
-- Cliente 1 da Filial 1
('USER_ID_4', '55667788000144', 'Loja DEF ME', 'vendas@def.com', '11666666666', 'filial_1', NOW(), true),
-- Cliente 2 da Filial 1
('USER_ID_5', '44556677000133', 'Serviços GHI LTDA', 'admin@ghi.com', '11555555555', 'filial_1', NOW(), true);

-- CLIENTES DA FILIAL 2:
INSERT INTO clientes (
    id, 
    cnpj, 
    nome_empresa, 
    email, 
    telefone, 
    filial_id, 
    created_at, 
    is_active
) VALUES 
-- Cliente 1 da Filial 2
('USER_ID_6', '33445566000122', 'Distribuidora JKL LTDA', 'compras@jkl.com', '11444444444', 'filial_2', NOW(), true),
-- Cliente 2 da Filial 2
('USER_ID_7', '22334455000111', 'Transportadora MNO S/A', 'operacao@mno.com', '11333333333', 'filial_2', NOW(), true);

-- Query para ver a distribuição de clientes por filial:
SELECT 
    f.nome as filial,
    f.cnpj_empresa,
    COUNT(c.id) as total_clientes,
    STRING_AGG(c.nome_empresa, ', ') as empresas
FROM filiais f
LEFT JOIN clientes c ON f.id = c.filial_id
GROUP BY f.id, f.nome, f.cnpj_empresa
ORDER BY f.id;