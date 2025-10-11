<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <div class="md:flex md:items-center md:justify-between">
          <div class="flex-1 min-w-0">
            <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              Gestão de Funcionários
            </h2>
            <p class="mt-1 text-sm text-gray-500">
              Gerencie funcionários de todas as filiais
            </p>
          </div>
          <div class="mt-4 flex md:mt-0 md:ml-4">
            <button
              @click="showCreateModal = true"
              class="ml-3 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
              </svg>
              Novo Funcionário
            </button>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <!-- Filtros -->
        <div class="mt-6 bg-white shadow rounded-lg">
          <div class="p-6">
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-4">
              <div>
                <label for="search" class="block text-sm font-medium text-gray-700">Buscar</label>
                <input
                  id="search"
                  v-model="searchTerm"
                  type="text"
                  placeholder="Nome ou email..."
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                />
              </div>
              <div>
                <label for="filial" class="block text-sm font-medium text-gray-700">Filial</label>
                <select
                  id="filial"
                  v-model="filialFilter"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                >
                  <option value="">Todas</option>
                  <option v-for="filial in filiais" :key="filial.id" :value="filial.id">
                    {{ filial.nome }}
                  </option>
                </select>
              </div>
              <div>
                <label for="role" class="block text-sm font-medium text-gray-700">Função</label>
                <select
                  id="role"
                  v-model="roleFilter"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                >
                  <option value="">Todas</option>
                  <option value="admin">Administrador</option>
                  <option value="manager">Gerente</option>
                  <option value="operator">Operador</option>
                </select>
              </div>
              <div class="flex items-end">
                <button
                  @click="loadFuncionarios"
                  class="w-full inline-flex justify-center items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
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

        <!-- Lista de funcionários -->
        <div class="mt-6 bg-white shadow overflow-hidden sm:rounded-md">
          <ul role="list" class="divide-y divide-gray-200">
            <li v-for="funcionario in filteredFuncionarios" :key="funcionario.id">
              <div class="px-4 py-4 flex items-center justify-between hover:bg-gray-50">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-full bg-gradient-to-r from-green-500 to-green-600 flex items-center justify-center">
                      <span class="text-white font-medium text-sm">
                        {{ funcionario.nome.charAt(0).toUpperCase() }}
                      </span>
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="flex items-center">
                      <div class="text-sm font-medium text-gray-900">
                        {{ funcionario.nome }}
                      </div>
                      <span 
                        class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                        :class="getRoleColor(funcionario.role)"
                      >
                        {{ getRoleLabel(funcionario.role) }}
                      </span>
                      <span 
                        class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                        :class="funcionario.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                      >
                        {{ funcionario.ativo ? 'Ativo' : 'Inativo' }}
                      </span>
                    </div>
                    <div class="text-sm text-gray-500">
                      <span>📧 {{ funcionario.email }}</span>
                      <span class="ml-3">💼 {{ funcionario.cargo }}</span>
                    </div>
                    <div class="text-sm text-gray-500">
                      <span>🏢 {{ getFilialNome(funcionario.organizacao_id) }}</span>
                      <span v-if="funcionario.ultimo_login" class="ml-3">
                        🕐 Último login: {{ formatTime(funcionario.ultimo_login) }}
                      </span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <button
                    @click="editFuncionario(funcionario)"
                    class="inline-flex items-center p-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                  >
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click="toggleFuncionarioStatus(funcionario)"
                    class="inline-flex items-center p-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                  >
                    <svg v-if="funcionario.ativo" class="h-4 w-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728L5.636 5.636m12.728 12.728L18.364 5.636" />
                    </svg>
                    <svg v-else class="h-4 w-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </button>
                  <button
                    @click="viewAtividades(funcionario)"
                    class="inline-flex items-center p-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                  >
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <!-- Estado vazio -->
        <div v-if="filteredFuncionarios.length === 0" class="mt-6 text-center">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Nenhum funcionário encontrado</h3>
          <p class="mt-1 text-sm text-gray-500">Comece criando um novo funcionário.</p>
          <div class="mt-6">
            <button
              @click="showCreateModal = true"
              class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
              </svg>
              Novo Funcionário
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
          <form @submit.prevent="saveFuncionario">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mt-3 text-center sm:mt-0 sm:text-left w-full">
                  <h3 class="text-lg leading-6 font-medium text-gray-900">
                    {{ showCreateModal ? 'Novo Funcionário' : 'Editar Funcionário' }}
                  </h3>
                  <div class="mt-4 space-y-4">
                    <div>
                      <label for="nome" class="block text-sm font-medium text-gray-700">Nome Completo *</label>
                      <input
                        id="nome"
                        v-model="formData.nome"
                        type="text"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                        placeholder="Nome completo"
                      />
                    </div>
                    <div>
                      <label for="email" class="block text-sm font-medium text-gray-700">Email *</label>
                      <input
                        id="email"
                        v-model="formData.email"
                        type="email"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                        placeholder="email@exemplo.com"
                      />
                    </div>
                    <div>
                      <label for="cargo" class="block text-sm font-medium text-gray-700">Cargo *</label>
                      <input
                        id="cargo"
                        v-model="formData.cargo"
                        type="text"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                        placeholder="Atendente, Analista, Gerente..."
                      />
                    </div>
                    <div>
                      <label for="organizacao_id" class="block text-sm font-medium text-gray-700">Filial *</label>
                      <select
                        id="organizacao_id"
                        v-model="formData.organizacao_id"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                      >
                        <option value="">Selecione a filial</option>
                        <option v-for="filial in filiais" :key="filial.id" :value="filial.id">
                          {{ filial.nome }}
                        </option>
                      </select>
                    </div>
                    <div>
                      <label for="role" class="block text-sm font-medium text-gray-700">Função *</label>
                      <select
                        id="role"
                        v-model="formData.role"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                      >
                        <option value="operator">👤 Operador</option>
                        <option value="manager">👨‍💼 Gerente</option>
                        <option value="admin">👑 Administrador</option>
                      </select>
                    </div>
                    <div v-if="showCreateModal">
                      <label for="senha" class="block text-sm font-medium text-gray-700">Senha *</label>
                      <input
                        id="senha"
                        v-model="formData.senha"
                        type="password"
                        :required="showCreateModal"
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm"
                        placeholder="Mínimo 6 caracteres"
                        minlength="6"
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
                class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-green-600 text-base font-medium text-white hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50"
              >
                {{ isLoading ? 'Salvando...' : (showCreateModal ? 'Criar' : 'Salvar') }}
              </button>
              <button
                type="button"
                @click="closeModal"
                class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
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
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const router = useRouter()

