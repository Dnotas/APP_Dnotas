<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <h1 class="text-2xl font-semibold text-gray-900">Dashboard</h1>
      </div>
      
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <!-- Stats cards -->
        <div class="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <div
            v-for="stat in stats"
            :key="stat.name"
            class="bg-white overflow-hidden shadow rounded-lg"
          >
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <component
                    :is="stat.icon"
                    class="h-6 w-6 text-gray-400"
                    aria-hidden="true"
                  />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      {{ stat.name }}
                    </dt>
                    <dd>
                      <div class="text-lg font-medium text-gray-900">
                        {{ stat.value }}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-5 py-3">
              <div class="text-sm">
                <span
                  class="font-medium"
                  :class="stat.changeType === 'increase' ? 'text-green-600' : 'text-red-600'"
                >
                  {{ stat.change }}
                </span>
                <span class="text-gray-500"> desde ontem</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Charts and recent activity -->
        <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
          <!-- Active chats -->
          <div class="bg-white shadow rounded-lg">
            <div class="p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Atendimentos Ativos
              </h3>
              <div class="mt-6 flow-root">
                <ul role="list" class="-my-5 divide-y divide-gray-200">
                  <li
                    v-for="chat in activeChats"
                    :key="chat.client_cnpj"
                    class="py-4"
                  >
                    <div class="flex items-center space-x-4">
                      <div class="flex-shrink-0">
                        <div class="h-8 w-8 rounded-full bg-primary-500 flex items-center justify-center">
                          <span class="text-white text-sm font-medium">
                            {{ chat.client_name.charAt(0) }}
                          </span>
                        </div>
                      </div>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">
                          {{ chat.client_name }}
                        </p>
                        <p class="text-sm text-gray-500 truncate">
                          {{ chat.last_message }}
                        </p>
                      </div>
                      <div class="flex-shrink-0 text-right">
                        <div
                          v-if="chat.unread_count > 0"
                          class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
                        >
                          {{ chat.unread_count }}
                        </div>
                        <p class="text-xs text-gray-500 mt-1">
                          {{ formatTime(chat.last_message_time) }}
                        </p>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
              <div class="mt-6">
                <router-link
                  to="/chat"
                  class="w-full flex justify-center items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  Ver todos os atendimentos
                </router-link>
              </div>
            </div>
          </div>

          <!-- Recent financial activity -->
          <div class="bg-white shadow rounded-lg">
            <div class="p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Atividade Financeira
              </h3>
              <div class="mt-6 flow-root">
                <ul role="list" class="-my-5 divide-y divide-gray-200">
                  <li
                    v-for="transaction in recentTransactions"
                    :key="transaction.id"
                    class="py-4"
                  >
                    <div class="flex items-center space-x-4">
                      <div class="flex-shrink-0">
                        <div
                          class="h-8 w-8 rounded-full flex items-center justify-center"
                          :class="transaction.type === 'received' ? 'bg-green-100' : 'bg-red-100'"
                        >
                          <component
                            :is="transaction.type === 'received' ? 'ArrowDownIcon' : 'ArrowUpIcon'"
                            class="h-4 w-4"
                            :class="transaction.type === 'received' ? 'text-green-600' : 'text-red-600'"
                          />
                        </div>
                      </div>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">
                          {{ transaction.description }}
                        </p>
                        <p class="text-sm text-gray-500">
                          {{ formatDate(transaction.date) }}
                        </p>
                      </div>
                      <div class="flex-shrink-0 text-right">
                        <p
                          class="text-sm font-medium"
                          :class="transaction.type === 'received' ? 'text-green-600' : 'text-red-600'"
                        >
                          {{ transaction.type === 'received' ? '+' : '-' }}R$ {{ formatCurrency(transaction.amount) }}
                        </p>
                      </div>
                    </div>
                  </li>
                </ul>
              </div>
              <div class="mt-6">
                <router-link
                  to="/financial"
                  class="w-full flex justify-center items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  Ver relatório financeiro
                </router-link>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick actions -->
        <div class="mt-8">
          <div class="bg-white shadow rounded-lg">
            <div class="p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-6">
                Ações Rápidas
              </h3>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <button
                  v-for="action in quickActions"
                  :key="action.name"
                  @click="action.action"
                  class="relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-primary-500 border border-gray-200 rounded-lg hover:border-gray-300 transition-colors"
                >
                  <div>
                    <span
                      class="rounded-lg inline-flex p-3 ring-4 ring-white"
                      :class="action.iconBackground"
                    >
                      <component
                        :is="action.icon"
                        class="h-6 w-6"
                        :class="action.iconColor"
                        aria-hidden="true"
                      />
                    </span>
                  </div>
                  <div class="mt-8">
                    <h3 class="text-lg font-medium">
                      <span class="absolute inset-0" aria-hidden="true" />
                      {{ action.name }}
                    </h3>
                    <p class="mt-2 text-sm text-gray-500">
                      {{ action.description }}
                    </p>
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
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { apiService } from '@/services/api'
import AppLayout from '@/components/AppLayout.vue'
import {
  UsersIcon,
  ChatIcon,
  CurrencyDollarIcon,
  ClockIcon,
  ArrowDownIcon,
  ArrowUpIcon,
  PlusIcon,
  DocumentReportIcon,
  MailIcon,
  CogIcon
} from '@heroicons/vue/outline'
import { format, formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const router = useRouter()
const authStore = useAuthStore()

const dashboardStats = ref({
  total_clients: 0,
  active_chats: 0,
  pending_boletos: 0,
  monthly_revenue: 0,
  daily_messages: 0,
  response_time_avg: 0
})

const activeChats = ref([])
const recentTransactions = ref([])

const stats = computed(() => [
  {
    name: 'Total de Clientes',
    value: dashboardStats.value.total_clients.toString(),
    icon: UsersIcon,
    change: '+12%',
    changeType: 'increase'
  },
  {
    name: 'Atendimentos Ativos',
    value: dashboardStats.value.active_chats.toString(),
    icon: ChatIcon,
    change: '+8%',
    changeType: 'increase'
  },
  {
    name: 'Boletos Pendentes',
    value: dashboardStats.value.pending_boletos.toString(),
    icon: CurrencyDollarIcon,
    change: '-3%',
    changeType: 'decrease'
  },
  {
    name: 'Tempo Médio de Resposta',
    value: `${dashboardStats.value.response_time_avg}min`,
    icon: ClockIcon,
    change: '-15%',
    changeType: 'decrease'
  }
])

const quickActions = [
  {
    name: 'Novo Cliente',
    description: 'Cadastrar um novo cliente',
    icon: PlusIcon,
    iconColor: 'text-primary-600',
    iconBackground: 'bg-primary-50',
    action: () => router.push('/clients')
  },
  {
    name: 'Gerar Relatório',
    description: 'Criar novo relatório',
    icon: DocumentReportIcon,
    iconColor: 'text-green-600',
    iconBackground: 'bg-green-50',
    action: () => router.push('/reports')
  },
  {
    name: 'Enviar Comunicado',
    description: 'Comunicado para clientes',
    icon: MailIcon,
    iconColor: 'text-yellow-600',
    iconBackground: 'bg-yellow-50',
    action: () => console.log('Enviar comunicado')
  },
  {
    name: 'Configurações',
    description: 'Ajustar configurações',
    icon: CogIcon,
    iconColor: 'text-gray-600',
    iconBackground: 'bg-gray-50',
    action: () => console.log('Configurações')
  }
]

const formatTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { 
    addSuffix: true, 
    locale: ptBR 
  })
}

const formatDate = (dateString: string) => {
  return format(new Date(dateString), 'dd/MM/yyyy', { locale: ptBR })
}

const formatCurrency = (amount: number) => {
  return amount.toFixed(2).replace('.', ',')
}

const loadDashboardData = async () => {
  try {
    const [stats, chats] = await Promise.all([
      apiService.getDashboardStats(),
      apiService.getChatSessions(authStore.user?.filial_id || 'matriz')
    ])
    
    dashboardStats.value = stats
    activeChats.value = chats.slice(0, 5) // Mostrar apenas os 5 primeiros
    
    // Mock de transações recentes
    recentTransactions.value = [
      {
        id: '1',
        description: 'Pagamento Empresa ABC',
        amount: 850.00,
        type: 'received',
        date: new Date().toISOString()
      },
      {
        id: '2',
        description: 'Taxa bancária',
        amount: 15.50,
        type: 'sent',
        date: new Date(Date.now() - 3600000).toISOString()
      },
      {
        id: '3',
        description: 'Mensalidade XYZ',
        amount: 450.00,
        type: 'received',
        date: new Date(Date.now() - 7200000).toISOString()
      }
    ]
  } catch (error) {
    console.error('Erro ao carregar dados do dashboard:', error)
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>