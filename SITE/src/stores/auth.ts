import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { organizacoesService, type Funcionario } from '@/services/organizacoes'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<Funcionario | null>(null)
  const token = ref<string | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!user.value)

  const initializeAuth = () => {
    const savedUser = localStorage.getItem('auth_user')
    const savedToken = localStorage.getItem('auth_token')
    if (savedUser) {
      user.value = JSON.parse(savedUser)
    }
    if (savedToken) {
      token.value = savedToken
    }
  }

  const login = async (email: string, password: string) => {
    try {
      isLoading.value = true
      error.value = null
      
      console.log('AuthStore: Tentando login com Supabase:', email)
      const response = await organizacoesService.login(email, password)
      console.log('AuthStore: Resposta do login:', response)
      
      if (response.success && response.funcionario) {
        user.value = response.funcionario
        token.value = response.token || 'mock-token' // Adicionar token mock por enquanto
        localStorage.setItem('auth_user', JSON.stringify(response.funcionario))
        localStorage.setItem('auth_token', token.value)
        
        console.log('AuthStore: Login realizado com sucesso:', response.funcionario)
        return true
      } else {
        error.value = response.error || 'Erro ao fazer login'
        console.error('AuthStore: Erro no login:', response.error)
        return false
      }
    } catch (err) {
      error.value = 'Erro de conexão'
      console.error('AuthStore: Erro de conexão:', err)
      return false
    } finally {
      isLoading.value = false
    }
  }

  const logout = async () => {
    // Logout do Supabase Auth
    await organizacoesService.logout()
    
    user.value = null
    token.value = null
    error.value = null
    localStorage.removeItem('auth_user')
    localStorage.removeItem('auth_token')
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