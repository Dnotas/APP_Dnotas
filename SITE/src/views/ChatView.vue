<template>
  <AppLayout>
    <div class="flex h-screen bg-gray-950">
      <!-- Sidebar de conversas -->
      <div class="w-80 bg-gray-900 border-r border-gray-700 flex flex-col">
        <!-- Header da sidebar -->
        <div class="px-4 py-6 border-b border-gray-700">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-medium text-white">Atendimentos</h2>
            <div class="flex items-center space-x-2">
              <button
                @click="toggleAtendimentoStatus"
                :class="[
                  'flex items-center px-3 py-1 rounded-full text-xs font-medium transition-colors',
                  funcionarioAtivo 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-gray-100 text-gray-800'
                ]"
              >
                <div 
                  :class="[
                    'w-2 h-2 rounded-full mr-2',
                    funcionarioAtivo ? 'bg-green-500' : 'bg-gray-400'
                  ]"
                ></div>
                {{ funcionarioAtivo ? 'Online' : 'Offline' }}
              </button>
            </div>
          </div>
          
          <!-- Filtros -->
          <div class="mt-4 space-y-3">
            <div class="relative">
              <input
                v-model="searchQuery"
                type="text"
                class="block w-full pl-3 pr-10 py-2 border border-gray-600 rounded-md leading-5 bg-gray-800 text-white placeholder-gray-400 focus:outline-none focus:placeholder-gray-300 focus:ring-1 focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                placeholder="Buscar cliente..."
              />
              <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                <SearchIcon class="h-5 w-5 text-gray-400" aria-hidden="true" />
              </div>
            </div>
            
            <select
              v-model="filtroStatus"
              class="block w-full py-2 px-3 border border-gray-600 bg-gray-800 text-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
            >
              <option value="">Todos os status</option>
              <option value="aberto">Aberto</option>
              <option value="em_atendimento">Em atendimento</option>
              <option value="aguardando_cliente">Aguardando cliente</option>
              <option value="finalizado">Finalizado</option>
            </select>
          </div>
        </div>
        
        <!-- Lista de conversas -->
        <div class="flex-1 overflow-y-auto">
          <div v-if="loading" class="p-4 text-center text-gray-400">
            Carregando conversas...
          </div>
          
          <div v-else-if="conversasFiltradas.length === 0" class="p-4 text-center text-gray-400">
            Nenhuma conversa encontrada
          </div>
          
          <div v-else class="divide-y divide-gray-700">
            <div
              v-for="conversa in conversasFiltradas"
              :key="conversa.id"
              class="px-4 py-4 hover:bg-gray-800 cursor-pointer transition-colors relative"
              :class="{ 'bg-gray-800 border-r-2 border-primary-500': conversaSelecionada?.id === conversa.id }"
              @click="selecionarConversa(conversa)"
            >
              <!-- Indicador de prioridade -->
              <div
                v-if="conversa.prioridade === 'alta' || conversa.prioridade === 'urgente'"
                :class="[
                  'absolute left-0 top-0 bottom-0 w-1',
                  conversa.prioridade === 'urgente' ? 'bg-red-500' : 'bg-orange-400'
                ]"
              ></div>
              
              <div class="flex items-start space-x-3">
                <div class="flex-shrink-0 relative">
                  <div class="h-10 w-10 rounded-full bg-primary-500 flex items-center justify-center">
                    <span class="text-white text-sm font-medium">
                      {{ conversa.cliente_nome.charAt(0).toUpperCase() }}
                    </span>
                  </div>
                  
                  <!-- Status badge -->
                  <div
                    :class="[
                      'absolute -bottom-1 -right-1 h-3 w-3 border-2 border-white rounded-full',
                      getStatusColor(conversa.status)
                    ]"
                  ></div>
                </div>
                
                <div class="flex-1 min-w-0">
                  <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-white truncate">
                      {{ conversa.cliente_nome }}
                    </p>
                    <div class="flex items-center space-x-1">
                      <span
                        v-if="conversa.mensagens_nao_lidas > 0"
                        class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
                      >
                        {{ conversa.mensagens_nao_lidas }}
                      </span>
                      <span class="text-xs text-gray-400">
                        {{ formatarTempo(conversa.ultima_mensagem_em) }}
                      </span>
                    </div>
                  </div>
                  
                  <p class="text-sm font-medium text-gray-300 truncate mt-1">
                    {{ conversa.titulo }}
                  </p>
                  
                  <div class="flex items-center justify-between mt-1">
                    <span 
                      :class="[
                        'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium',
                        getStatusBadgeColor(conversa.status)
                      ]"
                    >
                      {{ getStatusText(conversa.status) }}
                    </span>
                    
                    <span 
                      v-if="conversa.prioridade !== 'normal'"
                      :class="[
                        'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium',
                        getPrioridadeBadgeColor(conversa.prioridade)
                      ]"
                    >
                      {{ conversa.prioridade.charAt(0).toUpperCase() + conversa.prioridade.slice(1) }}
                    </span>
                  </div>
                  
                  <p class="text-xs text-gray-400 truncate mt-1">
                    {{ conversa.ultima_mensagem || 'Nenhuma mensagem ainda' }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Área do chat -->
      <div class="flex-1 flex flex-col">
        <!-- Estado vazio -->
        <div v-if="!conversaSelecionada" class="flex-1 flex items-center justify-center bg-gray-900">
          <div class="text-center">
            <ChatIcon class="mx-auto h-12 w-12 text-gray-500" />
            <h3 class="mt-2 text-sm font-medium text-white">Selecione uma conversa</h3>
            <p class="mt-1 text-sm text-gray-400">
              Escolha uma conversa na lista para começar o atendimento.
            </p>
          </div>
        </div>

        <!-- Chat ativo -->
        <div v-else class="flex-1 flex flex-col">
          <!-- Header do chat -->
          <div class="px-6 py-4 border-b border-gray-700 bg-gray-900">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="flex-shrink-0">
                  <div class="h-10 w-10 rounded-full bg-primary-500 flex items-center justify-center">
                    <span class="text-white text-sm font-medium">
                      {{ conversaSelecionada.cliente_nome.charAt(0).toUpperCase() }}
                    </span>
                  </div>
                </div>
                <div>
                  <h3 class="text-lg font-medium text-white">
                    {{ conversaSelecionada.cliente_nome }}
                  </h3>
                  <p class="text-sm text-gray-400">
                    {{ conversaSelecionada.titulo }}
                  </p>
                </div>
              </div>
              
              <div class="flex items-center space-x-2">
                <!-- Assumir atendimento -->
                <button
                  v-if="!conversaSelecionada.atendente_nome"
                  @click="assumirAtendimento"
                  :disabled="assumindoAtendimento"
                  class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
                >
                  <UserAddIcon class="h-4 w-4 mr-2" />
                  {{ assumindoAtendimento ? 'Assumindo...' : 'Assumir' }}
                </button>
                
                <!-- Finalizar conversa -->
                <button
                  v-if="conversaSelecionada.atendente_nome && conversaSelecionada.status !== 'finalizado'"
                  @click="finalizarConversa"
                  :disabled="finalizandoConversa"
                  class="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                >
                  <CheckIcon class="h-4 w-4 mr-2" />
                  {{ finalizandoConversa ? 'Finalizando...' : 'Finalizar' }}
                </button>
                
                <!-- Menu de opções -->
                <div class="relative" ref="menuRef">
                  <button
                    @click="mostrarMenu = !mostrarMenu"
                    class="p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500 rounded-md"
                  >
                    <DotsVerticalIcon class="h-5 w-5" />
                  </button>
                  
                  <!-- Menu dropdown -->
                  <div
                    v-if="mostrarMenu"
                    class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg ring-1 ring-black ring-opacity-5 z-10"
                  >
                    <div class="py-1">
                      <button
                        @click="mostrarTemplates = true; mostrarMenu = false"
                        class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        <TemplateIcon class="inline h-4 w-4 mr-2" />
                        Templates
                      </button>
                      <button
                        @click="uploadFile"
                        class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        <PaperClipIcon class="inline h-4 w-4 mr-2" />
                        Anexar arquivo
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Área de mensagens -->
          <div
            ref="mensagensContainer"
            class="flex-1 overflow-y-auto p-6 bg-gray-950 space-y-4"
          >
            <div v-if="carregandoMensagens" class="text-center text-gray-400">
              Carregando mensagens...
            </div>
            
            <div
              v-for="mensagem in mensagens"
              :key="mensagem.id"
              class="flex"
              :class="mensagem.remetente_tipo === 'cliente' ? 'justify-start' : 'justify-end'"
            >
              <div
                class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg"
                :class="mensagem.remetente_tipo === 'cliente' 
                  ? 'bg-white text-gray-900 shadow-sm' 
                  : mensagem.remetente_tipo === 'funcionario'
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-200 text-gray-700'"
              >
                <!-- Nome do remetente para mensagens do sistema -->
                <p 
                  v-if="mensagem.remetente_tipo === 'sistema'" 
                  class="text-xs font-medium text-gray-600 mb-1"
                >
                  {{ mensagem.remetente_nome }}
                </p>
                
                <!-- Conteúdo da mensagem -->
                <p class="text-sm whitespace-pre-wrap">{{ mensagem.conteudo }}</p>
                
                <!-- Arquivo anexo -->
                <div 
                  v-if="mensagem.arquivo_url" 
                  class="mt-2 p-2 bg-gray-100 rounded border"
                  :class="mensagem.remetente_tipo !== 'cliente' ? 'bg-primary-500' : ''"
                >
                  <a 
                    :href="getFileUrl(mensagem.arquivo_url)" 
                    target="_blank"
                    class="text-xs flex items-center space-x-1 hover:underline"
                    :class="mensagem.remetente_tipo !== 'cliente' ? 'text-white' : 'text-gray-700'"
                  >
                    <PaperClipIcon class="h-3 w-3" />
                    <span>{{ mensagem.arquivo_nome }}</span>
                  </a>
                </div>
                
                <!-- Timestamp -->
                <p
                  class="text-xs mt-1"
                  :class="mensagem.remetente_tipo === 'cliente' ? 'text-gray-500' : 
                          mensagem.remetente_tipo === 'funcionario' ? 'text-primary-100' : 'text-gray-500'"
                >
                  {{ formatarHoraMensagem(mensagem.created_at) }}
                </p>
              </div>
            </div>
          </div>

          <!-- Input de mensagem -->
          <div class="px-6 py-4 bg-gray-900 border-t border-gray-700">
            <div v-if="arquivoAnexado" class="mb-3 p-2 bg-gray-100 rounded flex items-center justify-between">
              <div class="flex items-center space-x-2">
                <PaperClipIcon class="h-4 w-4 text-gray-500" />
                <span class="text-sm text-gray-700">{{ arquivoAnexado.name }}</span>
              </div>
              <button @click="removerArquivo" class="text-red-500 hover:text-red-700">
                <XIcon class="h-4 w-4" />
              </button>
            </div>
            
            <form @submit.prevent="enviarMensagem" class="flex space-x-4">
              <div class="flex-1">
                <textarea
                  v-model="novaMensagem"
                  rows="2"
                  class="block w-full border border-gray-600 bg-gray-800 text-white rounded-md resize-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm placeholder-gray-400"
                  placeholder="Digite sua mensagem..."
                  :disabled="!podeEnviarMensagem"
                  @keydown.enter.exact.prevent="enviarMensagem"
                  @keydown.enter.shift.exact="novaMensagem += '\n'"
                ></textarea>
              </div>
              
              <div class="flex flex-col space-y-2">
                <!-- Botão de arquivo -->
                <input
                  ref="fileInput"
                  type="file"
                  @change="selecionarArquivo"
                  accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.gif,.txt"
                  class="hidden"
                />
                <button
                  type="button"
                  @click="$refs.fileInput.click()"
                  class="p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500 rounded-md"
                >
                  <PaperClipIcon class="h-5 w-5" />
                </button>
                
                <!-- Botão de enviar -->
                <button
                  type="submit"
                  :disabled="!podeEnviarMensagem || enviandoMensagem"
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <PaperAirplaneIcon class="h-5 w-5" />
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Templates -->
    <div v-if="mostrarTemplates" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900">Templates de Mensagens</h3>
          <button @click="mostrarTemplates = false" class="text-gray-400 hover:text-gray-600">
            <XIcon class="h-5 w-5" />
          </button>
        </div>
        
        <div class="space-y-2">
          <button
            v-for="template in templates"
            :key="template.id"
            @click="usarTemplate(template)"
            class="w-full text-left p-3 hover:bg-gray-50 rounded border"
          >
            <p class="font-medium text-sm text-gray-900">{{ template.titulo }}</p>
            <p class="text-xs text-gray-500 mt-1">{{ template.conteudo.substring(0, 100) }}...</p>
          </button>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useNotifications } from '@/composables/useNotifications'
