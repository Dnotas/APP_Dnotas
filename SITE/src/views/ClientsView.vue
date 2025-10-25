<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <div class="sm:flex sm:items-center">
          <div class="sm:flex-auto">
            <h1 class="text-xl font-semibold text-gray-900">Clientes</h1>
            <p class="mt-2 text-sm text-gray-700">
              Lista de todos os clientes da {{ authStore.user?.filial_id }}
            </p>
          </div>
          <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
            <button
              type="button"
              @click="abrirNovoClienteModal"
              class="inline-flex items-center justify-center rounded-md border border-transparent bg-primary-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 sm:w-auto"
            >
              Novo Cliente
            </button>
          </div>
        </div>
        
        <div class="mt-8 flex flex-col">
          <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
              <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                <table class="min-w-full divide-y divide-gray-300">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Cliente
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        CNPJ
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Último Login
                      </th>
                      <th class="relative px-6 py-3">
                        <span class="sr-only">Ações</span>
                      </th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr v-for="client in clients" :key="client.id">
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="flex items-center">
                          <div class="flex-shrink-0 h-10 w-10">
                            <div class="h-10 w-10 rounded-full bg-primary-500 flex items-center justify-center">
                              <span class="text-white text-sm font-medium">
                                {{ client.nome_empresa.charAt(0) }}
                              </span>
                            </div>
                          </div>
                          <div class="ml-4">
                            <div class="text-sm font-medium text-gray-900">
                              {{ client.nome_empresa }}
                            </div>
                            <div class="text-sm text-gray-500">
                              {{ client.email }}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {{ formatCnpj(client.cnpj) }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span
                          class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                          :class="client.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                        >
                          {{ client.is_active ? 'Ativo' : 'Inativo' }}
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {{ client.last_login ? formatDate(client.last_login) : 'Nunca' }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div class="flex items-center justify-end space-x-3">
                          <button 
                            @click="abrirFiliaisModal(client)"
                            class="text-blue-600 hover:text-blue-900"
                            title="Gerenciar Filiais"
                          >
                            Filiais
                          </button>
                          <button 
                            @click="abrirEditarClienteModal(client)"
                            class="text-primary-600 hover:text-primary-900"
                          >
                            Editar
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Filiais -->
    <FiliaisModal
      :is-open="filiaisModalOpen"
      :cliente="clienteSelecionado"
      @close="fecharFiliaisModal"
      @updated="loadClients"
    />

    <!-- Modal de Cliente (Criar/Editar) -->
    <ClienteModal
      :is-open="clienteModalOpen"
      :cliente="clienteParaEdicao"
      @close="fecharClienteModal"
      @saved="handleClienteSalvo"
    />
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { apiService } from '@/services/api'
import AppLayout from '@/components/AppLayout.vue'
import FiliaisModal from '@/components/FiliaisModal.vue'
import ClienteModal from '@/components/ClienteModal.vue'
import type { Client } from '@/types'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const authStore = useAuthStore()
const clients = ref<Client[]>([])

// Estado do modal de filiais
const filiaisModalOpen = ref(false)
const clienteSelecionado = ref<Client>({} as Client)

// Estado do modal de cliente
const clienteModalOpen = ref(false)
const clienteParaEdicao = ref<Client | null>(null)

const formatCnpj = (cnpj: string) => {
  return cnpj.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
}

const formatDate = (dateString: string) => {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

const loadClients = async () => {
  try {
    clients.value = await apiService.getClients(authStore.user?.filial_id || 'matriz')
  } catch (error) {
    console.error('Erro ao carregar clientes:', error)
  }
}

// Métodos do modal de filiais
const abrirFiliaisModal = (client: Client) => {
  clienteSelecionado.value = client
  filiaisModalOpen.value = true
}

const fecharFiliaisModal = () => {
  filiaisModalOpen.value = false
  clienteSelecionado.value = {} as Client
}

// Métodos do modal de cliente
const abrirNovoClienteModal = () => {
  clienteParaEdicao.value = null
  clienteModalOpen.value = true
}

const abrirEditarClienteModal = (client: Client) => {
  clienteParaEdicao.value = client
  clienteModalOpen.value = true
}

const fecharClienteModal = () => {
  clienteModalOpen.value = false
  clienteParaEdicao.value = null
}

const handleClienteSalvo = () => {
  loadClients()
  fecharClienteModal()
}

onMounted(() => {
  loadClients()
})
</script>