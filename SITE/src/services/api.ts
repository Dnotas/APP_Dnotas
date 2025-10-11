import axios, { type AxiosInstance } from 'axios'
import type { User, Client, Message, ChatSession, DashboardStats, Boleto } from '@/types'

class ApiService {
  private api: AxiosInstance

  constructor() {
    this.api = axios.create({
      baseURL: 'http://localhost:3000/api',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    })

    // Response interceptor para tratar erros
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expirado, fazer logout
          localStorage.removeItem('auth_token')
          localStorage.removeItem('auth_user')
          window.location.href = '/login'
        }
        return Promise.reject(error)
      }
    )
  }

  setAuthToken(token: string | null) {
    if (token) {
      this.api.defaults.headers.common['Authorization'] = `Bearer ${token}`
    } else {
      delete this.api.defaults.headers.common['Authorization']
    }
  }

  // Auth
  async login(email: string, password: string, filialId: string) {
    const response = await this.api.post('/auth/admin-login', {
      email,
      password,
      filial_id: filialId
    })
    return response.data
  }

  // Dashboard Stats
  async getDashboardStats(): Promise<DashboardStats> {
    const response = await this.api.get('/admin/dashboard-stats')
    return response.data.data
  }

  // Clients
  async getClients(filialId: string): Promise<Client[]> {
    const response = await this.api.get(`/admin/clients?filial_id=${filialId}`)
    return response.data.data
  }

  // Chat Sessions
  async getChatSessions(filialId: string): Promise<ChatSession[]> {
    const response = await this.api.get(`/admin/chat-sessions?filial_id=${filialId}`)
    return response.data.data
  }

  // Messages
  async getMessages(clientCnpj: string): Promise<Message[]> {
    const response = await this.api.get(`/admin/messages/${clientCnpj}`)
    return response.data.data
  }

  async sendMessage(clientCnpj: string, content: string): Promise<boolean> {
    try {
      const response = await this.api.post('/admin/send-message', {
        client_cnpj: clientCnpj,
        content
      })
      return response.data.success
    } catch (error) {
      console.error('Error sending message:', error)
      return false
    }
  }

  async markAsRead(clientCnpj: string): Promise<boolean> {
    try {
      const response = await this.api.post('/admin/mark-read', {
        client_cnpj: clientCnpj
      })
      return response.data.success
    } catch (error) {
      console.error('Error marking as read:', error)
      return false
    }
  }

  // Boletos
  async getBoletos(filialId: string): Promise<Boleto[]> {
    const response = await this.api.get(`/admin/boletos?filial_id=${filialId}`)
    return response.data.data
  }
}

export const apiService = new ApiService()