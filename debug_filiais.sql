-- SCRIPT DE DEBUG - Verificar filiais no banco de dados
-- Execute este script no Supabase para verificar os dados

-- 1. Verificar se a migração foi executada
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'client_filiais' 
AND table_schema = 'public';

-- 2. Verificar se a função existe
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'get_all_client_cnpjs';

-- 3. Listar todos os clientes
SELECT cnpj, nome_empresa, is_active 
FROM clientes 
WHERE is_active = true 
ORDER BY nome_empresa;

-- 4. Verificar filiais cadastradas
SELECT * FROM client_filiais WHERE is_active = true;

-- 5. Testar a função com CNPJ específico (SUBSTITUA pelo seu CNPJ)
-- CNPJ que aparece na imagem: 41678818000145
SELECT * FROM get_all_client_cnpjs('41678818000145');

-- 6. Verificar resposta da API simulada
SELECT 
    c.cnpj,
    c.nome_empresa,
    c.email,
    c.telefone,
    c.filial_id,
    (
        SELECT json_agg(
            json_build_object(
                'cnpj', all_cnpjs.cnpj,
                'nome', all_cnpjs.nome,
                'tipo', all_cnpjs.tipo,
                'ativo', all_cnpjs.ativo
            )
        )
        FROM get_all_client_cnpjs(c.cnpj) all_cnpjs
        WHERE all_cnpjs.tipo = 'filial' -- Apenas filiais, não matriz
    ) as filiais
FROM clientes c 
WHERE c.cnpj = '41678818000145';

-- 7. Inserir filial de teste para o seu CNPJ (se não existir)
INSERT INTO client_filiais (matriz_cnpj, filial_cnpj, filial_nome) 
VALUES ('41678818000145', '41678818000226', 'UAI SORVETES - Filial 1')
ON CONFLICT (filial_cnpj) DO NOTHING;

-- 8. Verificar novamente após inserção
SELECT * FROM get_all_client_cnpjs('41678818000145');