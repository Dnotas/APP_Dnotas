-- ====================================
-- ADICIONAR COLUNA ASAAS_KEYS NA TABELA FILIAIS
-- ====================================

-- 1. Verificar se a coluna já existe
SELECT 
    'VERIFICAR COLUNA' as info,
    column_name 
FROM information_schema.columns 
WHERE table_name = 'filiais' AND column_name = 'asaas_keys';

-- 2. Adicionar a coluna asaas_keys se não existir
ALTER TABLE filiais 
ADD COLUMN IF NOT EXISTS asaas_keys JSONB DEFAULT '[]'::jsonb;

-- 3. Adicionar comentário explicativo
COMMENT ON COLUMN filiais.asaas_keys IS 'Array JSON com múltiplas chaves de API do Asaas: [{"id": "uuid", "nome": "string", "key": "string", "ativo": boolean, "criado_em": "timestamp"}]';

-- 4. Criar índice para busca eficiente nas chaves
CREATE INDEX IF NOT EXISTS idx_filiais_asaas_keys ON filiais USING gin(asaas_keys);

-- 5. Verificar se a coluna foi criada
SELECT 
    'COLUNA CRIADA' as info,
    column_name,
    data_type,
    column_default
FROM information_schema.columns 
WHERE table_name = 'filiais' AND column_name = 'asaas_keys';

-- 6. Verificar estrutura atual da tabela filiais
SELECT 
    'ESTRUTURA COMPLETA FILIAIS' as info,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'filiais'
ORDER BY ordinal_position;

-- Log de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Coluna asaas_keys adicionada à tabela filiais em %', CURRENT_TIMESTAMP;
END $$;