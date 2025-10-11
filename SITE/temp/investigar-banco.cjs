const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.SDLuKQmwJu8gXEJX8CNMV5XVVFPnWNxklcfyOqnVtgw'

const supabase = createClient(supabaseUrl, supabaseKey)

async function investigarEstruturaBanco() {
  console.log('=== INVESTIGANDO ESTRUTURA DO BANCO ===')
  
  try {
    // 1. Verificar tabelas existentes - testando diferentes nomes
    console.log('\n1. TESTANDO TABELA FILIAIS:')
    const { data: filiais, error: errorFiliais } = await supabase
      .from('filiais')
      .select('*')
      .limit(5)
    
    console.log('Filiais encontradas:', filiais)
    console.log('Erro filiais:', errorFiliais)
    
    // 2. Verificar estrutura da tabela funcionarios
    console.log('\n2. TESTANDO TABELA FUNCIONARIOS:')
    const { data: funcionarios, error: errorFuncionarios } = await supabase
      .from('funcionarios')
      .select('*')
      .limit(5)
    
    console.log('Funcionários encontrados:', funcionarios)
    console.log('Erro funcionários:', errorFuncionarios)
    
    // 3. Testar se existe tabela organizacoes
    console.log('\n3. TESTANDO TABELA ORGANIZACOES:')
    const { data: organizacoes, error: errorOrganizacoes } = await supabase
      .from('organizacoes')
      .select('*')
      .limit(5)
    
    console.log('Organizações encontradas:', organizacoes)
    console.log('Erro organizações:', errorOrganizacoes)

    // 4. Testar tabela atividades_funcionarios
    console.log('\n4. TESTANDO TABELA ATIVIDADES_FUNCIONARIOS:')
    const { data: atividades, error: errorAtividades } = await supabase
      .from('atividades_funcionarios')
      .select('*')
      .limit(5)
    
    console.log('Atividades encontradas:', atividades)
    console.log('Erro atividades:', errorAtividades)

    // 5. Verificar se existe funcionário DNOTAS
    console.log('\n5. VERIFICANDO LOGIN DNOTAS:')
    const { data: loginDnotas, error: errorDnotas } = await supabase
      .from('funcionarios')
      .select('*')
      .eq('email', 'DNOTAS')
    
    console.log('Login DNOTAS encontrado:', loginDnotas)
    console.log('Erro DNOTAS:', errorDnotas)
    
    // 6. Contar registros
    console.log('\n6. CONTANDO REGISTROS:')
    const { count: countFiliais } = await supabase
      .from('filiais')
      .select('*', { count: 'exact', head: true })
    
    const { count: countFuncionarios } = await supabase
      .from('funcionarios')
      .select('*', { count: 'exact', head: true })
    
    const { count: countOrganizacoes } = await supabase
      .from('organizacoes')
      .select('*', { count: 'exact', head: true })
    
    console.log(`Total filiais: ${countFiliais}`)
    console.log(`Total funcionários: ${countFuncionarios}`)
    console.log(`Total organizações: ${countOrganizacoes}`)

    // 7. Verificar estrutura das colunas (usando uma query simples)
    console.log('\n7. VERIFICANDO ESTRUTURA DAS TABELAS:')
    
    // Testar campos específicos para descobrir estrutura
    if (filiais && filiais.length > 0) {
      console.log('Campos da tabela filiais:', Object.keys(filiais[0]))
    }
    
    if (funcionarios && funcionarios.length > 0) {
      console.log('Campos da tabela funcionarios:', Object.keys(funcionarios[0]))
    }
    
    if (organizacoes && organizacoes.length > 0) {
      console.log('Campos da tabela organizacoes:', Object.keys(organizacoes[0]))
    }

    // 8. Testar joins para verificar foreign keys
    console.log('\n8. TESTANDO RELACIONAMENTOS:')
    
    // Teste funcionarios -> filiais
    const { data: funcFiliais, error: errorFuncFiliais } = await supabase
      .from('funcionarios')
      .select('id, nome, email, filial_id, filiais(nome)')
      .limit(3)
    
    console.log('Funcionários com filiais:', funcFiliais)
    console.log('Erro func-filiais:', errorFuncFiliais)

    // Teste funcionarios -> organizacoes
    const { data: funcOrgs, error: errorFuncOrgs } = await supabase
      .from('funcionarios')
      .select('id, nome, email, organizacao_id, organizacoes(nome)')
      .limit(3)
    
    console.log('Funcionários com organizações:', funcOrgs)
    console.log('Erro func-organizações:', errorFuncOrgs)
    
  } catch (error) {
    console.error('Erro na investigação:', error)
  }
}

// Executar investigação
investigarEstruturaBanco()