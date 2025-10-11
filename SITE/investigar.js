// Script para investigar estrutura do banco Supabase
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.SDLuKQmwJu8gXEJX8CNMV5XVVFPnWNxklcfyOqnVtgw'

const supabase = createClient(supabaseUrl, supabaseKey)

async function investigarBanco() {
  console.log('=== INVESTIGANDO ESTRUTURA DO BANCO SUPABASE ===\n')
  
  try {
    // 1. Testar tabela filiais
    console.log('1. TABELA FILIAIS:')
    const { data: filiais, error: errorFiliais } = await supabase
      .from('filiais')
      .select('*')
      .limit(3)
    
    if (errorFiliais) {
      console.log('   ❌ Erro:', errorFiliais.message)
    } else {
      console.log('   ✅ Filiais encontradas:', filiais?.length || 0)
      if (filiais && filiais.length > 0) {
        console.log('   Estrutura:', Object.keys(filiais[0]))
        console.log('   Amostra:', filiais[0])
      }
    }
    
    // 2. Testar tabela funcionarios
    console.log('\n2. TABELA FUNCIONARIOS:')
    const { data: funcionarios, error: errorFuncionarios } = await supabase
      .from('funcionarios')
      .select('*')
      .limit(3)
    
    if (errorFuncionarios) {
      console.log('   ❌ Erro:', errorFuncionarios.message)
    } else {
      console.log('   ✅ Funcionários encontrados:', funcionarios?.length || 0)
      if (funcionarios && funcionarios.length > 0) {
        console.log('   Estrutura:', Object.keys(funcionarios[0]))
        console.log('   Amostra:', funcionarios[0])
      }
    }
    
    // 3. Testar tabela organizacoes
    console.log('\n3. TABELA ORGANIZACOES:')
    const { data: organizacoes, error: errorOrganizacoes } = await supabase
      .from('organizacoes')
      .select('*')
      .limit(3)
    
    if (errorOrganizacoes) {
      console.log('   ❌ Erro:', errorOrganizacoes.message)
    } else {
      console.log('   ✅ Organizações encontradas:', organizacoes?.length || 0)
      if (organizacoes && organizacoes.length > 0) {
        console.log('   Estrutura:', Object.keys(organizacoes[0]))
        console.log('   Amostra:', organizacoes[0])
      }
    }
    
    // 4. Verificar funcionário DNOTAS
    console.log('\n4. LOGIN DNOTAS:')
    const { data: dnotas, error: errorDnotas } = await supabase
      .from('funcionarios')
      .select('*')
      .eq('email', 'DNOTAS')
    
    if (errorDnotas) {
      console.log('   ❌ Erro:', errorDnotas.message)
    } else {
      console.log('   ✅ DNOTAS encontrado:', dnotas?.length || 0)
      if (dnotas && dnotas.length > 0) {
        console.log('   Dados:', dnotas[0])
      }
    }
    
    // 5. Contadores
    console.log('\n5. TOTAIS:')
    
    const { count: countFiliais } = await supabase
      .from('filiais')
      .select('*', { count: 'exact', head: true })
    console.log(`   Filiais: ${countFiliais}`)
    
    const { count: countFuncionarios } = await supabase
      .from('funcionarios')
      .select('*', { count: 'exact', head: true })
    console.log(`   Funcionários: ${countFuncionarios}`)
    
  } catch (error) {
    console.error('❌ Erro na investigação:', error)
  }
}

// Executar
investigarBanco().then(() => {
  console.log('\n=== INVESTIGAÇÃO CONCLUÍDA ===')
  process.exit(0)
}).catch(console.error)