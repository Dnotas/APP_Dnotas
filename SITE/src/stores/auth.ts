import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'
import { apiService } from '@/services/api'
import { funcionariosService, type Funcionario } from '@/services/funcionarios'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<Funcionario | null>(null)
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

  const login = async (email: string, password: string, filialId?: string) => {
    try {
      isLoading.value = true
      error.value = null
      
      const response = await funcionariosService.login(email, password)
      
      if (response.success && response.funcionario) {
        // Verificar se filial selecionada corresponde à filial do funcionário
        if (filialId && response.funcionario.filial_id !== filialId) {
          error.value = 'Funcionário não pertence à filial selecionada'
          return false
        }
        
        user.value = response.funcionario
        token.value = 'func_token_' + Date.now()
        
        localStorage.setItem('auth_token', token.value)
        localStorage.setItem('auth_user', JSON.stringify(response.funcionario))
        
        apiService.setAuthToken(token.value)
        
        return true
      } else {
        error.value = response.error || 'Erro ao fazer login'
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