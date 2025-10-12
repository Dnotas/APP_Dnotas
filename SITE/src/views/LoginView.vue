<template>
  <div class="min-h-screen relative overflow-hidden bg-gray-950">
    <!-- Background gradient -->
    <div class="absolute inset-0 bg-gradient-to-br from-blue-900/20 via-gray-900 to-purple-900/20"></div>
    
    <!-- Animated background elements -->
    <div class="absolute inset-0">
      <div class="absolute top-10 left-10 w-72 h-72 bg-blue-500/10 rounded-full blur-3xl animate-pulse-slow"></div>
      <div class="absolute bottom-10 right-10 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse-slow delay-1000"></div>
      <div class="absolute top-1/2 left-1/3 w-64 h-64 bg-cyan-500/5 rounded-full blur-2xl animate-pulse-slow delay-2000"></div>
    </div>
    
    <div class="relative z-10 min-h-screen flex">
      <!-- Left side - Logo and branding -->
      <div class="hidden lg:flex lg:w-1/2 flex-col justify-center items-center p-12 text-center">
        <div class="animate-fade-in">
          <div class="mb-8 relative">
            <div class="w-24 h-12 bg-gradient-to-r from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-300">
              <span class="text-white font-black text-xl tracking-wider">DNOTAS</span>
            </div>
            <div class="absolute -inset-4 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-2xl blur-xl opacity-50"></div>
          </div>
          
          <h1 class="text-5xl font-bold mb-6 bg-gradient-to-r from-blue-400 via-blue-500 to-purple-500 bg-clip-text text-transparent">
            Sistema de Gerenciamento
          </h1>
          
          <p class="text-xl text-gray-400 mb-8 max-w-md leading-relaxed">
            Plataforma completa para gestão de clientes, atendimento e relatórios financeiros
          </p>
          
          <div class="flex items-center space-x-8 text-gray-500">
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
              <span class="text-sm">Sistema Online</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-blue-400 rounded-full animate-pulse delay-500"></div>
              <span class="text-sm">Tempo Real</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-purple-400 rounded-full animate-pulse delay-1000"></div>
              <span class="text-sm">Seguro</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Right side - Login form -->
      <div class="w-full lg:w-1/2 flex items-center justify-center p-8">
        <div class="w-full max-w-md">
          <div class="card-glass glow-effect animate-fade-in">
            <div class="text-center mb-8">
              <div class="lg:hidden mb-6">
                <div class="w-20 h-10 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mx-auto shadow-xl">
                  <span class="text-white font-bold text-lg">DNOTAS</span>
                </div>
              </div>
              
              <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-blue-400 to-blue-500 bg-clip-text text-transparent">
                Bem-vindo de volta
              </h2>
              <p class="text-gray-400">
                Acesse seu painel administrativo
              </p>
            </div>
            
            <form @submit.prevent="handleLogin" class="space-y-6">
              <div class="space-y-4">
                <div class="relative">
                  <label for="email" class="block text-sm font-medium text-gray-300 mb-2">
                    Email
                  </label>
                  <input
                    id="email"
                    v-model="email"
                    type="email"
                    required
                    class="input-field"
                    placeholder="admin@dnotas.com"
                  />
                  <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-gray-500 mt-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                    </svg>
                  </div>
                </div>
                
                <div class="relative">
                  <label for="password" class="block text-sm font-medium text-gray-300 mb-2">
                    Senha
                  </label>
                  <input
                    id="password"
                    v-model="password"
                    type="password"
                    required
                    class="input-field"
                    placeholder="••••••••"
                  />
                  <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-gray-500 mt-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                  </div>
                </div>
                
                <!-- Filial removida - login automático detecta a organização -->
              </div>

              <div v-if="authStore.error" class="p-4 bg-red-500/10 border border-red-500/20 rounded-xl">
                <div class="flex items-center space-x-2">
                  <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-red-400 text-sm">{{ authStore.error }}</span>
                </div>
              </div>

              <button
                type="submit"
                :disabled="authStore.isLoading"
                class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:transform-none relative overflow-hidden group"
              >
                <span v-if="authStore.isLoading" class="flex items-center justify-center">
                  <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Entrando...
                </span>
                <span v-else class="flex items-center justify-center">
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                  </svg>
                  Entrar no Sistema
                </span>
              </button>

              <!-- Cadastro removido - apenas login disponível -->
            </form>

          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { funcionariosService } from '@/services/funcionarios'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')

const handleLogin = async () => {
  authStore.clearError()
  
  // Login simplificado - sem seleção de filial
  const success = await authStore.login(email.value, password.value)
  
  if (success) {
    // Redirecionar para dashboard simples
    router.push('/dashboard')
  }
}
</script>