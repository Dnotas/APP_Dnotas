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
      
      const response = await apiService.login(email, password, filialId)
      
      if (response.success) {
        user.value = response.data.user
        token.value = response.data.token
        
        localStorage.setItem('auth_token', response.data.token)
        localStorage.setItem('auth_user', JSON.stringify(response.data.user))
        
        apiService.setAuthToken(response.data.token)
        
        return true
      } else {
        error.value = response.message || 'Erro ao fazer login'
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