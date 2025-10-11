import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'
import { apiService } from '@/services/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!user.value && !!token.value)

  const initializeAuth = () => {
    const savedToken = localStorage.getItem('auth_token')
    const savedUser = localStorage.getItem('auth_user')
    
    if (savedToken && savedUser) {
      token.value = savedToken
      user.value = JSON.parse(savedUser)
      apiService.setAuthToken(savedToken)
    }
  }

  const login = async (email: string, password: string, filialId: string) => {
    try {
      isLoading.value = true
      error.value = null
      
      // Simulação de login para funcionários (para demonstração)
      const funcionarios = [
        {
          email: 'admin@dnotas.com',
          password: 'admin123',
          filial: 'matriz',
          user: {
            id: '1',
            nome: 'Administrador',
            email: 'admin@dnotas.com',
            filial_id: 'matriz',
            filial_nome: 'Matriz',
            role: 'admin'
          }
        },
        {
          email: 'gestor@dnotas.com', 
          password: 'gestor123',
          filial: 'matriz',
          user: {
            id: '2',
            nome: 'Gestor Matriz',
            email: 'gestor@dnotas.com',
            filial_id: 'matriz',
            filial_nome: 'Matriz',
            role: 'manager'
          }
        },
        {
          email: 'filial1@dnotas.com',
          password: 'filial123',
          filial: 'filial_1',
          user: {
            id: '3',
            nome: 'Operador Filial 1',
            email: 'filial1@dnotas.com',
            filial_id: 'filial_1',
            filial_nome: 'Filial 1',
            role: 'operator'
          }
        },
        {
          email: 'filial2@dnotas.com',
          password: 'filial123', 
          filial: 'filial_2',
          user: {
            id: '4',
            nome: 'Operador Filial 2',
            email: 'filial2@dnotas.com',
            filial_id: 'filial_2',
            filial_nome: 'Filial 2',
            role: 'operator'
          }
        }
      ]
      
      // Simular delay de rede
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      const funcionario = funcionarios.find(f => 
        f.email === email && 
        f.password === password && 
        f.filial === filialId
      )
      
      if (funcionario) {
        user.value = funcionario.user
        token.value = 'demo_token_' + Date.now()
        
        localStorage.setItem('auth_token', token.value)
        localStorage.setItem('auth_user', JSON.stringify(funcionario.user))
        
        apiService.setAuthToken(token.value)
        
        return true
      } else {
        error.value = 'Email, senha ou filial incorretos'
        return false
      }
    } catch (err) {
      error.value = 'Erro de conexão'
      console.error('Login error:', err)
      return false
    } finally {
      isLoading.value = false
    }
  }

  const logout = () => {
    user.value = null
    token.value = null
    error.value = null
    
    localStorage.removeItem('auth_token')
    localStorage.removeItem('auth_user')
    
    apiService.setAuthToken(null)
  }

  const clearError = () => {
    error.value = null
  }

  return {
    user,
    token,
    isLoading,
    error,
    isAuthenticated,
    initializeAuth,
    login,
    logout,
    clearError
  }
})