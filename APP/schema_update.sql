-- ATUALIZAÇÃO DO SCHEMA - ADICIONAR CNPJ DA EMPRESA NAS FILIAIS

-- 1. Adicionar coluna CNPJ da empresa nas filiais
ALTER TABLE filiais ADD COLUMN IF NOT EXISTS cnpj_empresa VARCHAR(14);

-- 2. Atualizar os dados das filiais com os CNPJs da empresa
UPDATE filiais SET 
    nome = 'Matriz - DNOTAS',
    cnpj_empresa = '47824624000197'
WHERE id = 'matriz';

UPDATE filiais SET 
    nome = 'Filial 1 - DNOTAS',
    cnpj_empresa = '47824624000278' -- Substitua pelo CNPJ real da filial 1
WHERE id = 'filial_1';

UPDATE filiais SET 
    nome = 'Filial 2 - DNOTAS',
    cnpj_empresa = '47824624000359' -- Substitua pelo CNPJ real da filial 2
WHERE id = 'filial_2';

-- 3. Função para facilitar o cadastro de clientes
CREATE OR REPLACE FUNCTION criar_cliente(
    p_cnpj VARCHAR(14),
    p_nome_empresa VARCHAR(255),
    p_email VARCHAR(255),
    p_senha VARCHAR(255),
    p_telefone VARCHAR(15) DEFAULT NULL,
    p_filial_id VARCHAR(50) DEFAULT 'matriz'
)
RETURNS UUID AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Criar usuário no Auth
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
        p_email,
        crypt(p_senha, gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        false,
        'authenticated'
    ) RETURNING id INTO user_id;
    
    -- Criar registro na tabela clientes
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
        user_id,
        p_cnpj,
        p_nome_empresa,
        p_email,
        p_telefone,
        p_filial_id,
        NOW(),
        true
    );
    
    RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Exemplos de uso da função para criar clientes:

-- Cliente da MATRIZ:
SELECT criar_cliente(
    '12345678000195',
    'Empresa ABC LTDA', 
    'cliente1@abc.com',
    '123456',
    '11999999999',
    'matriz'
);

-- Cliente da FILIAL 1:
SELECT criar_cliente(
    '98765432000106',
    'Comércio XYZ EIRELI',
    'cliente2@xyz.com', 
    '123456',
    '11888888888',
    'filial_1'
);

-- Cliente da FILIAL 2:
SELECT criar_cliente(
    '11223344000155',
    'Indústria 123 S/A',
    'cliente3@123.com',
    '123456', 
    '11777777777',
    'filial_2'
);

-- 5. View para relatório de clientes por filial
CREATE OR REPLACE VIEW vw_clientes_por_filial AS
SELECT 
    f.id as filial_id,
    f.nome as nome_filial,
    f.cnpj_empresa as cnpj_filial,
    c.cnpj as cnpj_cliente,
    c.nome_empresa,
    c.email,
    c.telefone,
    c.created_at,
    c.last_login,
    c.is_active,
    CASE 
        WHEN c.last_login IS NULL THEN EXTRACT(DAYS FROM (NOW() - c.created_at))
        ELSE EXTRACT(DAYS FROM (NOW() - c.last_login))
    END as dias_inativo
FROM filiais f
LEFT JOIN clientes c ON f.id = c.filial_id
WHERE c.is_active = true
ORDER BY f.id, c.nome_empresa;