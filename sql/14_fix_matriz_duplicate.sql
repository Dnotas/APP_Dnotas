-- ====================================
-- CORREÇÃO: REMOVER DUPLICATA DA MATRIZ
-- ====================================

-- ANÁLISE: Você tem duas entradas para matriz:
-- 1. id='11111111-1111-1111-1111-111111111111' (com chaves Asaas) ✅ MANTER
-- 2. id='matriz-id' (sem chaves Asaas) ❌ REMOVER

-- Passo 1: Verificar se há clientes vinculados ao 'matriz-id'
SELECT 'VERIFICAÇÃO INICIAL' as info;
SELECT 'Clientes vinculados ao matriz-id' as info, COUNT(*) as total
FROM clientes WHERE filial_id = 'matriz-id';

SELECT 'Clientes vinculados ao UUID matriz' as info, COUNT(*) as total  
FROM clientes WHERE filial_id = '11111111-1111-1111-1111-111111111111';

-- Passo 2: Migrar clientes do 'matriz-id' para o UUID correto (se houver)
UPDATE clientes 
SET filial_id = '11111111-1111-1111-1111-111111111111'
WHERE filial_id = 'matriz-id';

-- Verificar quantos registros foram atualizados
SELECT 'MIGRAÇÃO CONCLUÍDA' as info;
SELECT 'Clientes migrados para UUID' as info, COUNT(*) as total
FROM clientes WHERE filial_id = '11111111-1111-1111-1111-111111111111';

-- Passo 3: Verificar se há outras tabelas que referenciam 'matriz-id'
-- Verificar funcionarios
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'filial_id') THEN
        UPDATE funcionarios 
        SET filial_id = '11111111-1111-1111-1111-111111111111'
        WHERE filial_id = 'matriz-id';
        
        RAISE NOTICE 'Funcionários migrados para UUID da matriz';
    END IF;
END $$;

-- Verificar chat_conversations
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'chat_conversations' AND column_name = 'filial_id') THEN
        UPDATE chat_conversations 
        SET filial_id = '11111111-1111-1111-1111-111111111111'
        WHERE filial_id = 'matriz-id';
        
        RAISE NOTICE 'Conversas migradas para UUID da matriz';
    END IF;
END $$;

-- Verificar chat_templates
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'chat_templates' AND column_name = 'filial_id') THEN
        UPDATE chat_templates 
        SET filial_id = '11111111-1111-1111-1111-111111111111'
        WHERE filial_id = 'matriz-id';
        
        RAISE NOTICE 'Templates migrados para UUID da matriz';
    END IF;
END $$;

-- Passo 4: Remover a entrada duplicada 'matriz-id'
DELETE FROM filiais WHERE id = 'matriz-id';

-- Passo 5: Verificação final
SELECT 'VERIFICAÇÃO FINAL' as info;
SELECT 'Total de filiais restantes' as info, COUNT(*) as total FROM filiais;
SELECT 'Matriz única' as info, id, nome, codigo, 
       CASE WHEN asaas_keys IS NOT NULL AND asaas_keys != '[]'::jsonb 
            THEN 'COM CHAVES' 
            ELSE 'SEM CHAVES' 
       END as status_chaves
FROM filiais 
WHERE nome ILIKE '%matriz%' OR codigo ILIKE '%matriz%';

-- Log de sucesso
DO $$
DECLARE
    total_chaves INTEGER;
BEGIN
    SELECT jsonb_array_length(asaas_keys) INTO total_chaves 
    FROM filiais 
    WHERE id = '11111111-1111-1111-1111-111111111111';
    
    RAISE NOTICE 'Correção concluída! Matriz única com % chaves Asaas ativas', total_chaves;
END $$;