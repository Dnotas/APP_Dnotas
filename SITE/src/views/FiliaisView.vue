<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <div class="md:flex md:items-center md:justify-between">
          <div class="flex-1 min-w-0">
            <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              Gestão de Filiais
            </h2>
            <p class="mt-1 text-sm text-gray-500">
              Gerencie todas as filiais da rede DNOTAS
            </p>
          </div>
          <div class="mt-4 flex md:mt-0 md:ml-4">
            <button
              @click="showCreateModal = true"
              class="ml-3 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Nova Filial
            </button>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <!-- Filtros -->
        <div class="mt-6 bg-white shadow rounded-lg">
          <div class="p-6">
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div>
                <label for="search" class="block text-sm font-medium text-gray-700">Buscar</label>
                <input
                  id="search"
                  v-model="searchTerm"
                  type="text"
                  placeholder="Nome da filial..."
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
              <div>
                <label for="status" class="block text-sm font-medium text-gray-700">Status</label>
                <select
                  id="status"
                  v-model="statusFilter"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                >
                  <option value="">Todos</option>
                  <option value="true">Ativas</option>
                  <option value="false">Inativas</option>
                </select>
              </div>
              <div class="flex items-end">
                <button
                  @click="loadFiliais"
                  class="w-full inline-flex justify-center items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  Atualizar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Lista de filiais -->
        <div class="mt-6 bg-white shadow overflow-hidden sm:rounded-md">
          <ul role="list" class="divide-y divide-gray-200">
            <li v-for="filial in filteredFiliais" :key="filial.id">
              <div class="px-4 py-4 flex items-center justify-between hover:bg-gray-50">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-lg bg-gradient-to-r from-blue-500 to-blue-600 flex items-center justify-center">
                      <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                      </svg>
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="flex items-center">
                      <div class="text-sm font-medium text-gray-900">
                        {{ filial.nome }}
                      </div>
                      <span 
                        class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                        :class="filial.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                      >
                        {{ filial.ativo ? 'Ativa' : 'Inativa' }}
                      </span>
                    </div>
                    <div class="text-sm text-gray-500">
                      <span v-if="filial.codigo">Código: {{ filial.codigo }}</span>
                      <span v-if="filial.cnpj" class="ml-3">CNPJ: {{ filial.cnpj }}</span>
                    </div>
                    <div v-if="filial.endereco || filial.telefone" class="text-sm text-gray-500">
                      <span v-if="filial.endereco">{{ filial.endereco }}</span>
                      <span v-if="filial.telefone" class="ml-3">📞 {{ filial.telefone }}</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <button
                    @click="editFilial(filial)"
                    class="inline-flex items-center p-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click="toggleFilialStatus(filial)"
                    class="inline-flex items-center p-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    <svg v-if="filial.ativo" class="h-4 w-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14L21 3m0 0h-5.5M21 3v5.5M21 3l-3.5 3.5m-4.5 4.5L10 14l-4-4" />
                    </svg>
                    <svg v-else class="h-4 w-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <!-- Estado vazio -->
        <div v-if="filteredFiliais.length === 0" class="mt-6 text-center">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Nenhuma filial encontrada</h3>
          <p class="mt-1 text-sm text-gray-500">Comece criando uma nova filial.</p>
          <div class="mt-6">
            <button
              @click="showCreateModal = true"
              class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Nova Filial
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de criação/edição -->
    <div v-if="showCreateModal || showEditModal" class="fixed z-10 inset-0 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <form @submit.prevent="saveFilial">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mt-3 text-center sm:mt-0 sm:text-left w-full">
                  <h3 class="text-lg leading-6 font-medium text-gray-900">
                    {{ showCreateModal ? 'Nova Filial' : 'Editar Filial' }}
                  </h3>
                  <div class="mt-4 space-y-4">
                    <div>
                      <label for="nome" class="block text-sm font-medium text-gray-700">Nome *</label>
                      <input
                        id="nome"
                        v-model="formData.nome"
                        type="text"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="Nome da filial"
                      />
                    </div>
                    <div>
                      <label for="codigo" class="block text-sm font-medium text-gray-700">Código</label>
                      <input
                        id="codigo"
                        v-model="formData.codigo"
                        type="text"
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="FIL001"
                      />
                    </div>
                    <div>
                      <label for="cnpj" class="block text-sm font-medium text-gray-700">CNPJ</label>
                      <input
                        id="cnpj"
                        v-model="formData.cnpj"
                        type="text"
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="00.000.000/0000-00"
                      />
                    </div>
                    <div>
                      <label for="endereco" class="block text-sm font-medium text-gray-700">Endereço</label>
                      <textarea
                        id="endereco"
                        v-model="formData.endereco"
                        rows="2"
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="Endereço completo"
                      ></textarea>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                      <div>
                        <label for="telefone" class="block text-sm font-medium text-gray-700">Telefone</label>
                        <input
                          id="telefone"
                          v-model="formData.telefone"
                          type="text"
                          class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                          placeholder="(11) 99999-9999"
                        />
                      </div>
                      <div>
                        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
                        <input
                          id="email"
                          v-model="formData.email"
                          type="email"
                          class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                          placeholder="contato@filial.com"
                        />
                      </div>
                    </div>
                    <div>
                      <label for="responsavel" class="block text-sm font-medium text-gray-700">Responsável</label>
                      <input
                        id="responsavel"
                        v-model="formData.responsavel"
                        type="text"
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="Nome do responsável"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <button
                type="submit"
                :disabled="isLoading"
                class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50"
              >
                {{ isLoading ? 'Salvando...' : (showCreateModal ? 'Criar' : 'Salvar') }}
              </button>
              <button
                type="button"
                @click="closeModal"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { organizacoesService } from '@/services/organizacoes'
