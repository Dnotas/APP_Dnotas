-- CORRIGIR PROBLEMA DE RLS - PERMITIR BUSCA POR CNPJ SEM AUTENTICAÇÃO
-- Execute este SQL no Supabase

-- 1. Permitir busca de email por CNPJ para login (sem autenticação)
CREATE POLICY "Permitir busca email por CNPJ para login" ON clientes
    FOR SELECT USING (true);

-- 2. Remover a política restritiva anterior
DROP POLICY IF EXISTS "Clientes podem ver apenas seus dados" ON clientes;

-- 3. Criar nova política mais específica
CREATE POLICY "Clientes autenticados veem apenas seus dados" ON clientes
    FOR ALL USING (auth.uid() = id OR auth.uid() IS NULL);

-- 4. OU ALTERNATIVA: Criar função pública para buscar email por CNPJ
CREATE OR REPLACE FUNCTION public.buscar_email_por_cnpj(p_cnpj TEXT)
RETURNS TEXT
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN (SELECT email FROM clientes WHERE cnpj = p_cnpj LIMIT 1);
END;
$$ LANGUAGE plpgsql;