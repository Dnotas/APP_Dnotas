<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Overlay -->
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="fechar"></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
          <!-- Header -->
          <div class="flex items-center justify-between mb-6">
            <div>
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Gerenciar Filiais - {{ cliente.nome_empresa }}
              </h3>
              <p class="text-sm text-gray-500">
                CNPJ Matriz: {{ formatarCnpj(cliente.cnpj) }}
              </p>
            </div>
            <button @click="fechar" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <!-- Loading -->
          <div v-if="loading" class="text-center py-8">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
            <p class="mt-2 text-sm text-gray-500">Carregando filiais...</p>
          </div>

          <!-- Content -->
          <div v-else class="space-y-6">
            <!-- Formulário Nova Filial -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="text-md font-medium text-gray-900 mb-4">Adicionar Nova Filial</h4>
              
              <form @submit.prevent="adicionarFilial" class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="block text-sm font-medium text-gray-700">CNPJ da Filial *</label>
                  <input
                    v-model="novaFilial.cnpj"
                    type="text"
                    placeholder="00.000.000/0000-00"
                    maxlength="18"
                    @input="formatarCnpjInput"
                    class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                  <p v-if="cnpjError" class="mt-1 text-sm text-red-600">{{ cnpjError }}</p>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Nome da Filial *</label>
                  <input
                    v-model="novaFilial.nome"
                    type="text"
                    placeholder="Ex: Filial Shopping Center"
                    class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Telefone</label>
                  <input
                    v-model="novaFilial.telefone"
                    type="text"
                    placeholder="(11) 99999-9999"
                    class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Email</label>
                  <input
                    v-model="novaFilial.email"
                    type="email"
                    placeholder="filial@empresa.com"
                    class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div class="sm:col-span-2">
                  <label class="block text-sm font-medium text-gray-700">Endereço</label>
                  <input
                    v-model="novaFilial.endereco"
                    type="text"
                    placeholder="Rua, número, bairro, cidade"
                    class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div class="sm:col-span-2">
                  <button
                    type="submit"
                    :disabled="salvandoFilial"
                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
                  >
                    <svg v-if="salvandoFilial" class="animate-spin -ml-1 mr-3 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ salvandoFilial ? 'Adicionando...' : 'Adicionar Filial' }}
                  </button>
                </div>
              </form>
            </div>

            <!-- Lista de Filiais -->
            <div>
              <h4 class="text-md font-medium text-gray-900 mb-4">
                Filiais Cadastradas ({{ filiais.length }})
              </h4>

              <div v-if="filiais.length === 0" class="text-center py-8 text-gray-500">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m0 0H5m4 0V9a2 2 0 012-2h2a2 2 0 012 2v12"></path>
                </svg>
                <p class="mt-2">Nenhuma filial cadastrada</p>
                <p class="text-xs">Use o formulário acima para adicionar a primeira filial</p>
              </div>

              <div v-else class="space-y-3">
                <div
                  v-for="filial in filiais"
                  :key="filial.cnpj"
                  class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50"
                >
                  <div class="flex items-center justify-between">
                    <div class="flex-1">
                      <div class="flex items-center space-x-3">
                        <div class="flex-shrink-0">
                          <span 
                            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                            :class="filial.tipo === 'matriz' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'"
                          >
                            {{ filial.tipo === 'matriz' ? 'Matriz' : 'Filial' }}
                          </span>
                        </div>
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">{{ filial.nome }}</h5>
                          <p class="text-sm text-gray-500">{{ formatarCnpj(filial.cnpj) }}</p>
                        </div>
                      </div>
                    </div>

                    <div v-if="filial.tipo === 'filial'" class="flex items-center space-x-2">
                      <span 
                        class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                        :class="filial.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                      >
                        {{ filial.ativo ? 'Ativo' : 'Inativo' }}
                      </span>
                      
                      <button
                        @click="toggleFilial(filial)"
                        class="text-sm text-primary-600 hover:text-primary-900"
                      >
                        {{ filial.ativo ? 'Desativar' : 'Ativar' }}
                      </button>
                      
                      <button
                        @click="removerFilial(filial)"
                        class="text-sm text-red-600 hover:text-red-900"
                      >
                        Remover
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
          <button
            @click="fechar"
            class="w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { clientFiliaisService } from '@/services/client-filiais'
