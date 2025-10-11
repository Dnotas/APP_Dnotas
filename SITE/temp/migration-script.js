const { createClient } = require('@supabase/supabase-js');

// Configurações do Supabase
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function executeMigration() {
  console.log('=== EXECUTANDO MIGRAÇÃO SQL ===\n');

  try {
    // 1. CRIAR TABELA ORGANIZACOES
    console.log('1. Criando tabela organizacoes...');
    const createOrgTable = `
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
    
    const { error: createError } = await supabase.rpc('exec_sql', { sql: createOrgTable });
    if (createError) {
      console.log('❌ Erro ao criar tabela organizacoes:', createError);
    } else {
      console.log('✅ Tabela organizacoes criada/verificada');
    }

    // 2. INSERIR MATRIZ PRINCIPAL
    console.log('\n2. Inserindo matriz principal...');
    const { error: insertMatrizError } = await supabase
      .from('organizacoes')
      .upsert({
        id: 'matriz',
        nome: 'DNOTAS - Matriz',
        tipo: 'matriz',
        codigo: 'MATRIZ',
        cnpj: '12.345.678/0001-90',
        ativo: true
      }, { 
        onConflict: 'id',
        ignoreDuplicates: true
      });

    if (insertMatrizError) {
      console.log('❌ Erro ao inserir matriz:', insertMatrizError);
    } else {
      console.log('✅ Matriz principal inserida/verificada');
    }

    // 3. MIGRAR FILIAIS EXISTENTES PARA ORGANIZACOES
    console.log('\n3. Migrando filiais existentes...');
    
    // Primeiro, vamos verificar se a tabela filiais existe
    const { data: filiaisData, error: filiaisError } = await supabase
      .from('filiais')
      .select('*');
    
    if (!filiaisError && filiaisData) {
      console.log(`Encontradas ${filiaisData.length} filiais para migrar`);
      
      for (const filial of filiaisData) {
        const { error: migrateError } = await supabase
          .from('organizacoes')
          .upsert({
            id: filial.id,
            nome: filial.nome,
            tipo: 'filial',
            matriz_id: 'matriz',
            ativo: filial.ativo
          }, { 
            onConflict: 'id',
            ignoreDuplicates: true
          });
          
        if (migrateError) {
          console.log(`❌ Erro ao migrar filial ${filial.id}:`, migrateError);
        } else {
          console.log(`✅ Filial ${filial.id} migrada`);
        }
      }
    } else {
      console.log('⚠️ Tabela filiais não encontrada ou vazia');
    }

    // 4. INSERIR FILIAIS PADRÃO
    console.log('\n4. Inserindo filiais padrão...');
    const filiaisPadrao = [
      { id: 'filial_centro', nome: 'Filial Centro' },
      { id: 'filial_norte', nome: 'Filial Norte' },
      { id: 'filial_sul', nome: 'Filial Sul' }
    ];
    
    for (const filial of filiaisPadrao) {
      const { error: insertFilialError } = await supabase
        .from('organizacoes')
        .upsert({
          id: filial.id,
          nome: filial.nome,
          tipo: 'filial',
          matriz_id: 'matriz',
          ativo: true
        }, { 
          onConflict: 'id',
          ignoreDuplicates: true
        });

      if (insertFilialError) {
        console.log(`❌ Erro ao inserir filial ${filial.id}:`, insertFilialError);
      } else {
        console.log(`✅ Filial ${filial.id} inserida`);
      }
    }

    // 5. ADICIONAR COLUNA organizacao_id À TABELA funcionarios
    console.log('\n5. Adicionando coluna organizacao_id...');
    const addColumnSQL = `
      ALTER TABLE funcionarios 
      ADD COLUMN IF NOT EXISTS organizacao_id VARCHAR(50);
    `;
    
    const { error: addColumnError } = await supabase.rpc('exec_sql', { sql: addColumnSQL });
    if (addColumnError) {
      console.log('❌ Erro ao adicionar coluna organizacao_id:', addColumnError);
    } else {
      console.log('✅ Coluna organizacao_id adicionada/verificada');
    }

    // 6. MIGRAR filial_id PARA organizacao_id
    console.log('\n6. Migrando filial_id para organizacao_id...');
    const { data: funcionarios, error: funcError } = await supabase
      .from('funcionarios')
      .select('id, filial_id, organizacao_id');
    
    if (!funcError && funcionarios) {
      for (const func of funcionarios) {
        if (func.filial_id && !func.organizacao_id) {
          const { error: updateError } = await supabase
            .from('funcionarios')
            .update({ organizacao_id: func.filial_id })
            .eq('id', func.id);
            
          if (updateError) {
            console.log(`❌ Erro ao migrar funcionário ${func.id}:`, updateError);
          }
        }
      }
      console.log('✅ Migração filial_id → organizacao_id concluída');
    } else {
      console.log('⚠️ Erro ao consultar funcionários:', funcError);
    }

    // 7. CRIAR USUÁRIO DNOTAS
    console.log('\n7. Criando usuário DNOTAS...');
    const { error: createUserError } = await supabase
      .from('funcionarios')
      .upsert({
        nome: 'Administrador DNOTAS',
        email: 'DNOTAS',
        senha: 'D100*',
        cargo: 'Super Administrador',
        filial_id: 'matriz',
        organizacao_id: 'matriz',
        role: 'admin',
        ativo: true
      }, { 
        onConflict: 'email',
        ignoreDuplicates: true
      });

    if (createUserError) {
      console.log('❌ Erro ao criar usuário DNOTAS:', createUserError);
    } else {
      console.log('✅ Usuário DNOTAS criado/verificado');
    }

    // 8. VERIFICAÇÃO FINAL
    console.log('\n8. Verificação final...');
    const { data: dnotasUser, error: verifyError } = await supabase
      .from('funcionarios')
      .select('*')
      .eq('email', 'DNOTAS')
      .single();

    if (!verifyError && dnotasUser) {
      console.log('✅ LOGIN DNOTAS CRIADO COM SUCESSO:');
      console.log(JSON.stringify(dnotasUser, null, 2));
    } else {
      console.log('❌ Erro na verificação:', verifyError);
    }

    // Verificar organizações criadas
    const { data: orgs, error: orgsError } = await supabase
      .from('organizacoes')
      .select('*');

    if (!orgsError && orgs) {
      console.log(`\n✅ Total de organizações criadas: ${orgs.length}`);
      orgs.forEach(org => {
        console.log(`  - ${org.id}: ${org.nome} (${org.tipo})`);
      });
    }

  } catch (error) {
    console.error('❌ Erro geral na migração:', error);
  }
}

// Função auxiliar para criar RPC exec_sql se não existir
async function createExecSqlFunction() {
  console.log('Criando função exec_sql...');
  
  const createFunctionSQL = `
    CREATE OR REPLACE FUNCTION exec_sql(sql text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS $$
    BEGIN
      EXECUTE sql;
    END;
    $$;
  `;
  
  try {
    const { error } = await supabase.rpc('exec_sql', { sql: createFunctionSQL });
    if (error) {
      console.log('Função exec_sql pode não existir ainda, continuando...');
    }
  } catch (err) {
    console.log('Tentando criar função exec_sql via SQL direto...');
  }
}

// Executar migração
createExecSqlFunction().then(() => {
  executeMigration();
});