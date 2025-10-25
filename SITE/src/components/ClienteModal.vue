<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Overlay -->
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="fechar"></div>

      <!-- Modal -->
      <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
          <!-- Header -->
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              {{ isEditing ? 'Editar Cliente' : 'Novo Cliente' }}
            </h3>
            <button @click="fechar" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <!-- Loading -->
          <div v-if="loading" class="text-center py-8">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
            <p class="mt-2 text-sm text-gray-500">{{ isEditing ? 'Carregando dados...' : 'Salvando...' }}</p>
          </div>

          <!-- Form -->
          <form v-else @submit.prevent="salvar" class="space-y-6">
            <!-- Dados Básicos -->
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div class="sm:col-span-2">
                <label class="block text-sm font-medium text-gray-700">Nome da Empresa *</label>
                <input
                  v-model="form.nome_empresa"
                  type="text"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">CNPJ *</label>
                <input
                  v-model="form.cnpj"
                  type="text"
                  placeholder="00.000.000/0000-00"
                  maxlength="18"
                  @input="formatarCnpjInput"
                  :disabled="isEditing"
                  required
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 disabled:bg-gray-100"
                />
                <p v-if="isEditing" class="mt-1 text-xs text-gray-500">CNPJ não pode ser alterado</p>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input
                  v-model="form.email"
                  type="email"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">Telefone</label>
                <input
                  v-model="form.telefone"
                  type="text"
                  placeholder="(11) 99999-9999"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">Senha *</label>
                <input
                  v-model="form.senha"
                  type="password"
                  :required="!isEditing"
                  :placeholder="isEditing ? 'Deixe em branco para manter a senha atual' : 'Digite a senha'"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>

            <!-- Seção de Filiais -->
            <div class="border-t pt-6">
              <div class="flex items-center justify-between mb-4">
                <h4 class="text-md font-medium text-gray-900">Filiais</h4>
                <button
                  type="button"
                  @click="adicionarFilial"
                  class="inline-flex items-center px-3 py-1 border border-transparent text-sm leading-4 font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200"
                >
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                  Adicionar Filial
                </button>
              </div>

              <div v-if="form.filiais.length === 0" class="text-center py-4 text-gray-500 bg-gray-50 rounded-lg">
                <p class="text-sm">Nenhuma filial cadastrada</p>
                <p class="text-xs">Clique em "Adicionar Filial" para incluir filiais</p>
              </div>

              <div v-else class="space-y-3">
                <div
                  v-for="(filial, index) in form.filiais"
                  :key="index"
                  class="border border-gray-200 rounded-lg p-4 bg-gray-50"
                >
                  <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                    <div>
                      <label class="block text-sm font-medium text-gray-700">CNPJ da Filial *</label>
                      <input
                        v-model="filial.cnpj"
                        type="text"
                        placeholder="00.000.000/0000-00"
                        maxlength="18"
                        @input="formatarCnpjFilial(index, $event)"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">Nome da Filial *</label>
                      <input
                        v-model="filial.nome"
                        type="text"
                        placeholder="Ex: Filial Shopping"
                        required
                        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>

                    <div class="flex items-end">
                      <button
                        type="button"
                        @click="removerFilial(index)"
                        class="w-full inline-flex justify-center items-center px-3 py-2 border border-red-300 text-sm leading-4 font-medium rounded-md text-red-700 bg-red-50 hover:bg-red-100"
                      >
                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        Remover
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>

        <!-- Footer -->
        <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
          <button
            @click="salvar"
            :disabled="salvando"
            class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-primary-600 text-base font-medium text-white hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50"
          >
            <svg v-if="salvando" class="animate-spin -ml-1 mr-3 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ salvando ? 'Salvando...' : (isEditing ? 'Atualizar' : 'Criar') }}
          </button>
          
          <button
            @click="fechar"
            type="button"
            class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Client } from '@/types'

interface Props {
  isOpen: boolean
  cliente?: Client | null
}

interface Emits {
  (e: 'close'): void
  (e: 'saved'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Estado
const loading = ref(false)
const salvando = ref(false)

// Form data
const form = ref({
  nome_empresa: '',
  cnpj: '',
  email: '',
  telefone: '',
  senha: '',
  filiais: [] as Array<{ cnpj: string; nome: string }>
})

// Computed
const isEditing = computed(() => !!props.cliente)

// Watchers
watch(() => props.isOpen, async (isOpen) => {
  if (isOpen) {
    if (props.cliente) {
      await carregarDadosCliente()
    } else {
      resetForm()
    }
  }
})

// Métodos
const carregarDadosCliente = async () => {
  if (!props.cliente) return
  
  loading.value = true
  try {
    // Preencher dados básicos
    form.value.nome_empresa = props.cliente.nome_empresa
    form.value.cnpj = formatarCnpj(props.cliente.cnpj)
    form.value.email = props.cliente.email || ''
    form.value.telefone = props.cliente.telefone || ''
    form.value.senha = ''
    
    // Carregar filiais (implementar busca via API)
    // TODO: Buscar filiais do cliente
    form.value.filiais = []
    
  } catch (error) {
    console.error('Erro ao carregar dados do cliente:', error)
  } finally {
    loading.value = false
  }
}

const formatarCnpj = (cnpj: string) => {
  return cnpj.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
}

const formatarCnpjInput = (event: Event) => {
  const input = event.target as HTMLInputElement
  let value = input.value.replace(/\D/g, '')
  
  if (value.length <= 14) {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
    form.value.cnpj = value
  }
}

const formatarCnpjFilial = (index: number, event: Event) => {
  const input = event.target as HTMLInputElement
  let value = input.value.replace(/\D/g, '')
  
  if (value.length <= 14) {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
    form.value.filiais[index].cnpj = value
  }
}

const adicionarFilial = () => {
  form.value.filiais.push({
    cnpj: '',
    nome: ''
  })
}

const removerFilial = (index: number) => {
  form.value.filiais.splice(index, 1)
}

const salvar = async () => {
  salvando.value = true
  try {
    // TODO: Implementar salvamento via API
    console.log('Salvando cliente:', form.value)
    
    // Simular delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    emit('saved')
    fechar()
    
  } catch (error) {
    console.error('Erro ao salvar cliente:', error)
  } finally {
    salvando.value = false
  }
}

const resetForm = () => {
  form.value = {
    nome_empresa: '',
    cnpj: '',
    email: '',
    telefone: '',
    senha: '',
    filiais: []
  }
}

const fechar = () => {
  emit('close')
}
</script>