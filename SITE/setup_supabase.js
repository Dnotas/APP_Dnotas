// Script para configurar as tabelas no Supabase
import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.0t3OdgR_eoqBWwqcWdK6O1VNrJFJLZAHU8oQpIDCvkI' // Service role key

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function setupTables() {
  try {
    console.log('🚀 Configurando tabelas no Supabase...')
    
    // Verificar se as tabelas existem
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .in('table_name', ['organizacoes', 'funcionarios', 'atividades_funcionarios'])
    
    if (tablesError) {
      console.error('Erro ao verificar tabelas:', tablesError)
      return
    }
    
    const existingTables = tables.map(t => t.table_name)
    console.log('📋 Tabelas existentes:', existingTables)
    
    // Criar organizações se não existir
    if (!existingTables.includes('organizacoes')) {
      console.log('➕ Criando tabela organizacoes...')
      
      const { error: orgError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE TABLE organizacoes (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            tipo VARCHAR(10) CHECK (tipo IN ('matriz', 'filial')) NOT NULL,
            codigo VARCHAR(20) UNIQUE,
            cnpj VARCHAR(14),
            endereco TEXT,
            telefone VARCHAR(20),
            email VARCHAR(100),
            responsavel VARCHAR(100),
            matriz_id VARCHAR(50),
            ativo BOOLEAN DEFAULT true NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
        `
      })
      
      if (orgError) {
        console.error('Erro ao criar tabela organizacoes:', orgError)
      } else {
        console.log('✅ Tabela organizacoes criada!')
      }
    }
    
    // Inserir dados padrão das organizações
    console.log('📝 Inserindo organizações padrão...')
    const { error: insertOrgError } = await supabase
      .from('organizacoes')
      .upsert([
        { nome: 'Matriz DNOTAS', tipo: 'matriz', codigo: 'matriz', matriz_id: null },
        { nome: 'Filial 1', tipo: 'filial', codigo: 'filial01', matriz_id: 'matriz' },
        { nome: 'Filial 2', tipo: 'filial', codigo: 'filial02', matriz_id: 'matriz' }
      ], { onConflict: 'codigo' })
    
    if (insertOrgError) {
      console.error('Erro ao inserir organizações:', insertOrgError)
    } else {
      console.log('✅ Organizações inseridas!')
    }
    
    // Buscar ID da matriz
    const { data: matrizData } = await supabase
      .from('organizacoes')
      .select('id')
      .eq('codigo', 'matriz')
      .single()
    
    if (!matrizData) {
      console.error('❌ Matriz não encontrada!')
      return
    }
    
    const matrizId = matrizData.id
    console.log('🏢 ID da Matriz:', matrizId)
    
    // Criar funcionários se não existir
    if (!existingTables.includes('funcionarios')) {
      console.log('➕ Criando tabela funcionarios...')
      
      const { error: funcError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE TABLE funcionarios (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            senha VARCHAR(255) NOT NULL,
            cargo VARCHAR(100),
            organizacao_id UUID REFERENCES organizacoes(id),
            role VARCHAR(20) CHECK (role IN ('super_admin', 'admin', 'manager', 'operator')) DEFAULT 'operator',
            cpf VARCHAR(11),
            telefone VARCHAR(20),
            ativo BOOLEAN DEFAULT true NOT NULL,
            ultimo_login TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
        `
      })
      
      if (funcError) {
        console.error('Erro ao criar tabela funcionarios:', funcError)
      } else {
        console.log('✅ Tabela funcionarios criada!')
      }
    }
    
    // Inserir funcionários padrão
    console.log('👥 Inserindo funcionários padrão...')
    const { error: insertFuncError } = await supabase
      .from('funcionarios')
      .upsert([
        {
          nome: 'Administrador Sistema',
          email: 'admin@dnotas.com',
          senha: 'admin123',
          cargo: 'Administrador',
          organizacao_id: matrizId,
          role: 'admin'
        },
        {
          nome: 'Gestor Matriz',
          email: 'gestor@dnotas.com',
          senha: 'gestor123',
          cargo: 'Gestor',
          organizacao_id: matrizId,
          role: 'manager'
        }
      ], { onConflict: 'email' })
    
    if (insertFuncError) {
      console.error('Erro ao inserir funcionários:', insertFuncError)
    } else {
      console.log('✅ Funcionários inseridos!')
    }
    
    // Criar tabela de atividades
    if (!existingTables.includes('atividades_funcionarios')) {
      console.log('➕ Criando tabela atividades_funcionarios...')
      
      const { error: atError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE TABLE atividades_funcionarios (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            funcionario_id UUID REFERENCES funcionarios(id),
            tipo_atividade VARCHAR(50) NOT NULL,
            descricao TEXT NOT NULL,
            dados_extras JSONB,
            cliente_cnpj VARCHAR(14),
            resultado VARCHAR(20) CHECK (resultado IN ('success', 'error', 'warning')) DEFAULT 'success',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
        `
      })
      
      if (atError) {
        console.error('Erro ao criar tabela atividades_funcionarios:', atError)
      } else {
        console.log('✅ Tabela atividades_funcionarios criada!')
      }
    }
    
    console.log('🎉 Setup concluído com sucesso!')
    
    // Verificar funcionários criados
    const { data: funcionarios } = await supabase
      .from('funcionarios')
      .select('nome, email, role')
      .eq('ativo', true)
    
    console.log('👥 Funcionários disponíveis:')
    funcionarios?.forEach(func => {
      console.log(`  - ${func.nome} (${func.email}) - ${func.role}`)
    })
    
  } catch (error) {
    console.error('❌ Erro no setup:', error)
  }
}

setupTables()