import AppLayout from '@/components/AppLayout.vue'
import {
  SearchIcon,
  ChatIcon,
  DotsVerticalIcon,
  PaperAirplaneIcon,
  PaperClipIcon,
  XIcon,
  UserAddIcon,
  CheckIcon,
  TemplateIcon
} from '@heroicons/vue/outline'
import { format, formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

// Interfaces
interface Conversa {
  id: string
  cliente_cnpj: string
  cliente_nome: string
  titulo: string
  status: string
  prioridade: string
  atendente_nome: string | null
  ultima_mensagem_em: string
  mensagens_nao_lidas: number
  ultima_mensagem: string
  total_mensagens: number
  created_at: string
}

interface Mensagem {
  id: string
  remetente_tipo: string
  remetente_nome: string
  conteudo: string
  tipo_conteudo: string
  arquivo_nome: string | null
  arquivo_url: string | null
  created_at: string
}

interface Template {
  id: string
  titulo: string
  conteudo: string
  categoria: string
}

// Store e composables
const authStore = useAuthStore()
const { requestPermission, notifyNewMessage, notifyNewConversation, checkSupport } = useNotifications()

// Estado reativo
const searchQuery = ref('')
const filtroStatus = ref('')
const conversas = ref<Conversa[]>([])
const conversaSelecionada = ref<Conversa | null>(null)
const mensagens = ref<Mensagem[]>([])
const novaMensagem = ref('')
const templates = ref<Template[]>([])
const funcionarioAtivo = ref(false)

// Estado de loading
const loading = ref(false)
const carregandoMensagens = ref(false)
const enviandoMensagem = ref(false)
const assumindoAtendimento = ref(false)
const finalizandoConversa = ref(false)

// UI state
const mostrarMenu = ref(false)
const mostrarTemplates = ref(false)
const arquivoAnexado = ref<File | null>(null)

// Refs
const mensagensContainer = ref<HTMLElement | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const menuRef = ref<HTMLElement | null>(null)

// Computed
const conversasFiltradas = computed(() => {
  let resultado = conversas.value

  if (searchQuery.value) {
    resultado = resultado.filter(conv =>
      conv.cliente_nome.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      conv.titulo.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  }

  if (filtroStatus.value) {
    resultado = resultado.filter(conv => conv.status === filtroStatus.value)
  }

  return resultado.sort((a, b) => {
    // Priorizar conversas não lidas
    if (a.mensagens_nao_lidas > 0 && b.mensagens_nao_lidas === 0) return -1
    if (a.mensagens_nao_lidas === 0 && b.mensagens_nao_lidas > 0) return 1
    
    // Depois por data da última mensagem
    return new Date(b.ultima_mensagem_em).getTime() - new Date(a.ultima_mensagem_em).getTime()
  })
})

const podeEnviarMensagem = computed(() => {
  return conversaSelecionada.value && 
         (novaMensagem.value.trim() || arquivoAnexado.value) && 
         !enviandoMensagem.value &&
         conversaSelecionada.value.status !== 'finalizado'
})

// Métodos auxiliares
const formatarTempo = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { 
    addSuffix: true, 
    locale: ptBR 
  })
}

