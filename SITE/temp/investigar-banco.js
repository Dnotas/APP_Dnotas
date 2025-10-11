"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.investigarEstruturaBanco = investigarEstruturaBanco;
const supabase_js_1 = require("@supabase/supabase-js");
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.SDLuKQmwJu8gXEJX8CNMV5XVVFPnWNxklcfyOqnVtgw';
const supabase = (0, supabase_js_1.createClient)(supabaseUrl, supabaseKey);
async function investigarEstruturaBanco() {
    console.log('=== INVESTIGANDO ESTRUTURA DO BANCO ===');
    try {
        // 1. Verificar tabelas existentes
        console.log('\n1. TESTANDO TABELA FILIAIS:');
        const { data: filiais, error: errorFiliais } = await supabase
            .from('filiais')
            .select('*')
            .limit(5);
        console.log('Filiais encontradas:', filiais);
        console.log('Erro filiais:', errorFiliais);
        // 2. Verificar estrutura da tabela funcionarios
        console.log('\n2. TESTANDO TABELA FUNCIONARIOS:');
        const { data: funcionarios, error: errorFuncionarios } = await supabase
            .from('funcionarios')
            .select('*')
            .limit(5);
        console.log('Funcionários encontrados:', funcionarios);
        console.log('Erro funcionários:', errorFuncionarios);
        // 3. Testar se existe tabela organizacoes
        console.log('\n3. TESTANDO TABELA ORGANIZACOES:');
        const { data: organizacoes, error: errorOrganizacoes } = await supabase
            .from('organizacoes')
            .select('*')
            .limit(5);
        console.log('Organizações encontradas:', organizacoes);
        console.log('Erro organizações:', errorOrganizacoes);
        // 4. Verificar se existe funcionário DNOTAS
        console.log('\n4. VERIFICANDO LOGIN DNOTAS:');
        const { data: loginDnotas, error: errorDnotas } = await supabase
            .from('funcionarios')
            .select('*')
            .eq('email', 'DNOTAS');
        console.log('Login DNOTAS encontrado:', loginDnotas);
        console.log('Erro DNOTAS:', errorDnotas);
        // 5. Contar registros
        console.log('\n5. CONTANDO REGISTROS:');
        const { count: countFiliais } = await supabase
            .from('filiais')
            .select('*', { count: 'exact', head: true });
        const { count: countFuncionarios } = await supabase
            .from('funcionarios')
            .select('*', { count: 'exact', head: true });
        console.log(`Total filiais: ${countFiliais}`);
        console.log(`Total funcionários: ${countFuncionarios}`);
    }
    catch (error) {
        console.error('Erro na investigação:', error);
    }
}
// Executar investigação
investigarEstruturaBanco();
