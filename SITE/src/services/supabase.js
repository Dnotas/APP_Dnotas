import { createClient } from '@supabase/supabase-js'

// Configuração do Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.sPk51xxT7KBFp0_KC674PS62nwXNtBpo7UCKRm6ZEeY'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false,
    detectSessionInUrl: false,
    autoRefreshToken: false
  }
})

// Função para testar conexão
export async function testarConexao() {
  try {
    console.log('🔄 Testando conexão com Supabase...')
    console.log('URL:', supabaseUrl)
    console.log('Key (primeiros 20 chars):', supabaseAnonKey.substring(0, 20) + '...')
    
    // Teste 1: Verificar se o cliente foi criado corretamente
    if (!supabase) {
      console.error('❌ Cliente Supabase não foi criado')
      return false
    }
    
    console.log('✅ Cliente Supabase criado com sucesso')
    
    // Teste 2: Tentar uma consulta SQL simples (não depende de RLS)
    const { data, error } = await supabase.rpc('current_database')
    
    if (error) {
      console.error('❌ Erro na função RPC:', error)
      
      // Teste alternativo - tentar acessar tabela diretamente
      console.log('🔄 Tentando teste alternativo...')
      const { data: data2, error: error2 } = await supabase
        .from('clientes')
        .select('id')
        .limit(0) // Não pegar nenhum registro, só testar acesso
      
      if (error2) {
        console.error('❌ Erro na tabela clientes:', error2)
        console.error('Status HTTP:', error2.code)
        console.error('Mensagem:', error2.message)
        
        // Se for erro 400, pode ser problema de RLS
        if (error2.code === 'PGRST116' || error2.message?.includes('RLS')) {
          console.error('🔒 Problema de RLS detectado!')
          console.error('Execute o SQL: corrigir_rls_supabase.sql')
        }
        
        return false
      }
      
      console.log('✅ Teste alternativo OK!')
      return true
    }
    
    console.log('✅ Conexão OK! Database:', data)
    return true
  } catch (err) {
    console.error('❌ Erro na conexão (catch):', err)
    return false
  }
}