const formatarHoraMensagem = (dateString: string) => {
  return format(new Date(dateString), 'HH:mm', { locale: ptBR })
}

const getStatusColor = (status: string) => {
  const colors = {
    aberto: 'bg-green-400',
    em_atendimento: 'bg-blue-400',
    aguardando_cliente: 'bg-yellow-400',
    finalizado: 'bg-gray-400'
  }
  return colors[status] || 'bg-gray-400'
}

const getStatusBadgeColor = (status: string) => {
  const colors = {
    aberto: 'bg-green-100 text-green-800',
    em_atendimento: 'bg-blue-100 text-blue-800',
    aguardando_cliente: 'bg-yellow-100 text-yellow-800',
    finalizado: 'bg-gray-100 text-gray-800'
  }
  return colors[status] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status: string) => {
  const texts = {
    aberto: 'Aberto',
    em_atendimento: 'Em atendimento',
    aguardando_cliente: 'Aguardando',
    finalizado: 'Finalizado'
  }
  return texts[status] || status
}

const getPrioridadeBadgeColor = (prioridade: string) => {
  const colors = {
    baixa: 'bg-gray-100 text-gray-800',
    normal: 'bg-blue-100 text-blue-800',
    alta: 'bg-orange-100 text-orange-800',
    urgente: 'bg-red-100 text-red-800'
  }
  return colors[prioridade] || 'bg-gray-100 text-gray-800'
}

