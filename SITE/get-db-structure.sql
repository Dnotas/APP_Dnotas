-- SQL para obter estrutura completa das tabelas relevantes do banco

-- 1. Estrutura da tabela chat_conversations
SELECT 
    'chat_conversations' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'chat_conversations'
ORDER BY ordinal_position;

-- 2. Estrutura da tabela chat_messages  
SELECT 
    'chat_messages' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'chat_messages'
ORDER BY ordinal_position;

-- 3. Estrutura da tabela clientes
SELECT 
    'clientes' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 4. Estrutura da tabela funcionarios
SELECT 
    'funcionarios' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 5. Estrutura da tabela organizacoes
SELECT 
    'organizacoes' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'organizacoes'
ORDER BY ordinal_position;

-- 6. Dados atuais das organizações
SELECT 'DADOS ORGANIZACOES' as info, id, nome, tipo FROM organizacoes;

-- 7. Dados atuais dos funcionários (IDs e organizacao_id)
SELECT 'DADOS FUNCIONARIOS' as info, id, nome, organizacao_id FROM funcionarios;

-- 8. Amostra de clientes (primeiros 3 com filial_id)
SELECT 'DADOS CLIENTES' as info, cnpj, nome_empresa, filial_id FROM clientes LIMIT 3;

-- 9. Conversas existentes 
SELECT 'DADOS CONVERSAS' as info, id, cliente_cnpj, filial_id, status FROM chat_conversations;

-- 10. Mensagens existentes (primeiras 3)
SELECT 'DADOS MENSAGENS' as info, conversa_id, remetente_tipo, conteudo FROM chat_messages LIMIT 3;