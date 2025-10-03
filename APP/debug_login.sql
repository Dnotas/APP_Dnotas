-- TESTAR SE A BUSCA POR EMAIL FUNCIONA
-- Esta é a query que o app está executando internamente

SELECT email 
FROM clientes 
WHERE cnpj = '12345678000195';

-- Resultado deve ser: cliente1@abc.com

-- Se o resultado estiver correto, o problema pode estar na autenticação
-- Vamos resetar a senha para garantir:
UPDATE auth.users 
SET encrypted_password = crypt('123456', gen_salt('bf')),
    updated_at = NOW()
WHERE email = 'cliente1@abc.com';