const getFileUrl = (url: string) => {
  return `${import.meta.env.VITE_API_URL}${url}`
}

// Métodos principais
const carregarConversas = async () => {
  loading.value = true
  try {
    console.log('DEBUG: Carregando conversas...')
    console.log('DEBUG: API URL:', import.meta.env.VITE_API_URL)
    console.log('DEBUG: Organizacao ID:', authStore.user?.organizacao_id)
    console.log('DEBUG: User:', authStore.user)
    
    // Mapear organizacao_id para filial_id 
    const filialId = authStore.user?.organizacao_id === 'matriz-master' ? 'matriz-id' : authStore.user?.organizacao_id
    console.log('DEBUG: Filial ID mapeado:', filialId)
    
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/conversations/attendance/${filialId}`, {
      headers: {
        'Content-Type': 'application/json'
        // 'Authorization': `Bearer ${authStore.token}` // Removido temporariamente para teste
      }
    })
    
    console.log('DEBUG: Response status:', response.status)
    console.log('DEBUG: Response ok:', response.ok)
    
    if (response.ok) {
      const data = await response.json()
      console.log('DEBUG: Conversas carregadas:', data)
      conversas.value = data.data || []
    } else {
      const errorData = await response.text()
      console.error('DEBUG: Erro na resposta:', errorData)
    }
  } catch (error) {
    console.error('Erro ao carregar conversas:', error)
  } finally {
    loading.value = false
  }
}

const selecionarConversa = async (conversa: Conversa) => {
  conversaSelecionada.value = conversa
  await carregarMensagens(conversa.id)
  
  // Marcar mensagens como lidas
  if (conversa.mensagens_nao_lidas > 0) {
    await marcarComoLida(conversa.id)
    conversa.mensagens_nao_lidas = 0
  }
}

const carregarMensagens = async (conversaId: string) => {
  carregandoMensagens.value = true
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/messages/${conversaId}`)
    
    if (response.ok) {
      const data = await response.json()
      mensagens.value = data.data || []
      await scrollToBottom()
    }
  } catch (error) {
    console.error('Erro ao carregar mensagens:', error)
  } finally {
    carregandoMensagens.value = false
  }
}