const funcionarios = ref([])
const filiais = ref([])
const searchTerm = ref('')
const filialFilter = ref('')
const roleFilter = ref('')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const isLoading = ref(false)
const editingFuncionario = ref(null)

const formData = ref({
  nome: '',
  email: '',
  cargo: '',
  organizacao_id: '',
  role: 'operator',
  senha: ''
})

const filteredFuncionarios = computed(() => {
  let filtered = funcionarios.value

  if (searchTerm.value) {
    const term = searchTerm.value.toLowerCase()
    filtered = filtered.filter(func => 
      func.nome.toLowerCase().includes(term) || 
      func.email.toLowerCase().includes(term)
    )
  }

  if (filialFilter.value) {
    filtered = filtered.filter(func => func.organizacao_id === filialFilter.value)
  }

  if (roleFilter.value) {
    filtered = filtered.filter(func => func.role === roleFilter.value)
  }

  return filtered
})

const getRoleColor = (role: string) => {
  const colors = {
    'admin': 'bg-red-100 text-red-800',
    'manager': 'bg-blue-100 text-blue-800',
    'operator': 'bg-gray-100 text-gray-800'
  }
  return colors[role] || colors.operator
}

const getRoleLabel = (role: string) => {
  const labels = {
    'admin': 'Administrador',
    'manager': 'Gerente',
    'operator': 'Operador'
  }
  return labels[role] || 'Operador'
}

const getFilialNome = (organizacaoId: string) => {
  const filial = filiais.value.find(f => f.id === organizacaoId)
  return filial ? filial.nome : 'Filial não encontrada'
}

const formatTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { 
    addSuffix: true, 
    locale: ptBR 
  })
}

const loadFiliais = async () => {
  try {
    const response = await organizacoesService.getOrganizacoes()
    if (response.success) {
      filiais.value = response.organizacoes
    }
  } catch (error) {
    console.error('Erro ao carregar filiais:', error)
  }
}

const loadFuncionarios = async () => {
  try {
    console.log('FuncionariosView: Carregando funcionários...')
    
    // Carregar funcionários de todas as organizações
    const allFuncionarios = []
    
    for (const filial of filiais.value) {
      const response = await organizacoesService.getFuncionarios(filial.id)
      if (response.success) {
        allFuncionarios.push(...response.funcionarios)
      }
    }
    
    funcionarios.value = allFuncionarios
    console.log('FuncionariosView: Funcionários carregados:', funcionarios.value)
  } catch (error) {
    console.error('FuncionariosView: Erro ao carregar funcionários:', error)
  }
}

const editFuncionario = (funcionario) => {
  editingFuncionario.value = funcionario
  formData.value = { 
    nome: funcionario.nome,
    email: funcionario.email,
    cargo: funcionario.cargo,
    organizacao_id: funcionario.organizacao_id,
    role: funcionario.role,
    senha: ''
  }
  showEditModal.value = true
}

const toggleFuncionarioStatus = async (funcionario) => {
  try {
    isLoading.value = true
    // TODO: Implementar toggle status
    console.log('Toggle status funcionário:', funcionario.id)
    funcionario.ativo = !funcionario.ativo
  } catch (error) {
    console.error('Erro ao alterar status:', error)
  } finally {
    isLoading.value = false
  }
}

const viewAtividades = (funcionario) => {
  console.log('Ver atividades do funcionário:', funcionario.id)
  // TODO: Implementar página de atividades
}

const saveFuncionario = async () => {
  try {
    isLoading.value = true
    
    if (showCreateModal.value) {
      const response = await organizacoesService.criarFuncionario(formData.value)
      if (response.success) {
        await loadFuncionarios()
        closeModal()
      }
    } else {
      // TODO: Implementar edição
      console.log('Editar funcionário:', formData.value)
      closeModal()
    }
  } catch (error) {
    console.error('Erro ao salvar funcionário:', error)
  } finally {
    isLoading.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  showEditModal.value = false
  editingFuncionario.value = null
  formData.value = {
    nome: '',
    email: '',
    cargo: '',
    organizacao_id: '',
    role: 'operator',
    senha: ''
  }
}

onMounted(async () => {
  await loadFiliais()
  await loadFuncionarios()
})
</script>