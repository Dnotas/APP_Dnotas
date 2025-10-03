-- RECRIAR USUÁRIO CORRETAMENTE NO SUPABASE AUTH
-- Execute este SQL no Supabase

-- 1. Primeiro, deletar o usuário atual (se existir)
DELETE FROM auth.users WHERE email = 'cliente1@abc.com';
DELETE FROM clientes WHERE cnpj = '12345678000195';

-- 2. Criar usuário usando a função correta do Supabase
SELECT auth.admin_create_user(
  email => 'cliente1@abc.com',
  password => '123456',
  email_confirm => true
);

-- 3. Pegar o ID do usuário criado
SELECT id FROM auth.users WHERE email = 'cliente1@abc.com';

-- 4. Inserir na tabela clientes (substitua USER_ID_AQUI pelo ID retornado acima)
INSERT INTO clientes (
    id,
    cnpj,
    nome_empresa,
    email,
    telefone,
    filial_id,
    created_at,
    is_active
) VALUES (
    (SELECT id FROM auth.users WHERE email = 'cliente1@abc.com'),
    '12345678000195',
    'Empresa ABC LTDA',
    'cliente1@abc.com',
    '11999999999',
    'matriz',
    NOW(),
    true
);

-- 5. Verificar se foi criado corretamente
SELECT 
    u.id,
    u.email,
    u.created_at,
    c.cnpj,
    c.nome_empresa
FROM auth.users u
JOIN clientes c ON u.id = c.id
WHERE u.email = 'cliente1@abc.com';