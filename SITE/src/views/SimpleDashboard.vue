<template>
  <div class="min-h-screen bg-gray-950">
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-white">Painel Administrativo</h1>
          <p class="text-gray-400">Bem-vindo, {{ authStore.user?.nome }}</p>
        </div>
        <button 
          @click="logout"
          class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg transition-colors"
        >
          Sair
        </button>
      </div>

      <!-- Success Message -->
      <div class="bg-green-500/10 border border-green-500/20 rounded-xl p-6 mb-8">
        <div class="flex items-center space-x-3">
          <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <div>
            <h3 class="text-green-400 font-semibold">Login realizado com sucesso!</h3>
            <p class="text-gray-300">Sistema de autenticação Supabase funcionando corretamente.</p>
          </div>
        </div>
      </div>

      <!-- User Info Card -->
      <div class="bg-gray-900/50 backdrop-blur-sm rounded-xl p-6 border border-gray-800">
        <h2 class="text-xl font-semibold text-white mb-4">Informações do Usuário</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="text-gray-400 text-sm">Nome</label>
            <p class="text-white font-medium">{{ authStore.user?.nome }}</p>
          </div>
          <div>
            <label class="text-gray-400 text-sm">Email</label>
            <p class="text-white font-medium">{{ authStore.user?.email }}</p>
          </div>
          <div>
            <label class="text-gray-400 text-sm">Cargo</label>
            <p class="text-white font-medium">{{ authStore.user?.cargo }}</p>
          </div>
          <div>
            <label class="text-gray-400 text-sm">Papel</label>
            <p class="text-white font-medium">{{ authStore.user?.role }}</p>
          </div>
          <div>
            <label class="text-gray-400 text-sm">Organização</label>
            <p class="text-white font-medium">{{ authStore.user?.organizacao_nome }}</p>
          </div>
          <div>
            <label class="text-gray-400 text-sm">Tipo</label>
            <p class="text-white font-medium">{{ authStore.user?.organizacao_tipo }}</p>
          </div>
        </div>
      </div>

      <!-- Next Steps -->
      <div class="mt-8 bg-blue-500/10 border border-blue-500/20 rounded-xl p-6">
        <h3 class="text-blue-400 font-semibold mb-3">Próximos Passos</h3>
        <ul class="text-gray-300 space-y-2">
          <li class="flex items-center space-x-2">
            <span class="w-2 h-2 bg-blue-400 rounded-full"></span>
            <span>Sistema de autenticação ✅ Funcionando</span>
          </li>
          <li class="flex items-center space-x-2">
            <span class="w-2 h-2 bg-yellow-400 rounded-full"></span>
            <span>Implementar cadastro de clientes</span>
          </li>
          <li class="flex items-center space-x-2">
            <span class="w-2 h-2 bg-yellow-400 rounded-full"></span>
            <span>Sistema de chat/mensagens</span>
          </li>
          <li class="flex items-center space-x-2">
            <span class="w-2 h-2 bg-yellow-400 rounded-full"></span>
            <span>Relatórios financeiros</span>
          </li>
          <li class="flex items-center space-x-2">
            <span class="w-2 h-2 bg-yellow-400 rounded-full"></span>
            <span>Deploy da API</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const logout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>