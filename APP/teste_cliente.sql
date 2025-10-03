-- CRIAR CLIENTE DE TESTE NO SUPABASE
-- Execute este SQL no SQL Editor do Supabase

-- 1. Primeiro, vamos criar um usuário no sistema de autenticação
-- Vá em Authentication > Users no painel do Supabase e clique em "Add user"
-- Ou use este SQL (substitua o email/senha):

-- Dados de teste:
-- Email: teste@dnotas.com
-- Senha: 123456
-- CNPJ: 12345678000195

-- 2. Depois que criar o usuário na aba Authentication, execute este SQL:
-- (Substitua 'USER_ID_AQUI' pelo ID do usuário criado)

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
    'USER_ID_AQUI', -- Substitua pelo ID do usuário criado em Authentication
    '12345678000195',
    'Empresa Teste LTDA',
    'teste@dnotas.com',
    '11999999999',
    'matriz',
    NOW(),
    true
);

-- OU MAIS FÁCIL: Use o app para se cadastrar
-- Dados para teste:
-- CNPJ: 12.345.678/0001-95
-- Nome: Empresa Teste LTDA  
-- Email: teste@dnotas.com
-- Senha: 123456
-- Filial: Matriz