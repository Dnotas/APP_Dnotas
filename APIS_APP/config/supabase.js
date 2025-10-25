// Configuração do Supabase para a API
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// URL e chave do Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ ERRO: Variáveis de ambiente SUPABASE_URL e SUPABASE_ANON_KEY não estão definidas');
    console.log('ℹ️ Certifique-se de ter um arquivo .env com:');
    console.log('SUPABASE_URL=https://seu-projeto.supabase.co');
    console.log('SUPABASE_ANON_KEY=sua-chave-anonima');
    process.exit(1);
}

// Criar cliente do Supabase
const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
    }
});

console.log('✅ Cliente Supabase configurado com sucesso');

module.exports = {
    supabase,
    supabaseUrl,
    supabaseKey
};