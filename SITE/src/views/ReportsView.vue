<template>
  <AppLayout>
    <div class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
        <h1 class="text-2xl font-semibold text-gray-900">Relatórios</h1>
        
        <!-- Solicitações Pendentes -->
        <div class="mt-6 bg-white shadow rounded-lg">
          <div class="px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <h2 class="text-lg font-medium text-gray-900">Solicitações Pendentes</h2>
              <div class="flex items-center">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                  {{ solicitacoesPendentes.length }} pendentes
                </span>
                <button 
                  @click="loadSolicitacoes"
                  class="ml-3 inline-flex items-center px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
                >
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                  </svg>
                  Atualizar
                </button>
              </div>
            </div>
          </div>
          
          <div class="px-6 py-4">
            <div v-if="loading" class="flex justify-center">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
            
            <div v-else-if="solicitacoesPendentes.length === 0" class="text-center py-8">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">Nenhuma solicitação pendente</h3>
              <p class="mt-1 text-sm text-gray-500">Todas as solicitações estão processadas.</p>
            </div>
            
            <div v-else class="space-y-4">
              <div 
                v-for="solicitacao in solicitacoesPendentes" 
                :key="solicitacao.id"
                class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50"
              >
                <div class="flex items-start justify-between">
                  <div class="flex-1">
                    <div class="flex items-center">
                      <h3 class="text-sm font-medium text-gray-900">{{ solicitacao.cliente_cnpj }}</h3>
                      <span 
                        :class="{
                          'bg-orange-100 text-orange-800': solicitacao.status === 'pendente',
                          'bg-blue-100 text-blue-800': solicitacao.status === 'processando'
                        }"
                        class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      >
                        {{ solicitacao.status.toUpperCase() }}
                      </span>
                    </div>
                    <div class="mt-1 text-sm text-gray-500">
                      <p><strong>Período:</strong> {{ formatPeriodo(solicitacao) }}</p>
                      <p><strong>Tipo:</strong> {{ solicitacao.tipo_periodo === 'dia_unico' ? 'Dia único' : 'Intervalo' }}</p>
                      <p><strong>Solicitado em:</strong> {{ formatDate(solicitacao.data_solicitacao) }}</p>
                      <p v-if="solicitacao.observacoes"><strong>Observações:</strong> {{ solicitacao.observacoes }}</p>
                    </div>
                  </div>
                  <div class="ml-4 flex-shrink-0">
                    <button 
                      @click="abrirModalProcessamento(solicitacao)"
                      class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                    >
                      Processar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal de Processamento -->
        <div v-if="modalAberto" class="fixed inset-0 z-50 overflow-y-auto">
          <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div class="fixed inset-0 transition-opacity">
              <div class="absolute inset-0 bg-gray-500 opacity-75" @click="fecharModal"></div>
            </div>

            <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="sm:flex sm:items-start">
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                    <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">
                      Processar Relatório
                    </h3>
                    
                    <div v-if="solicitacaoSelecionada" class="space-y-4">
                      <div class="bg-gray-50 p-3 rounded">
                        <p><strong>Cliente:</strong> {{ solicitacaoSelecionada.cliente_cnpj }}</p>
                        <p><strong>Período:</strong> {{ formatPeriodo(solicitacaoSelecionada) }}</p>
                      </div>

                      <div v-for="(data, index) in datasParaProcessar" :key="index" class="border border-gray-200 rounded p-3">
                        <h4 class="font-medium text-gray-900 mb-2">{{ data.data_relatorio }}</h4>
                        <div class="grid grid-cols-3 gap-4">
                          <div>
                            <label class="block text-xs font-medium text-gray-700">Crédito</label>
                            <input 
                              v-model.number="data.vendas_credito" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-700">Débito</label>
                            <input 
                              v-model.number="data.vendas_debito" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-700">PIX</label>
                            <input 
                              v-model.number="data.vendas_pix" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-700">Vale</label>
                            <input 
                              v-model.number="data.vendas_vale" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-700">Dinheiro</label>
                            <input 
                              v-model.number="data.vendas_dinheiro" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-700">Transferência</label>
                            <input 
                              v-model.number="data.vendas_transferencia" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm text-sm"
                            >
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <button 
                  @click="processarRelatorio"
                  :disabled="processando"
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 disabled:opacity-50 sm:ml-3 sm:w-auto sm:text-sm"
                >
                  <span v-if="processando">Processando...</span>
                  <span v-else>Salvar Relatório</span>
                </button>
                <button 
                  @click="fecharModal"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
                >
                  Cancelar
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
import AppLayout from '@/components/AppLayout.vue'

const loading = ref(false)
const solicitacoesPendentes = ref([])
const modalAberto = ref(false)
const solicitacaoSelecionada = ref(null)
const datasParaProcessar = ref([])
const processando = ref(false)

const API_BASE_URL = 'https://api.dnotas.com.br:9999'

onMounted(() => {
  loadSolicitacoes()
})

async function loadSolicitacoes() {
  loading.value = true
  try {
    const response = await fetch(`${API_BASE_URL}/api/admin/solicitacoes/pendentes`)
    const data = await response.json()
    
    if (data.success) {
      solicitacoesPendentes.value = data.data
    }
  } catch (error) {
    console.error('Erro ao carregar solicitações:', error)
  } finally {
    loading.value = false
  }
}

function formatPeriodo(solicitacao) {
  const inicio = new Date(solicitacao.data_inicio).toLocaleDateString('pt-BR')
  const fim = new Date(solicitacao.data_fim).toLocaleDateString('pt-BR')
  
  if (solicitacao.tipo_periodo === 'dia_unico') {
    return inicio
  } else {
    return `${inicio} até ${fim}`
  }
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleString('pt-BR')
}

function abrirModalProcessamento(solicitacao) {
  solicitacaoSelecionada.value = solicitacao
  modalAberto.value = true
  
  // Gerar datas para processamento
  const dataInicio = new Date(solicitacao.data_inicio)
  const dataFim = new Date(solicitacao.data_fim)
  const datas = []
  
  const current = new Date(dataInicio)
  while (current <= dataFim) {
    datas.push({
      data_relatorio: current.toISOString().split('T')[0],
      vendas_credito: 0,
      vendas_debito: 0,
      vendas_pix: 0,
      vendas_vale: 0,
      vendas_dinheiro: 0,
      vendas_transferencia: 0
    })
    current.setDate(current.getDate() + 1)
  }
  
  datasParaProcessar.value = datas
}

function fecharModal() {
  modalAberto.value = false
  solicitacaoSelecionada.value = null
  datasParaProcessar.value = []
}

async function processarRelatorio() {
  if (!solicitacaoSelecionada.value) return
  
  processando.value = true
  try {
    const response = await fetch(`${API_BASE_URL}/api/admin/relatorios/processar/${solicitacaoSelecionada.value.id}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        relatorios_dados: datasParaProcessar.value,
        processado_por: 'Sistema' // TODO: pegar usuário logado
      })
    })
    
    const data = await response.json()
    
    if (data.success) {
      alert('Relatório processado com sucesso!')
      fecharModal()
      loadSolicitacoes() // Recarregar lista
    } else {
      throw new Error(data.error)
    }
  } catch (error) {
    console.error('Erro ao processar relatório:', error)
    alert('Erro ao processar relatório: ' + error.message)
  } finally {
    processando.value = false
  }
}
</script>