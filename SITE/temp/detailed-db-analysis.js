const { createClient } = require('@supabase/supabase-js');

// Configurações do Supabase
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function detailedAnalysis() {
  console.log('=== ANÁLISE DETALHADA DO BANCO DE DADOS ===\n');

  // 1. Verificar todas as tabelas do projeto
  const projectTables = [
    'funcionarios', 'filiais', 'organizacoes', 'atividades_funcionarios',
    'clientes', 'conversas', 'mensagens', 'solicitacoes_nf', 'boletos',
    'relatorios', 'notificacoes', 'auth_sessions'
  ];

  console.log('1. VERIFICANDO EXISTÊNCIA DAS TABELAS:\n');
  
  const existingTables = [];
  const missingTables = [];

  for (const table of projectTables) {
    const { data, error, count } = await supabase
      .from(table)
      .select('*', { count: 'exact' })
      .limit(1);
      
    if (error) {
      console.log(`❌ ${table} - NÃO EXISTE`);
      missingTables.push(table);
    } else {
      console.log(`✅ ${table} - EXISTE (${count} registros)`);
      existingTables.push(table);
    }
  }

  console.log(`\nTABELAS EXISTENTES: ${existingTables.length}`);
  console.log(`TABELAS FALTANDO: ${missingTables.length}`);
  console.log(`Faltando: ${missingTables.join(', ')}\n`);

  // 2. Análise detalhada das tabelas existentes
  console.log('2. ANÁLISE DETALHADA DAS TABELAS EXISTENTES:\n');

  for (const table of existingTables) {
    console.log(`=== TABELA: ${table.toUpperCase()} ===`);
    
    const { data, error, count } = await supabase
      .from(table)
      .select('*', { count: 'exact' })
      .limit(5);
      
    if (!error && data) {
      console.log(`Total de registros: ${count}`);
      
      if (data.length > 0) {
        // Mostrar estrutura das colunas
        const firstRecord = data[0];
        console.log('Colunas:');
        Object.keys(firstRecord).forEach(col => {
          const value = firstRecord[col];
          const type = value === null ? 'NULL' : typeof value;
          console.log(`  - ${col}: ${type}`);
        });
        
        console.log('\nPrimeiros registros:');
        data.forEach((record, index) => {
          console.log(`  [${index + 1}] ${JSON.stringify(record, null, 4)}`);
        });
      } else {
        console.log('Tabela vazia');
      }
    }
    console.log('\n' + '='.repeat(50) + '\n');
  }

  // 3. Verificar se existe usuário DNOTAS
  console.log('3. VERIFICANDO USUÁRIO DNOTAS:\n');
  
  const { data: dnotasUser, error: dnotasError } = await supabase
    .from('funcionarios')
    .select('*')
    .eq('email', 'DNOTAS');
    
  if (dnotasError) {
    console.log('❌ Erro ao buscar DNOTAS:', dnotasError.message);
  } else if (dnotasUser && dnotasUser.length > 0) {
    console.log('✅ Usuário DNOTAS encontrado:', JSON.stringify(dnotasUser, null, 2));
  } else {
    console.log('❌ Usuário DNOTAS NÃO ENCONTRADO');
  }

  // 4. Verificar funcionários por filial
  console.log('\n4. DISTRIBUIÇÃO DE FUNCIONÁRIOS POR FILIAL:\n');
  
  const { data: funcionariosPorFilial, error: filialError } = await supabase
    .from('funcionarios')
    .select('filial_id, nome, email, cargo, role');
    
  if (!filialError && funcionariosPorFilial) {
    const filiais = {};
    funcionariosPorFilial.forEach(func => {
      if (!filiais[func.filial_id]) {
        filiais[func.filial_id] = [];
      }
      filiais[func.filial_id].push(func);
    });
    
    Object.keys(filiais).forEach(filialId => {
      console.log(`FILIAL: ${filialId} (${filiais[filialId].length} funcionários)`);
      filiais[filialId].forEach(func => {
        console.log(`  - ${func.nome} (${func.email}) - ${func.cargo} [${func.role}]`);
      });
      console.log('');
    });
  }

  console.log('=== FIM DA ANÁLISE ===');
}

detailedAnalysis().catch(console.error);