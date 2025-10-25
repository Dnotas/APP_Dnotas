// Serviço para gerenciar filiais dos clientes
import type { ClientFilial } from '@/types'

const API_BASE = 'https://api.dnotas.com.br:9999/api/client-filiais'

interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}

interface FilialResponse {
  matriz_cnpj: string
  filiais: Array<{
    cnpj: string
    nome: string
    tipo: 'matriz' | 'filial'
    ativo: boolean
  }>
}

export const clientFiliaisService = {
  // Buscar todas as filiais de um cliente
  async getFiliais(cnpj: string): Promise<FilialResponse> {
    try {
      console.log(`🏢 Buscando filiais do cliente: ${cnpj}`)
      
      const response = await fetch(`${API_BASE}/${cnpj}`)
      const data: ApiResponse<FilialResponse> = await response.json()
      
      if (!response.ok || !data.success) {
        throw new Error(data.error || 'Erro ao buscar filiais')
      }
      
      console.log(`✅ Filiais encontradas:`, data.data)
      return data.data!
      
    } catch (error) {
      console.error('❌ Erro ao buscar filiais:', error)
      throw error
    }
  },

  // Adicionar nova filial a um cliente
  async adicionarFilial(filial: {
    matriz_cnpj: string
    filial_cnpj: string
    filial_nome: string
    endereco?: string
    telefone?: string
    email?: string
  }): Promise<ClientFilial> {
    try {
      console.log(`🏢 Adicionando filial:`, filial)
      
      const response = await fetch(API_BASE, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(filial)
      })
      
      const data: ApiResponse<ClientFilial> = await response.json()
      
      if (!response.ok || !data.success) {
        throw new Error(data.error || 'Erro ao adicionar filial')
      }
      
      console.log(`✅ Filial criada:`, data.data)
      return data.data!
      
    } catch (error) {
      console.error('❌ Erro ao adicionar filial:', error)
      throw error
    }
  },

  // Atualizar dados de uma filial
  async atualizarFilial(id: string, dados: {
    filial_nome?: string
    endereco?: string
    telefone?: string
    email?: string
    ativo?: boolean
  }): Promise<ClientFilial> {
    try {
      console.log(`🏢 Atualizando filial ${id}:`, dados)
      
      const response = await fetch(`${API_BASE}/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(dados)
      })
      
      const data: ApiResponse<ClientFilial> = await response.json()
      
      if (!response.ok || !data.success) {
        throw new Error(data.error || 'Erro ao atualizar filial')
      }
      
      console.log(`✅ Filial atualizada:`, data.data)
      return data.data!
      
    } catch (error) {
      console.error('❌ Erro ao atualizar filial:', error)
      throw error
    }
  },

  // Remover uma filial (soft delete)
  async removerFilial(id: string): Promise<void> {
    try {
      console.log(`🏢 Removendo filial: ${id}`)
      
      const response = await fetch(`${API_BASE}/${id}`, {
        method: 'DELETE'
      })
      
      const data: ApiResponse<any> = await response.json()
      
      if (!response.ok || !data.success) {
        throw new Error(data.error || 'Erro ao remover filial')
      }
      
      console.log(`✅ Filial removida com sucesso`)
      
    } catch (error) {
      console.error('❌ Erro ao remover filial:', error)
      throw error
    }
  },

  // Buscar se um CNPJ já existe (para validação)
  async buscarCnpj(cnpj: string): Promise<{
    found: boolean
    tipo?: 'matriz' | 'filial'
    dados?: any
  }> {
    try {
      console.log(`🔍 Verificando CNPJ: ${cnpj}`)
      
      const response = await fetch(`${API_BASE}/search/${cnpj}`)
      const data = await response.json()
      
      if (!response.ok || !data.success) {
        throw new Error(data.error || 'Erro ao buscar CNPJ')
      }
      
      console.log(`✅ Resultado da busca:`, data)
      return {
        found: data.found,
        tipo: data.tipo,
        dados: data.dados
      }
      
    } catch (error) {
      console.error('❌ Erro ao buscar CNPJ:', error)
      throw error
    }
  },

  // Formatar CNPJ
  formatarCnpj(cnpj: string): string {
    return cnpj.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
  },

  // Limpar formatação do CNPJ
  limparCnpj(cnpj: string): string {
    return cnpj.replace(/[^\d]/g, '')
  },

  // Validar CNPJ
  validarCnpj(cnpj: string): boolean {
    const cleanCnpj = this.limparCnpj(cnpj)
    return cleanCnpj.length === 14 && /^\d+$/.test(cleanCnpj)
  }
}