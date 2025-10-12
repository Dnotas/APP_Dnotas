import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
// Usando service_role key para desenvolvimento (mais permissões)
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI'

const supabase = createClient(supabaseUrl, supabaseKey)

export interface Organizacao {
  id: string
  nome: string
  tipo: 'matriz' | 'filial'
  codigo?: string
  cnpj?: string
  endereco?: string
  telefone?: string
  email?: string
  responsavel?: string
  matriz_id?: string
  ativo: boolean
  created_at: string
  updated_at?: string
}

export interface Funcionario {
  id: string
  nome: string
  email: string
  cargo: string
  organizacao_id: string
  organizacao_nome?: string
  role: 'super_admin' | 'admin' | 'manager' | 'operator'
  ativo: boolean
  ultimo_login?: string
  created_at: string
}

export interface FuncionarioCreate {
  nome: string
  email: string
  senha: string
  cargo: string
  organizacao_id: string
  role: 'admin' | 'manager' | 'operator'
}

export interface OrganizacaoCreate {
  id: string
  nome: string
  tipo: 'matriz' | 'filial'
  codigo?: string
  cnpj?: string
  endereco?: string
  telefone?: string
  email?: string
  responsavel?: string
  matriz_id?: string
}

class OrganizacoesService {
  // Login usando banco de dados Supabase
  async login(email: string, senha: string) {
    try {
      console.log('OrganizacoesService: Tentando login:', email)
      
      const { data, error } = await supabase
        .from('funcionarios')
        .select(`
          id, nome, email, senha, cargo, role, ativo, ultimo_login,
          organizacao_id
        `)
        .eq('email', email)
        .eq('ativo', true)
        .single()

      console.log('OrganizacoesService: Resposta login:', { data, error })

      if (error || !data) {
        return { success: false, error: 'Credenciais inválidas' }
      }

      // Verificação simples da senha (em produção usar bcrypt.compare)
      if (data.senha !== senha) {
        return { success: false, error: 'Senha incorreta' }
      }

      // Buscar informações da organização separadamente
      let organizacao_nome = 'Organização'
      let organizacao_tipo = 'matriz'
      
      if (data.organizacao_id) {
        const { data: orgData } = await supabase
          .from('organizacoes')
          .select('nome, tipo')
          .eq('id', data.organizacao_id)
          .single()
        
        if (orgData) {
          organizacao_nome = orgData.nome
          organizacao_tipo = orgData.tipo
        }
      }

      // Atualizar último login
      await supabase
        .from('funcionarios')
        .update({ ultimo_login: new Date().toISOString() })
        .eq('id', data.id)

      return {
        success: true,
        funcionario: {
          ...data,
          organizacao_nome,
          organizacao_tipo
        }
      }
    } catch (error) {
      console.error('Erro no login:', error)
      return { success: false, error: 'Erro interno do servidor' }
    }
  }

  // Listar todas as organizações (só matriz pode ver)
  async getOrganizacoes() {
    try {
      console.log('OrganizacoesService: Buscando organizações...')
      
      const { data, error } = await supabase
        .from('organizacoes')
        .select('*')
        .eq('ativo', true)
        .order('tipo, nome')

      console.log('OrganizacoesService: Resposta organizações:', { data, error })

      if (error) throw error

      return { success: true, organizacoes: data }
    } catch (error) {
      console.error('Erro ao buscar organizações:', error)
      return { success: false, error: 'Erro ao buscar organizações' }
    }
  }

  // Listar filiais (para matriz)
  async getFiliais() {
    try {
      console.log('OrganizacoesService: Buscando filiais...')
      
      const { data, error } = await supabase
        .from('organizacoes')
        .select('*')
        .eq('tipo', 'filial')
        .eq('ativo', true)
        .order('nome')

      console.log('OrganizacoesService: Resposta filiais:', { data, error })

      if (error) throw error

      return { success: true, filiais: data }
    } catch (error) {
      console.error('Erro ao buscar filiais:', error)
      return { success: false, error: 'Erro ao buscar filiais' }
    }
  }

  // Criar nova filial (só matriz)
  async criarFilial(filial: OrganizacaoCreate) {
    try {
      console.log('OrganizacoesService: Criando filial:', filial)
      
      const { data, error } = await supabase
        .from('organizacoes')
        .insert([{
          ...filial,
          tipo: 'filial',
          matriz_id: 'matriz',
          ativo: true
        }])
        .select()
        .single()

      console.log('OrganizacoesService: Resposta criar filial:', { data, error })

      if (error) throw error

      return { success: true, filial: data }
    } catch (error) {
      console.error('Erro ao criar filial:', error)
      return { success: false, error: 'Erro ao criar filial' }
    }
  }

  // Listar funcionários da organização
  async getFuncionarios(organizacaoId: string) {
    try {
      console.log('OrganizacoesService: Buscando funcionários de:', organizacaoId)
      
      const { data, error } = await supabase
        .from('funcionarios')
        .select(`
          id, nome, email, cargo, role, ativo, ultimo_login, created_at,
          organizacoes(nome)
        `)
        .eq('organizacao_id', organizacaoId)
        .order('nome')

      console.log('OrganizacoesService: Resposta funcionários:', { data, error })

      if (error) throw error

      return { success: true, funcionarios: data }
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error)
      return { success: false, error: 'Erro ao buscar funcionários' }
    }
  }

  // Criar funcionário
  async criarFuncionario(funcionario: FuncionarioCreate) {
    try {
      console.log('OrganizacoesService: Criando funcionário:', funcionario)
      
      const { data, error } = await supabase
        .from('funcionarios')
        .insert([{
          ...funcionario,
          ativo: true
        }])
        .select()
        .single()

      console.log('OrganizacoesService: Resposta criar funcionário:', { data, error })

      if (error) throw error

      return { success: true, funcionario: data }
    } catch (error) {
      console.error('Erro ao criar funcionário:', error)
      return { success: false, error: 'Erro ao criar funcionário' }
    }
  }

  // Registrar atividade do funcionário
  async registrarAtividade(
    funcionarioId: string,
    tipoAtividade: string,
    descricao: string,
    dadosExtras: any = {}
  ) {
    try {
      const { error } = await supabase
        .from('atividades_funcionarios')
        .insert([{
          funcionario_id: funcionarioId,
          tipo_atividade: tipoAtividade,
          descricao,
          dados_extras: dadosExtras,
          resultado: 'success'
        }])

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Erro ao registrar atividade:', error)
      return { success: false }
    }
  }
}

export const organizacoesService = new OrganizacoesService()