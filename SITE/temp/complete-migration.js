const { createClient } = require('@supabase/supabase-js');

// Configurações do Supabase
const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function completeAfterManualSQL() {
  console.log('=== COMPLETANDO MIGRAÇÃO APÓS EXECUÇÃO MANUAL DO SQL ===\n');

  try {
    // 1. Verificar se a tabela organizacoes foi criada
    console.log('1. Verificando tabela organizacoes...');
    const { data: orgs, error: orgError, count: orgCount } = await supabase
      .from('organizacoes')
      .select('*', { count: 'exact' });
    
    if (orgError) {
      console.log('❌ Tabela organizacoes ainda não existe. Execute primeiro o SQL manual!');
      console.log('Erro:', orgError.message);
      return;
    } else {
      console.log(`✅ Tabela organizacoes existe com ${orgCount} registros`);
      if (orgs.length > 0) {
        console.log('Organizações encontradas:');
        orgs.forEach(org => {
          console.log(`  - ${org.id}: ${org.nome} (${org.tipo})`);
        });
      }
    }

    // 2. Inserir dados se a tabela estiver vazia
    if (orgCount === 0) {
      console.log('\n2. Inserindo dados iniciais na tabela organizacoes...');
      
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
          .insert(org);

        if (insertError) {
          console.log(`❌ Erro ao inserir ${org.id}:`, insertError.message);
        } else {
          console.log(`✅ Organização ${org.id} inserida`);
        }
      }
    }

    // 3. Migrar filiais existentes para organizacoes
    console.log('\n3. Migrando filiais existentes...');
    const { data: filiais, error: filiaisError } = await supabase
      .from('filiais')
      .select('*');
    
    if (!filiaisError && filiais) {
      console.log(`Encontradas ${filiais.length} filiais para migrar`);
      
      for (const filial of filiais) {
        // Verificar se já existe
        const { data: existente } = await supabase
          .from('organizacoes')
          .select('id')
          .eq('id', filial.id)
          .single();
        
        if (!existente) {
          const { error: migrateError } = await supabase
            .from('organizacoes')
            .insert({
              id: filial.id,
              nome: filial.nome,
              tipo: 'filial',
              matriz_id: 'matriz',
              ativo: filial.ativo
            });
            
          if (migrateError) {
            console.log(`❌ Erro ao migrar filial ${filial.id}:`, migrateError.message);
          } else {
            console.log(`✅ Filial ${filial.id} migrada`);
          }
        } else {
          console.log(`⚠️ Filial ${filial.id} já existe em organizacoes`);
        }
      }
    }

    // 4. Verificar se a coluna organizacao_id foi adicionada
    console.log('\n4. Verificando coluna organizacao_id em funcionarios...');
    const { data: funcionarios, error: funcError } = await supabase
      .from('funcionarios')
      .select('*')
      .limit(1);
    
    if (!funcError && funcionarios.length > 0) {
      const colunas = Object.keys(funcionarios[0]);
      console.log('Colunas da tabela funcionarios:', colunas);
      
      if (colunas.includes('organizacao_id')) {
        console.log('✅ Coluna organizacao_id existe');
        
        // 5. Migrar filial_id para organizacao_id
        console.log('\n5. Migrando filial_id para organizacao_id...');
        const { data: todosFunc, error: todosFuncError } = await supabase
          .from('funcionarios')
          .select('id, filial_id, organizacao_id');
        
        if (!todosFuncError) {
          for (const func of todosFunc) {
            if (func.filial_id && !func.organizacao_id) {
              const { error: updateError } = await supabase
                .from('funcionarios')
                .update({ organizacao_id: func.filial_id })
                .eq('id', func.id);
                
              if (updateError) {
                console.log(`❌ Erro ao migrar funcionário ${func.id}:`, updateError.message);
              } else {
                console.log(`✅ Funcionário ${func.id} migrado (${func.filial_id} → organizacao_id)`);
              }
            }
          }
        }
        
      } else {
        console.log('❌ Coluna organizacao_id não existe. Execute o SQL manual primeiro!');
      }
    }

    // 6. Atualizar usuário DNOTAS com organizacao_id se necessário
    console.log('\n6. Verificando usuário DNOTAS...');
    const { data: dnotasUser, error: dnotasError } = await supabase
      .from('funcionarios')
      .select('*')
      .eq('email', 'DNOTAS')
      .single();

    if (!dnotasError && dnotasUser) {
      console.log('✅ Usuário DNOTAS encontrado');
      
      if (dnotasUser.hasOwnProperty('organizacao_id') && !dnotasUser.organizacao_id) {
        console.log('Atualizando organizacao_id do usuário DNOTAS...');
        const { error: updateDnotasError } = await supabase
          .from('funcionarios')
          .update({ organizacao_id: 'matriz' })
          .eq('email', 'DNOTAS');
          
        if (updateDnotasError) {
          console.log('❌ Erro ao atualizar DNOTAS:', updateDnotasError.message);
        } else {
          console.log('✅ Usuário DNOTAS atualizado com organizacao_id = matriz');
        }
      }
    } else {
      console.log('❌ Usuário DNOTAS não encontrado:', dnotasError?.message);
    }

    // 7. Relatório final
    console.log('\n=== RELATÓRIO FINAL ===');
    
    // Contar organizações
    const { count: totalOrgs } = await supabase
      .from('organizacoes')
      .select('*', { count: 'exact', head: true });
    console.log(`✅ Total de organizações: ${totalOrgs}`);
    
    // Contar funcionários
    const { count: totalFunc } = await supabase
      .from('funcionarios')
      .select('*', { count: 'exact', head: true });
    console.log(`✅ Total de funcionários: ${totalFunc}`);
    
    // Verificar login DNOTAS final
    const { data: finalUser, error: finalError } = await supabase
      .from('funcionarios')
      .select('nome, email, cargo, filial_id, organizacao_id, ativo')
      .eq('email', 'DNOTAS')
      .single();
    
    if (!finalError && finalUser) {
      console.log('\n✅ LOGIN DNOTAS CONFIGURADO:');
      console.log(`   Email: ${finalUser.email}`);
      console.log(`   Senha: D100*`);
      console.log(`   Nome: ${finalUser.nome}`);
      console.log(`   Cargo: ${finalUser.cargo}`);
      console.log(`   Filial ID: ${finalUser.filial_id}`);
      console.log(`   Organização ID: ${finalUser.organizacao_id || 'Não definido'}`);
      console.log(`   Ativo: ${finalUser.ativo}`);
      
      console.log('\n🎉 MIGRAÇÃO CONCLUÍDA COM SUCESSO!');
      console.log('Agora você pode fazer login no sistema com:');
      console.log('   Login: DNOTAS');
      console.log('   Senha: D100*');
    } else {
      console.log('❌ Erro ao verificar usuário final:', finalError?.message);
    }

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

completeAfterManualSQL();