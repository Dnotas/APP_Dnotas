-- VERIFICAR SE O USUÁRIO EXISTE NO AUTH DO SUPABASE
-- Execute este SQL para ver se há problema de autenticação

-- 1. Verificar se o cliente existe na tabela clientes
SELECT 
    c.id,
    c.cnpj,
    c.nome_empresa,
    c.email,
    c.filial_id
FROM clientes c
WHERE c.cnpj = '12345678000195';

-- 2. Verificar se existe usuário correspondente no auth.users
SELECT 
    u.id,
    u.email,
    u.created_at,
    u.email_confirmed_at,
    u.last_sign_in_at
FROM auth.users u
JOIN clientes c ON u.id = c.id
WHERE c.cnpj = '12345678000195';

-- 3. Se não existir no auth.users, vamos criar manualmente
-- Primeiro pegue o ID do cliente:
SELECT id, email FROM clientes WHERE cnpj = '12345678000195';

-- 4. SOLUÇÃO: Criar usuário no auth manualmente
-- Substitua 'CLIENT_ID_AQUI' pelo ID retornado acima
INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role,
    aud
) VALUES (
    (SELECT id FROM clientes WHERE cnpj = '12345678000195'),
    '00000000-0000-0000-0000-000000000000',
    'cliente1@abc.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    'authenticated',
    'authenticated'
) ON CONFLICT (id) DO UPDATE SET
    encrypted_password = crypt('123456', gen_salt('bf')),
    updated_at = NOW();