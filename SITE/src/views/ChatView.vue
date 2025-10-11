<template>
  <AppLayout>
    <div class="flex h-full">
      <!-- Chat sessions sidebar -->
      <div class="w-80 bg-white border-r border-gray-200 flex flex-col">
        <div class="px-4 py-6 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Atendimentos</h2>
          <div class="mt-3">
            <div class="relative">
              <input
                v-model="searchQuery"
                type="text"
                class="block w-full pl-3 pr-10 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                placeholder="Buscar cliente..."
              />
              <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                <SearchIcon class="h-5 w-5 text-gray-400" aria-hidden="true" />
              </div>
            </div>
          </div>
        </div>
        
        <div class="flex-1 overflow-y-auto">
          <div class="divide-y divide-gray-200">
            <div
              v-for="session in filteredSessions"
              :key="session.client_cnpj"
              class="px-4 py-4 hover:bg-gray-50 cursor-pointer transition-colors"
              :class="{ 'bg-primary-50': selectedSession?.client_cnpj === session.client_cnpj }"
              @click="selectSession(session)"
            >
              <div class="flex items-start space-x-3">
                <div class="flex-shrink-0 relative">
                  <div class="h-10 w-10 rounded-full bg-primary-500 flex items-center justify-center">
                    <span class="text-white text-sm font-medium">
                      {{ session.client_name.charAt(0) }}
                    </span>
                  </div>
                  <div
                    v-if="session.is_online"
                    class="absolute -bottom-1 -right-1 h-3 w-3 bg-green-400 border-2 border-white rounded-full"
                  ></div>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-gray-900 truncate">
                      {{ session.client_name }}
                    </p>
                    <div class="flex items-center space-x-1">
                      <span
                        v-if="session.unread_count > 0"
                        class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
                      >
                        {{ session.unread_count }}
                      </span>
                      <span class="text-xs text-gray-500">
                        {{ formatTime(session.last_message_time) }}
                      </span>
                    </div>
                  </div>
                  <p class="text-sm text-gray-500 truncate mt-1">
                    {{ session.last_message }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Chat area -->
      <div class="flex-1 flex flex-col">
        <div v-if="!selectedSession" class="flex-1 flex items-center justify-center bg-gray-50">
          <div class="text-center">
            <ChatIcon class="mx-auto h-12 w-12 text-gray-400" />
            <h3 class="mt-2 text-sm font-medium text-gray-900">Selecione um atendimento</h3>
            <p class="mt-1 text-sm text-gray-500">
              Escolha uma conversa na lista ao lado para começar o atendimento.
            </p>
          </div>
        </div>

        <div v-else class="flex-1 flex flex-col">
          <!-- Chat header -->
          <div class="px-6 py-4 border-b border-gray-200 bg-white">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="flex-shrink-0 relative">
                  <div class="h-10 w-10 rounded-full bg-primary-500 flex items-center justify-center">
                    <span class="text-white text-sm font-medium">
                      {{ selectedSession.client_name.charAt(0) }}
                    </span>
                  </div>
                  <div
                    v-if="selectedSession.is_online"
                    class="absolute -bottom-1 -right-1 h-3 w-3 bg-green-400 border-2 border-white rounded-full"
                  ></div>
                </div>
                <div>
                  <h3 class="text-lg font-medium text-gray-900">
                    {{ selectedSession.client_name }}
                  </h3>
                  <p class="text-sm text-gray-500">
                    {{ selectedSession.is_online ? 'Online' : 'Offline' }}
                  </p>
                </div>
              </div>
              <div class="flex items-center space-x-2">
                <button
                  type="button"
                  class="p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500 rounded-md"
                >
                  <PhoneIcon class="h-5 w-5" />
                </button>
                <button
                  type="button"
                  class="p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500 rounded-md"
                >
                  <DotsVerticalIcon class="h-5 w-5" />
                </button>
              </div>
            </div>
          </div>

          <!-- Messages area -->
          <div
            ref="messagesContainer"
            class="flex-1 overflow-y-auto p-6 bg-gray-50 space-y-4"
          >
            <div
              v-for="message in currentMessages"
              :key="message.id"
              class="flex"
              :class="message.is_from_client ? 'justify-start' : 'justify-end'"
            >
              <div
                class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg"
                :class="message.is_from_client 
                  ? 'bg-white text-gray-900' 
                  : 'bg-primary-600 text-white'"
              >
                <p class="text-sm">{{ message.content }}</p>
                <p
                  class="text-xs mt-1"
                  :class="message.is_from_client ? 'text-gray-500' : 'text-primary-100'"
                >
                  {{ formatMessageTime(message.timestamp) }}
                  <span v-if="!message.read && !message.is_from_client" class="ml-1">✓</span>
                </p>
              </div>
            </div>
          </div>

          <!-- Message input -->
          <div class="px-6 py-4 bg-white border-t border-gray-200">
            <form @submit.prevent="sendMessage" class="flex space-x-4">
              <div class="flex-1">
                <textarea
                  v-model="newMessage"
                  rows="2"
                  class="block w-full border border-gray-300 rounded-md resize-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                  placeholder="Digite sua mensagem..."
                  @keydown.enter.exact.prevent="sendMessage"
                  @keydown.enter.shift.exact="newMessage += '\n'"
                ></textarea>
              </div>
              <button
                type="submit"
                :disabled="!newMessage.trim() || isSending"
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <PaperAirplaneIcon class="h-5 w-5" />
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { apiService } from '@/services/api'
import AppLayout from '@/components/AppLayout.vue'
import type { ChatSession, Message } from '@/types'
import {
  SearchIcon,
  ChatIcon,
  PhoneIcon,
  DotsVerticalIcon,
  PaperAirplaneIcon
} from '@heroicons/vue/outline'
import { format, formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const authStore = useAuthStore()

const searchQuery = ref('')
const selectedSession = ref<ChatSession | null>(null)
const chatSessions = ref<ChatSession[]>([])
const currentMessages = ref<Message[]>([])
const newMessage = ref('')
const isSending = ref(false)
const messagesContainer = ref<HTMLElement | null>(null)

const filteredSessions = computed(() => {
  if (!searchQuery.value) return chatSessions.value
  
  return chatSessions.value.filter(session =>
    session.client_name.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

const formatTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { 
    addSuffix: true, 
    locale: ptBR 
  })
}

const formatMessageTime = (dateString: string) => {
  return format(new Date(dateString), 'HH:mm', { locale: ptBR })
}

const selectSession = async (session: ChatSession) => {
  selectedSession.value = session
  await loadMessages(session.client_cnpj)
  
  // Marcar como lido
  if (session.unread_count > 0) {
    await apiService.markAsRead(session.client_cnpj)
    session.unread_count = 0
  }
}

const loadMessages = async (clientCnpj: string) => {
  try {
    currentMessages.value = await apiService.getMessages(clientCnpj)
    await scrollToBottom()
  } catch (error) {
    console.error('Erro ao carregar mensagens:', error)
  }
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || !selectedSession.value || isSending.value) return
  
  isSending.value = true
  const messageContent = newMessage.value.trim()
  newMessage.value = ''
  
  // Adicionar mensagem localmente
  const tempMessage: Message = {
    id: Date.now().toString(),
    content: messageContent,
    sender_id: 'admin',
    sender_name: authStore.user?.name || 'Suporte',
    timestamp: new Date().toISOString(),
    is_from_client: false,
    client_cnpj: selectedSession.value.client_cnpj,
    read: false
  }
  
  currentMessages.value.push(tempMessage)
  await scrollToBottom()
  
  try {
    const success = await apiService.sendMessage(selectedSession.value.client_cnpj, messageContent)
    
    if (success) {
      // Atualizar a sessão
      selectedSession.value.last_message = messageContent
      selectedSession.value.last_message_time = new Date().toISOString()
      
      // Mover para o topo da lista
      const sessionIndex = chatSessions.value.findIndex(s => s.client_cnpj === selectedSession.value?.client_cnpj)
      if (sessionIndex > 0) {
        const session = chatSessions.value.splice(sessionIndex, 1)[0]
        chatSessions.value.unshift(session)
      }
    }
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error)
  } finally {
    isSending.value = false
  }
}

const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

const loadChatSessions = async () => {
  try {
    chatSessions.value = await apiService.getChatSessions(authStore.user?.filial_id || 'matriz')
  } catch (error) {
    console.error('Erro ao carregar sessões de chat:', error)
  }
}

// Watch para auto-scroll quando novas mensagens chegam
watch(currentMessages, () => {
  scrollToBottom()
}, { deep: true })

onMounted(() => {
  loadChatSessions()
})
</script>