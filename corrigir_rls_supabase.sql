-- Execute este SQL no Supabase para corrigir problemas de RLS (Row Level Security)

-- 1. Verificar se RLS está habilitado nas tabelas
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('clientes', 'funcionarios', 'filiais');

-- 2. Desabilitar RLS temporariamente para desenvolvimento (se necessário)
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;  
ALTER TABLE filiais DISABLE ROW LEVEL SECURITY;

-- 3. Ou criar políticas básicas se preferir manter RLS ativo
-- (Descomente as linhas abaixo se quiser usar RLS com políticas)

/*
-- Política para clientes (permite select para anon)
CREATE POLICY "Allow anon select on clientes" ON clientes 
FOR SELECT TO anon USING (true);

-- Política para funcionarios (permite select para anon)
CREATE POLICY "Allow anon select on funcionarios" ON funcionarios 
FOR SELECT TO anon USING (true);

-- Política para filiais (permite select para anon) 
CREATE POLICY "Allow anon select on filiais" ON filiais 
FOR SELECT TO anon USING (true);

-- Política para insert em clientes
CREATE POLICY "Allow anon insert on clientes" ON clientes 
FOR INSERT TO anon WITH CHECK (true);

-- Política para insert em funcionarios
CREATE POLICY "Allow anon insert on funcionarios" ON funcionarios 
FOR INSERT TO anon WITH CHECK (true);

-- Política para insert em filiais
CREATE POLICY "Allow anon insert on filiais" ON filiais 
FOR INSERT TO anon WITH CHECK (true);
*/

-- 4. Verificar se as políticas foram criadas/removidas
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual, 
    with_check 
FROM pg_policies 
WHERE schemaname = 'public' 
    AND tablename IN ('clientes', 'funcionarios', 'filiais');

-- 5. Testar acesso básico
SELECT 'clientes' as tabela, count(*) as total FROM clientes
UNION ALL
SELECT 'funcionarios' as tabela, count(*) as total FROM funcionarios
UNION ALL  
SELECT 'filiais' as tabela, count(*) as total FROM filiais;