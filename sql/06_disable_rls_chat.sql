-- ====================================
-- DESABILITAR RLS PARA SISTEMA DE CHAT
-- ====================================
-- Temporariamente desabilitar Row Level Security para teste

-- Desabilitar RLS nas tabelas de chat
ALTER TABLE chat_conversations DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_avaliacoes DISABLE ROW LEVEL SECURITY;

-- Log
DO $$
BEGIN
    RAISE NOTICE 'RLS desabilitado para tabelas de chat em %', CURRENT_TIMESTAMP;
END $$;