import AppLayout from '@/components/AppLayout.vue'

const router = useRouter()

const filiais = ref([])
const searchTerm = ref('')
const statusFilter = ref('')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const isLoading = ref(false)
const editingFilial = ref(null)

const formData = ref({
  id: '',
  nome: '',
  codigo: '',
  cnpj: '',
  endereco: '',
  telefone: '',
  email: '',
  responsavel: ''
})

const filteredFiliais = computed(() => {
  let filtered = filiais.value

  if (searchTerm.value) {
    filtered = filtered.filter(filial => 
      filial.nome.toLowerCase().includes(searchTerm.value.toLowerCase())
    )
  }

  if (statusFilter.value !== '') {
    const status = statusFilter.value === 'true'
    filtered = filtered.filter(filial => filial.ativo === status)
  }

  return filtered
})

const loadFiliais = async () => {
  try {
    console.log('FiliaisView: Carregando filiais...')
    const response = await organizacoesService.getFiliais()
    if (response.success) {
      filiais.value = response.filiais
      console.log('FiliaisView: Filiais carregadas:', filiais.value)
    }
  } catch (error) {
    console.error('FiliaisView: Erro ao carregar filiais:', error)
  }
}

const editFilial = (filial) => {
  editingFilial.value = filial
  formData.value = { ...filial }
  showEditModal.value = true
}

const toggleFilialStatus = async (filial) => {
  try {
    isLoading.value = true
    // TODO: Implementar toggle status
    console.log('Toggle status filial:', filial.id)
    filial.ativo = !filial.ativo
  } catch (error) {
    console.error('Erro ao alterar status:', error)
  } finally {
    isLoading.value = false
  }
}

const saveFilial = async () => {
  try {
    isLoading.value = true
    
    if (showCreateModal.value) {
      // Gerar ID para nova filial
      formData.value.id = `filial_${Date.now()}`
      const response = await organizacoesService.criarFilial(formData.value)
      if (response.success) {
        await loadFiliais()
        closeModal()
      }
    } else {
      // TODO: Implementar edição
      console.log('Editar filial:', formData.value)
      closeModal()
    }
  } catch (error) {
    console.error('Erro ao salvar filial:', error)
  } finally {
    isLoading.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  showEditModal.value = false
  editingFilial.value = null
  formData.value = {
    id: '',
    nome: '',
    codigo: '',
    cnpj: '',
    endereco: '',
    telefone: '',
    email: '',
    responsavel: ''
  }
}

onMounted(() => {
  loadFiliais()
})
</script>