import type { Client } from '@/types'

interface Props {
  isOpen: boolean
  cliente: Client
}

interface Emits {
  (e: 'close'): void
  (e: 'updated'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Estado
const loading = ref(false)
const salvandoFilial = ref(false)
const cnpjError = ref('')

// Dados
const filiais = ref<Array<{
  cnpj: string
  nome: string
  tipo: 'matriz' | 'filial'
  ativo: boolean
}>>([])

const novaFilial = ref({
  cnpj: '',
  nome: '',
  telefone: '',
  email: '',
  endereco: ''
})

// Computed
const formatarCnpj = (cnpj: string) => {
  return clientFiliaisService.formatarCnpj(cnpj)
}

// Watchers
watch(() => props.isOpen, async (isOpen) => {
  if (isOpen) {
    await carregarFiliais()
  } else {
    resetForm()
  }
})

// Métodos
const carregarFiliais = async () => {
  loading.value = true
  try {
    const response = await clientFiliaisService.getFiliais(props.cliente.cnpj)
    filiais.value = response.filiais || []
    console.log('✅ Filiais carregadas:', filiais.value)
  } catch (error) {
    console.error('❌ Erro ao carregar filiais:', error)
    // Toast de erro aqui
  } finally {
    loading.value = false
  }
}

const formatarCnpjInput = (event: Event) => {
  const input = event.target as HTMLInputElement
  let value = input.value.replace(/\D/g, '')
  
  // Formatar CNPJ
  if (value.length <= 14) {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
    novaFilial.value.cnpj = value
  }
  
  // Limpar erro
  cnpjError.value = ''
}

const validarCnpj = async (cnpj: string): Promise<boolean> => {
  const cnpjLimpo = clientFiliaisService.limparCnpj(cnpj)
  
  // Validar formato
  if (!clientFiliaisService.validarCnpj(cnpj)) {
    cnpjError.value = 'CNPJ inválido'
    return false
  }
  
  // Verificar se não é igual à matriz
  if (cnpjLimpo === clientFiliaisService.limparCnpj(props.cliente.cnpj)) {
    cnpjError.value = 'CNPJ não pode ser igual ao da matriz'
    return false
  }
  
  // Verificar se já existe
  try {
    const resultado = await clientFiliaisService.buscarCnpj(cnpjLimpo)
    if (resultado.found) {
      cnpjError.value = `CNPJ já cadastrado como ${resultado.tipo}`
      return false
    }
  } catch (error) {
    console.error('Erro ao validar CNPJ:', error)
  }
  
  return true
}

const adicionarFilial = async () => {
  if (!await validarCnpj(novaFilial.value.cnpj)) {
    return
  }
  
  salvandoFilial.value = true
  try {
    await clientFiliaisService.adicionarFilial({
      matriz_cnpj: clientFiliaisService.limparCnpj(props.cliente.cnpj),
      filial_cnpj: clientFiliaisService.limparCnpj(novaFilial.value.cnpj),
      filial_nome: novaFilial.value.nome,
      endereco: novaFilial.value.endereco || undefined,
      telefone: novaFilial.value.telefone || undefined,
      email: novaFilial.value.email || undefined
    })
    
    // Recarregar lista
    await carregarFiliais()
    
    // Limpar formulário
    resetForm()
    
    // Notificar pai
    emit('updated')
    
    console.log('✅ Filial adicionada com sucesso')
    
  } catch (error) {
    console.error('❌ Erro ao adicionar filial:', error)
    // Toast de erro aqui
  } finally {
    salvandoFilial.value = false
  }
}

const toggleFilial = async (filial: any) => {
  // Implementar toggle ativo/inativo
  console.log('Toggle filial:', filial)
}

const removerFilial = async (filial: any) => {
  if (confirm(`Tem certeza que deseja remover a filial "${filial.nome}"?`)) {
    // Implementar remoção
    console.log('Remover filial:', filial)
  }
}

const resetForm = () => {
  novaFilial.value = {
    cnpj: '',
    nome: '',
    telefone: '',
    email: '',
    endereco: ''
  }
  cnpjError.value = ''
}

const fechar = () => {
  emit('close')
}
</script>