const enviarMensagem = async () => {
  if (!podeEnviarMensagem.value || !conversaSelecionada.value) return
  
  enviandoMensagem.value = true
  
  try {
    const formData = new FormData()
    formData.append('conversa_id', conversaSelecionada.value.id)
    formData.append('funcionario_id', authStore.user?.id || '')
    formData.append('funcionario_nome', authStore.user?.nome || '')
    formData.append('conteudo', novaMensagem.value.trim())
    
    if (arquivoAnexado.value) {
      formData.append('arquivo', arquivoAnexado.value)
      formData.append('tipo_conteudo', 'arquivo')
    } else {
      formData.append('tipo_conteudo', 'texto')
    }
    
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/messages/send-staff`, {
      method: 'POST',
      body: formData,
      headers: {
        'Authorization': `Bearer ${authStore.token}`
      }
    })
    
    if (response.ok) {
      novaMensagem.value = ''
      arquivoAnexado.value = null
      await carregarMensagens(conversaSelecionada.value.id)
      await carregarConversas() // Atualizar lista
    }
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error)
  } finally {
    enviandoMensagem.value = false
  }
}

const assumirAtendimento = async () => {
  if (!conversaSelecionada.value) return
  
  assumindoAtendimento.value = true
  
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/conversations/${conversaSelecionada.value.id}/assume`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authStore.token}`
      },
      body: JSON.stringify({
        funcionario_id: authStore.user?.id,
        funcionario_nome: authStore.user?.nome
      })
    })
    
    if (response.ok) {
      conversaSelecionada.value.atendente_nome = authStore.user?.nome || ''
      conversaSelecionada.value.status = 'em_atendimento'
      await carregarConversas()
    }
  } catch (error) {
    console.error('Erro ao assumir atendimento:', error)
  } finally {
    assumindoAtendimento.value = false
  }
}

const finalizarConversa = async () => {
  if (!conversaSelecionada.value) return
  
  finalizandoConversa.value = true
  
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/conversations/${conversaSelecionada.value.id}/finalize`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authStore.token}`
      },
      body: JSON.stringify({
        funcionario_id: authStore.user?.id
      })
    })
    
    if (response.ok) {
      conversaSelecionada.value.status = 'finalizado'
      await carregarConversas()
    }
  } catch (error) {
    console.error('Erro ao finalizar conversa:', error)
  } finally {
    finalizandoConversa.value = false
  }
}

const marcarComoLida = async (conversaId: string) => {
  try {
    await fetch(`${import.meta.env.VITE_API_URL}/api/chat/messages/read-staff/${conversaId}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${authStore.token}`
      }
    })
  } catch (error) {
    console.error('Erro ao marcar como lida:', error)
  }
}

const toggleAtendimentoStatus = async () => {
  try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/funcionarios/${authStore.user?.id}/toggle-status`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authStore.token}`
      },
      body: JSON.stringify({
        atendimento_ativo: !funcionarioAtivo.value
      })
    })
    
    if (response.ok) {
      funcionarioAtivo.value = !funcionarioAtivo.value
    }
  } catch (error) {
    console.error('Erro ao alterar status:', error)
  }
}

const carregarTemplates = async () => {
  try {
    const filialId = authStore.user?.organizacao_id === 'matriz-master' ? 'matriz-id' : authStore.user?.organizacao_id
    const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/templates/${filialId}`)
    
    if (response.ok) {
      const data = await response.json()
      templates.value = data.data || []
    }
  } catch (error) {
    console.error('Erro ao carregar templates:', error)
  }
}

