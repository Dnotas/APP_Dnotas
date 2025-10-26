import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.sPk51xxT7KBFp0_KC674PS62nwXNtBpo7UCKRm6ZEeY'

const supabase = createClient(supabaseUrl, supabaseKey)

async function investigarEstruturaChat() {
  console.log('=== INVESTIGANDO ESTRUTURA DAS TABELAS DE CHAT ===\n')
  
  try {
    // 1. Verificar se existem conversas
    console.log('1. VERIFICANDO CONVERSAS EXISTENTES:')
    const { data: conversas, error: conversasError } = await supabase
      .from('chat_conversations')
      .select('*')
      .limit(5)
    
    if (conversasError) {
      console.error('Erro ao buscar conversas:', conversasError)
    } else {
      console.log(`Total de conversas encontradas: ${conversas?.length || 0}`)
      if (conversas && conversas.length > 0) {
        console.log('Primeira conversa:', JSON.stringify(conversas[0], null, 2))
      }
    }
    
    console.log('\n' + '='.repeat(50) + '\n')
    
    // 2. Verificar mensagens
    console.log('2. VERIFICANDO MENSAGENS EXISTENTES:')
    const { data: mensagens, error: mensagensError } = await supabase
      .from('chat_messages')
      .select('*')
      .limit(5)
    
    if (mensagensError) {
      console.error('Erro ao buscar mensagens:', mensagensError)
    } else {
      console.log(`Total de mensagens encontradas: ${mensagens?.length || 0}`)
      if (mensagens && mensagens.length > 0) {
        console.log('Primeira mensagem:', JSON.stringify(mensagens[0], null, 2))
      }
    }
    
    console.log('\n' + '='.repeat(50) + '\n')
    
    // 3. Verificar estrutura das tabelas
    console.log('3. VERIFICANDO ESTRUTURA DAS TABELAS:')
    
    // Tentar diferentes consultas para entender a estrutura
    console.log('\n--- Tentando buscar conversa específica mencionada no log ---')
    const { data: conversaEspecifica, error: conversaError } = await supabase
      .from('chat_conversations')
      .select('*')
      .eq('id', '852ffc08-0d02-4f2d-8abb-901d8f665cf4')
    
    if (conversaError) {
      console.error('Erro ao buscar conversa específica:', conversaError)
    } else {
      console.log('Conversa específica encontrada:', JSON.stringify(conversaEspecifica, null, 2))
    }
    
    console.log('\n--- Verificando cliente UAI SORVETES ---')
    const { data: cliente, error: clienteError } = await supabase
      .from('clientes')
      .select('*')
      .ilike('nome_empresa', '%UAI SORVETES%')
    
    if (clienteError) {
      console.error('Erro ao buscar cliente:', clienteError)
    } else {
      console.log('Cliente encontrado:', JSON.stringify(cliente, null, 2))
    }
    
    console.log('\n' + '='.repeat(50) + '\n')
    
    // 4. Verificar organizações
    console.log('4. VERIFICANDO ORGANIZAÇÕES:')
    const { data: organizacoes, error: orgError } = await supabase
      .from('organizacoes')
      .select('*')
    
    if (orgError) {
      console.error('Erro ao buscar organizações:', orgError)
    } else {
      console.log('Organizações encontradas:')
      organizacoes?.forEach(org => {
        console.log(`- ${org.nome} (ID: ${org.id}, Tipo: ${org.tipo})`)
      })
    }
    
    console.log('\n' + '='.repeat(50) + '\n')
    
    // 5. Verificar funcionários
    console.log('5. VERIFICANDO FUNCIONÁRIOS:')
    const { data: funcionarios, error: funcError } = await supabase
      .from('funcionarios')
      .select('id, nome, organizacao_id')
    
    if (funcError) {
      console.error('Erro ao buscar funcionários:', funcError)
    } else {
      console.log('Funcionários encontrados:')
      funcionarios?.forEach(func => {
        console.log(`- ${func.nome} (ID: ${func.id}, Org: ${func.organizacao_id})`)
      })
    }
    
  } catch (error) {
    console.error('Erro geral:', error)
  }
}

// Executar investigação
investigarEstruturaChat().then(() => {
  console.log('\n=== FIM DA INVESTIGAÇÃO ===')
  process.exit(0)
})