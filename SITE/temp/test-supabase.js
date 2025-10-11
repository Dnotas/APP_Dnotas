const { createClient } = require('@supabase/supabase-js');

// Configurações do Supabase
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function investigateDatabase() {
  console.log('=== INVESTIGANDO ESTRUTURA DO BANCO DE DADOS ===\n');

  try {
    // 1. Verificar tabelas existentes usando information_schema
    console.log('1. CONSULTANDO TABELAS EXISTENTES:');
    const { data: tables, error: tablesError } = await supabase
      .rpc('get_tables');
    
    if (tablesError) {
      console.log('Erro ao consultar tabelas:', tablesError);
      
      // Tentar método alternativo - listar usando SELECT direto
      console.log('\nTentando método alternativo...');
      
      // Testar conexão básica
      const { data: testData, error: testError } = await supabase
        .from('funcionarios')
        .select('*')
        .limit(1);
        
      if (testError) {
        console.log('Erro na conexão básica:', testError);
      } else {
        console.log('Conexão funcionando! Dados de teste:', testData);
      }
    } else {
      console.log('Tabelas encontradas:', tables);
    }

    // 2. Testar tabelas específicas
    console.log('\n2. TESTANDO TABELAS ESPECÍFICAS:');
    
    const tablesToTest = ['funcionarios', 'filiais', 'organizacoes', 'atividades_funcionarios'];
    
    for (const table of tablesToTest) {
      console.log(`\n--- Testando tabela: ${table} ---`);
      
      const { data, error, count } = await supabase
        .from(table)
        .select('*', { count: 'exact' })
        .limit(3);
        
      if (error) {
        console.log(`❌ Erro na tabela ${table}:`, error.message);
      } else {
        console.log(`✅ Tabela ${table} existe - Total de registros: ${count}`);
        if (data && data.length > 0) {
          console.log('Primeiros registros:', JSON.stringify(data, null, 2));
        }
      }
    }

    // 3. Verificar estrutura das colunas (se possível)
    console.log('\n3. VERIFICANDO ESTRUTURA DAS COLUNAS:');
    
    const { data: funcionariosColumns, error: colError } = await supabase
      .from('funcionarios')
      .select('*')
      .limit(0); // Só queremos o schema, não os dados
      
    if (!colError) {
      console.log('Estrutura da tabela funcionarios obtida com sucesso');
    }

  } catch (error) {
    console.error('Erro geral:', error);
  }
}

investigateDatabase();