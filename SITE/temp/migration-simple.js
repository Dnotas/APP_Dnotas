const { createClient } = require('@supabase/supabase-js');

// Configurações do Supabase
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function executeMigrationSimple() {
  console.log('=== EXECUTANDO MIGRAÇÃO SIMPLIFICADA ===\n');

  try {
    // 1. Primeiro, vamos ver as tabelas que existem
    console.log('1. Verificando tabelas existentes...');
    
    const tablesToCheck = ['funcionarios', 'filiais', 'organizacoes', 'clientes'];
    
    for (const table of tablesToCheck) {
      const { data, error, count } = await supabase
        .from(table)
        .select('*', { count: 'exact' })
        .limit(1);
        
      if (error) {
        console.log(`❌ Tabela ${table} não existe ou erro:`, error.message);
      } else {
        console.log(`✅ Tabela ${table} existe - ${count} registros`);
      }
    }

    // 2. Vamos tentar criar dados na tabela organizacoes (se ela existir)
    console.log('\n2. Tentando inserir dados na tabela organizacoes...');
    
    // Primeiro, verificamos se a tabela organizacoes existe tentando fazer select
    const { data: orgTest, error: orgTestError } = await supabase
      .from('organizacoes')
      .select('*')
      .limit(1);
    
    if (orgTestError) {
      console.log('❌ Tabela organizacoes não existe ainda. Código:', orgTestError.code);
      console.log('Mensagem:', orgTestError.message);
      
      // Vamos tentar um approach diferente - usar a extensão postgres para executar SQL
      console.log('\n3. Tentando criar tabela via SQL...');
      
      // Usar a função sql do cliente supabase
      const createTableSQL = `
        CREATE TABLE IF NOT EXISTS organizacoes (
          id VARCHAR(50) PRIMARY KEY,
          nome VARCHAR(100) NOT NULL,
          tipo VARCHAR(20) CHECK (tipo IN ('matriz', 'filial')) NOT NULL,
          codigo VARCHAR(20),
          cnpj VARCHAR(18),
          endereco TEXT,
          telefone VARCHAR(20),
          email VARCHAR(100),
          responsavel VARCHAR(100),
          matriz_id VARCHAR(50),
          ativo BOOLEAN DEFAULT true,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      `;
      
      try {
        const { data: sqlResult, error: sqlError } = await supabase
          .rpc('sql', { query: createTableSQL });
        
        if (sqlError) {
          console.log('❌ Erro ao executar SQL:', sqlError);
          
          // Vamos mostrar instruções para execução manual
          console.log('\n=== INSTRUÇÕES PARA EXECUÇÃO MANUAL ===');
          console.log('Por favor, execute o seguinte SQL no painel do Supabase:');
          console.log('\nSQL Editor → Nova query → Cole e execute:');
          console.log('\n' + createTableSQL);
          console.log('\n=== FIM DAS INSTRUÇÕES ===\n');
        } else {
          console.log('✅ SQL executado com sucesso:', sqlResult);
        }
      } catch (err) {
        console.log('❌ Erro ao executar RPC SQL:', err.message);
      }
      
    } else {
      console.log('✅ Tabela organizacoes já existe!');
      
      // 4. Inserir dados básicos
      console.log('\n4. Inserindo dados básicos...');
      
      const organizacoes = [
        {
          id: 'matriz',
          nome: 'DNOTAS - Matriz',
          tipo: 'matriz',
          codigo: 'MATRIZ',
          cnpj: '12.345.678/0001-90',
          ativo: true
        },
        {
          id: 'filial_centro',
          nome: 'Filial Centro',
          tipo: 'filial',
          matriz_id: 'matriz',
          ativo: true
        },
        {
          id: 'filial_norte',
          nome: 'Filial Norte',
          tipo: 'filial',
          matriz_id: 'matriz',
          ativo: true
        },
        {
          id: 'filial_sul',
          nome: 'Filial Sul',
          tipo: 'filial',
          matriz_id: 'matriz',
          ativo: true
        }
      ];
      
      for (const org of organizacoes) {
        const { error: insertError } = await supabase
          .from('organizacoes')
          .upsert(org, { 
            onConflict: 'id',
            ignoreDuplicates: true
          });

        if (insertError) {
          console.log(`❌ Erro ao inserir ${org.id}:`, insertError.message);
        } else {
          console.log(`✅ Organização ${org.id} inserida/atualizada`);
        }
      }
    }

    // 5. Verificar estrutura da tabela funcionarios
    console.log('\n5. Verificando estrutura da tabela funcionarios...');
    
    const { data: funcionarios, error: funcError } = await supabase
      .from('funcionarios')
      .select('*')
      .limit(1);
    
    if (!funcError && funcionarios.length > 0) {
      console.log('✅ Tabela funcionarios existe. Colunas encontradas:');
      console.log(Object.keys(funcionarios[0]));
      
      // Verificar se já existe a coluna organizacao_id
      if (funcionarios[0].hasOwnProperty('organizacao_id')) {
        console.log('✅ Coluna organizacao_id já existe');
      } else {
        console.log('❌ Coluna organizacao_id não existe');
        console.log('\nSQL para adicionar a coluna:');
        console.log('ALTER TABLE funcionarios ADD COLUMN organizacao_id VARCHAR(50);');
      }
    } else {
      console.log('❌ Erro ao verificar funcionarios:', funcError?.message);
    }

    // 6. Criar usuário DNOTAS (sem organizacao_id se não existir)
    console.log('\n6. Criando usuário DNOTAS...');
    
    const userData = {
      nome: 'Administrador DNOTAS',
      email: 'DNOTAS',
      senha: 'D100*',
      cargo: 'Super Administrador',
      filial_id: 'matriz',
      role: 'admin',
      ativo: true
    };
    
    // Se a coluna organizacao_id existir, incluir
    if (funcionarios && funcionarios.length > 0 && funcionarios[0].hasOwnProperty('organizacao_id')) {
      userData.organizacao_id = 'matriz';
    }
    
    const { data: newUser, error: userError } = await supabase
      .from('funcionarios')
      .upsert(userData, { 
        onConflict: 'email',
        ignoreDuplicates: true
      })
      .select();

    if (userError) {
      console.log('❌ Erro ao criar usuário DNOTAS:', userError.message);
    } else {
      console.log('✅ Usuário DNOTAS criado/atualizado:', newUser);
    }

    // 7. Verificação final
    console.log('\n7. Verificação final - Login DNOTAS...');
    const { data: dnotasUser, error: verifyError } = await supabase
      .from('funcionarios')
      .select('*')
      .eq('email', 'DNOTAS');

    if (!verifyError && dnotasUser.length > 0) {
      console.log('✅ LOGIN DNOTAS ENCONTRADO:');
      console.log(JSON.stringify(dnotasUser[0], null, 2));
    } else {
      console.log('❌ Usuário DNOTAS não encontrado:', verifyError?.message);
    }

  } catch (error) {
    console.error('❌ Erro geral na migração:', error);
  }
}

executeMigrationSimple();