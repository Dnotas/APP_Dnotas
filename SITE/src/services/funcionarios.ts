import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://cqqeylhspmpilzgmqfiu.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.SDLuKQmwJu8gXEJX8CNMV5XVVFPnWNxklcfyOqnVtgw'

const supabase = createClient(supabaseUrl, supabaseKey)

export interface Funcionario {
  id: string
  nome: string
  email: string
  cargo: string
  filial_id: string
  filial_nome?: string
  role: 'admin' | 'manager' | 'operator' | 'viewer'
  ativo: boolean
  ultimo_login?: string
  created_at: string
}

export interface FuncionarioCreate {
  nome: string
  email: string
  senha: string
  cargo: string
  filial_id: string
  role: 'admin' | 'manager' | 'operator' | 'viewer'
  cpf?: string
  telefone?: string
}

export interface AtividadeFuncionario {
  id: string
  funcionario_id: string
  tipo_atividade: string
  descricao: string
  dados_extras?: any
  cliente_cnpj?: string
  resultado: 'success' | 'error' | 'warning'
  created_at: string
}

class FuncionariosService {
  // Autenticar funcionário
  async login(email: string, senha: string) {
    try {
      const { data, error } = await supabase
        .from('funcionarios')
        .select(`
          id, nome, email, cargo, role, ativo, ultimo_login,
          filial_id, filiais(nome)
        `)
        .eq('email', email)
        .eq('ativo', true)
        .single()

      if (error || !data) {
        return { success: false, error: 'Credenciais inválidas' }
      }

      // Aqui você faria a verificação da senha com bcrypt
      // Por enquanto, vamos simular (em produção usar bcrypt.compare)
      const senhasValidas: { [key: string]: string } = {
        'admin@dnotas.com': 'admin123',
        'gestor@dnotas.com': 'gestor123',
        'maria.silva@dnotas.com': 'funcionario123',
        'joao.santos@dnotas.com': 'funcionario123',
        'ana.costa@dnotas.com': 'funcionario123',
        'carlos.oliveira@dnotas.com': 'funcionario123',
        'paula.lima@dnotas.com': 'funcionario123'
      }

      if (senhasValidas[email] !== senha) {
        return { success: false, error: 'Senha incorreta' }
      }

      // Atualizar último login
      await supabase
        .from('funcionarios')
        .update({ ultimo_login: new Date().toISOString() })
        .eq('id', data.id)

      // Registrar atividade de login
      await this.registrarAtividade(
        data.id,
        'login',
        `Login realizado no sistema`,
        { ip: 'web', navegador: navigator.userAgent }
      )

      return {
        success: true,
        funcionario: {
          ...data,
          filial_nome: data.filiais?.nome
        }
      }
    } catch (error) {
      console.error('Erro no login:', error)
      return { success: false, error: 'Erro interno do servidor' }
    }
  }

  // Listar funcionários da filial
  async getFuncionarios(filialId: string) {
    try {
      const { data, error } = await supabase
        .from('funcionarios')
        .select(`
          id, nome, email, cargo, role, ativo, ultimo_login, created_at,
          filiais(nome)
        `)
        .eq('filial_id', filialId)
        .order('nome')

      if (error) throw error

      return { success: true, funcionarios: data }
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error)
      return { success: false, error: 'Erro ao buscar funcionários' }
    }
  }

  // Criar novo funcionário
  async criarFuncionario(funcionario: FuncionarioCreate) {
    try {
      // Em produção, fazer hash da senha com bcrypt
      const { data, error } = await supabase
        .from('funcionarios')
        .insert([{
          ...funcionario,
          ativo: true
        }])
        .select()
        .single()

      if (error) throw error

      return { success: true, funcionario: data }
    } catch (error) {
      console.error('Erro ao criar funcionário:', error)
      return { success: false, error: 'Erro ao criar funcionário' }
    }
  }

  // Atualizar funcionário
  async atualizarFuncionario(id: string, updates: Partial<FuncionarioCreate>) {
    try {
      const { data, error } = await supabase
        .from('funcionarios')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (error) throw error

      return { success: true, funcionario: data }
    } catch (error) {
      console.error('Erro ao atualizar funcionário:', error)
      return { success: false, error: 'Erro ao atualizar funcionário' }
    }
  }

  // Desativar funcionário
  async desativarFuncionario(id: string) {
    try {
      const { error } = await supabase
        .from('funcionarios')
        .update({ ativo: false })
        .eq('id', id)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Erro ao desativar funcionário:', error)
      return { success: false, error: 'Erro ao desativar funcionário' }
    }
  }

  // Registrar atividade do funcionário
  async registrarAtividade(
    funcionarioId: string,
    tipoAtividade: string,
    descricao: string,
    dadosExtras: any = {},
    clienteCnpj?: string
  ) {
    try {
      const { error } = await supabase
        .from('atividades_funcionarios')
        .insert([{
          funcionario_id: funcionarioId,
          tipo_atividade: tipoAtividade,
          descricao,
          dados_extras: dadosExtras,
          cliente_cnpj: clienteCnpj,
          resultado: 'success'
        }])

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Erro ao registrar atividade:', error)
      return { success: false }
    }
  }

  // Buscar atividades do funcionário
  async getAtividades(funcionarioId: string, limit = 50) {
    try {
      const { data, error } = await supabase
        .from('atividades_funcionarios')
        .select('*')
        .eq('funcionario_id', funcionarioId)
        .order('created_at', { ascending: false })
        .limit(limit)

      if (error) throw error

      return { success: true, atividades: data }
    } catch (error) {
      console.error('Erro ao buscar atividades:', error)
      return { success: false, error: 'Erro ao buscar atividades' }
    }
  }

  // Buscar filiais
  async getFiliais() {
    try {
      const { data, error } = await supabase
        .from('filiais')
        .select('*')
        .eq('ativo', true)
        .order('nome')

      if (error) throw error

      return { success: true, filiais: data }
    } catch (error) {
      console.error('Erro ao buscar filiais:', error)
      return { success: false, error: 'Erro ao buscar filiais' }
    }
  }
}

export const funcionariosService = new FuncionariosService()