const usarTemplate = (template: Template) => {
  novaMensagem.value = template.conteudo
  mostrarTemplates.value = false
}

const selecionarArquivo = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    arquivoAnexado.value = target.files[0]
  }
}

const removerArquivo = () => {
  arquivoAnexado.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const scrollToBottom = async () => {
  await nextTick()
  if (mensagensContainer.value) {
    mensagensContainer.value.scrollTop = mensagensContainer.value.scrollHeight
  }
}

// Auto-refresh das conversas
let intervalId: number | null = null
let conversasAnteriores: Conversa[] = []

const iniciarAutoRefresh = () => {
  intervalId = setInterval(async () => {
    const conversasAntigas = [...conversas.value]
    await carregarConversas()
    
    // Verificar novas conversas
    const novasConversas = conversas.value.filter(conv => 
      !conversasAntigas.find(antiga => antiga.id === conv.id)
    )
    
    // Notificar novas conversas
    for (const novaConversa of novasConversas) {
      notifyNewConversation(novaConversa.cliente_nome, novaConversa.titulo)
    }
    
    // Verificar novas mensagens
    for (const conversa of conversas.value) {
      const conversaAntiga = conversasAntigas.find(antiga => antiga.id === conversa.id)
      if (conversaAntiga && conversa.mensagens_nao_lidas > conversaAntiga.mensagens_nao_lidas) {
        // Nova mensagem não lida
        if (conversaSelecionada.value?.id !== conversa.id) {
          notifyNewMessage(conversa.cliente_nome, conversa.ultima_mensagem || 'Nova mensagem')
        }
      }
    }
    
    // Atualizar mensagens da conversa ativa
    if (conversaSelecionada.value) {
      await carregarMensagens(conversaSelecionada.value.id)
    }
  }, 5000) // 5 segundos para melhor responsividade
}

const pararAutoRefresh = () => {
  if (intervalId) {
    clearInterval(intervalId)
    intervalId = null
  }
}

// Click outside para fechar menu
const handleClickOutside = (event: Event) => {
  if (menuRef.value && !menuRef.value.contains(event.target as Node)) {
    mostrarMenu.value = false
  }
}

// Lifecycle
onMounted(async () => {
  console.log('DEBUG: ChatView montado')
  console.log('DEBUG: AuthStore completo:', authStore)
  console.log('DEBUG: User:', authStore.user)
  console.log('DEBUG: Token:', authStore.token)
  
  // Verificar suporte e solicitar permissão para notificações
  checkSupport()
  await requestPermission()
  
  await carregarConversas()
  await carregarTemplates()
  iniciarAutoRefresh()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  pararAutoRefresh()
  document.removeEventListener('click', handleClickOutside)
})

// Watch para scroll automático
watch(mensagens, () => {
  scrollToBottom()
}, { deep: true })
</script>