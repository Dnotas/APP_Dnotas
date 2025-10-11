<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <div class="md:flex md:items-center md:justify-between">
          <div class="flex-1 min-w-0">
            <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              Painel Administrativo - {{ authStore.user?.organizacao_nome }}
            </h2>
            <p class="mt-1 text-sm text-gray-500">
              Gestão completa do sistema DNOTAS
            </p>
          </div>
          <div class="mt-4 flex md:mt-0 md:ml-4">
            <button
              @click="loadData"
              class="ml-3 inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Atualizar
            </button>
          </div>
        </div>
      </div>
      
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <!-- Cards de estatísticas -->
        <div class="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <div class="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Total de Filiais
                    </dt>
                    <dd>
                      <div class="text-lg font-semibold text-gray-900">
                        {{ stats.totalFiliais }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-blue-50 px-5 py-3">
              <div class="text-sm">
                <router-link to="/admin/filiais" class="font-medium text-blue-700 hover:text-blue-900">
                  Gerenciar filiais →
                </router-link>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Total de Funcionários
                    </dt>
                    <dd>
                      <div class="text-lg font-semibold text-gray-900">
                        {{ stats.totalFuncionarios }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-green-50 px-5 py-3">
              <div class="text-sm">
                <router-link to="/admin/funcionarios" class="font-medium text-green-700 hover:text-green-900">
                  Gerenciar funcionários →
                </router-link>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Total de Clientes
                    </dt>
                    <dd>
                      <div class="text-lg font-semibold text-gray-900">
                        {{ stats.totalClientes }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-purple-50 px-5 py-3">
              <div class="text-sm">
                <router-link to="/clients" class="font-medium text-purple-700 hover:text-purple-900">
                  Ver clientes →
                </router-link>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Atividades Hoje
                    </dt>
                    <dd>
                      <div class="text-lg font-semibold text-gray-900">
                        {{ stats.atividadesHoje }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-yellow-50 px-5 py-3">
              <div class="text-sm">
                <router-link to="/reports" class="font-medium text-yellow-700 hover:text-yellow-900">
                  Ver relatórios →
                </router-link>
              </div>
            </div>
          </div>
        </div>

        <!-- Grid principal -->
        <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
          <!-- Filiais recentes -->
          <div class="bg-white shadow-lg rounded-lg border border-gray-200">
            <div class="p-6">
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                  Filiais Ativas
                </h3>
                <router-link 
                  to="/admin/filiais" 
                  class="text-sm text-blue-600 hover:text-blue-900 font-medium"
                >
                  Ver todas
                </router-link>
              </div>
              <div class="flow-root">
                <ul role="list" class="-my-5 divide-y divide-gray-200">
                  <li v-for="filial in filiais" :key="filial.id" class="py-4">
                    <div class="flex items-center space-x-4">
                      <div class="flex-shrink-0">
                        <div class="h-10 w-10 rounded-lg bg-gradient-to-r from-blue-500 to-blue-600 flex items-center justify-center">
                          <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                          </svg>
                        </div>
                      </div>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">
                          {{ filial.nome }}
                        </p>
                        <p class="text-sm text-gray-500">
                          {{ filial.funcionarios_count || 0 }} funcionários
                        </p>
                      </div>
                      <div class="flex-shrink-0">
                        <span 
                          class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                          :class="filial.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                        >
                          {{ filial.ativo ? 'Ativa' : 'Inativa' }}
                        </span>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Atividades recentes -->
          <div class="bg-white shadow-lg rounded-lg border border-gray-200">
            <div class="p-6">
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                  Atividades Recentes
                </h3>
                <router-link 
                  to="/reports" 
                  class="text-sm text-blue-600 hover:text-blue-900 font-medium"
                >
                  Ver todas
                </router-link>
              </div>
              <div class="flow-root">
                <ul role="list" class="-my-5 divide-y divide-gray-200">
                  <li v-for="atividade in atividades" :key="atividade.id" class="py-4">
                    <div class="flex items-center space-x-4">
                      <div class="flex-shrink-0">
                        <div 
                          class="h-8 w-8 rounded-full flex items-center justify-center"
                          :class="getActivityColor(atividade.tipo_atividade)"
                        >
                          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                          </svg>
                        </div>
                      </div>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">
                          {{ atividade.descricao }}
                        </p>
                        <p class="text-sm text-gray-500">
                          {{ formatTime(atividade.created_at) }}
                        </p>
                      </div>
                      <div class="flex-shrink-0">
                        <span 
                          class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                          :class="getResultColor(atividade.resultado)"
                        >
                          {{ atividade.resultado }}
                        </span>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- Ações administrativas -->
        <div class="mt-8">
          <div class="bg-white shadow-lg rounded-lg border border-gray-200">
            <div class="p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-6">
                Ações Administrativas
              </h3>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <button
                  @click="router.push('/admin/filiais/novo')"
                  class="relative group bg-gradient-to-r from-blue-500 to-blue-600 p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-blue-500 rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all transform hover:scale-105"
                >
                  <div class="flex items-center">
                    <span class="rounded-lg inline-flex p-3 bg-white bg-opacity-20">
                      <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                      </svg>
                    </span>
                    <div class="ml-4">
                      <h3 class="text-lg font-medium text-white">
                        Nova Filial
                      </h3>
                      <p class="mt-1 text-sm text-blue-100">
                        Criar uma nova filial
                      </p>
                    </div>
                  </div>
                </button>

                <button
                  @click="router.push('/admin/funcionarios/novo')"
                  class="relative group bg-gradient-to-r from-green-500 to-green-600 p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-green-500 rounded-lg hover:from-green-600 hover:to-green-700 transition-all transform hover:scale-105"
                >
                  <div class="flex items-center">
                    <span class="rounded-lg inline-flex p-3 bg-white bg-opacity-20">
                      <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                      </svg>
                    </span>
                    <div class="ml-4">
                      <h3 class="text-lg font-medium text-white">
                        Novo Funcionário
                      </h3>
                      <p class="mt-1 text-sm text-green-100">
                        Cadastrar funcionário
                      </p>
                    </div>
                  </div>
                </button>

                <button
                  @click="router.push('/reports')"
                  class="relative group bg-gradient-to-r from-purple-500 to-purple-600 p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-purple-500 rounded-lg hover:from-purple-600 hover:to-purple-700 transition-all transform hover:scale-105"
                >
                  <div class="flex items-center">
                    <span class="rounded-lg inline-flex p-3 bg-white bg-opacity-20">
                      <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    </span>
                    <div class="ml-4">
                      <h3 class="text-lg font-medium text-white">
                        Relatórios
                      </h3>
                      <p class="mt-1 text-sm text-purple-100">
                        Gerar relatórios
                      </p>
                    </div>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { organizacoesService } from '@/services/organizacoes'
import AppLayout from '@/components/AppLayout.vue'
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const router = useRouter()
const authStore = useAuthStore()

const stats = ref({
  totalFiliais: 0,
  totalFuncionarios: 0,
  totalClientes: 0,
  atividadesHoje: 0
})

const filiais = ref([])
const atividades = ref([])

const formatTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { 
    addSuffix: true, 
    locale: ptBR 
  })
}

const getActivityColor = (tipo: string) => {
  const colors = {
    'login': 'bg-green-100 text-green-600',
    'create': 'bg-blue-100 text-blue-600',
    'update': 'bg-yellow-100 text-yellow-600',
    'delete': 'bg-red-100 text-red-600',
    'default': 'bg-gray-100 text-gray-600'
  }
  return colors[tipo] || colors.default
}

const getResultColor = (resultado: string) => {
  const colors = {
    'success': 'bg-green-100 text-green-800',
    'error': 'bg-red-100 text-red-800',
    'warning': 'bg-yellow-100 text-yellow-800'
  }
  return colors[resultado] || colors.success
}

const loadData = async () => {
  try {
    console.log('AdminDashboard: Carregando dados...')
    
    // Carregar organizações
    const orgResponse = await organizacoesService.getOrganizacoes()
    if (orgResponse.success) {
      filiais.value = orgResponse.organizacoes.filter(org => org.tipo === 'filial').slice(0, 5)
      stats.value.totalFiliais = orgResponse.organizacoes.filter(org => org.tipo === 'filial').length
    }

    // Carregar funcionários
    const funcResponse = await organizacoesService.getFuncionarios('matriz')
    if (funcResponse.success) {
      stats.value.totalFuncionarios = funcResponse.funcionarios.length
    }

    // Mock de dados para demonstração
    stats.value.totalClientes = 156
    stats.value.atividadesHoje = 23

    // Mock de atividades
    atividades.value = [
      {
        id: '1',
        descricao: 'Login realizado por Admin',
        tipo_atividade: 'login',
        resultado: 'success',
        created_at: new Date().toISOString()
      },
      {
        id: '2',
        descricao: 'Nova filial criada: Filial São Paulo',
        tipo_atividade: 'create',
        resultado: 'success',
        created_at: new Date(Date.now() - 3600000).toISOString()
      },
      {
        id: '3',
        descricao: 'Funcionário atualizado: João Silva',
        tipo_atividade: 'update',
        resultado: 'success',
        created_at: new Date(Date.now() - 7200000).toISOString()
      }
    ]

    console.log('AdminDashboard: Dados carregados:', { stats: stats.value, filiais: filiais.value })
  } catch (error) {
    console.error('AdminDashboard: Erro ao carregar dados:', error)
  }
}

onMounted(() => {
  console.log('AdminDashboard: Componente montado, usuário:', authStore.user)
  loadData()
})
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>