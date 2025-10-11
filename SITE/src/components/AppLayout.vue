<template>
  <div class="flex h-screen bg-gray-950">
    <!-- Sidebar -->
    <div class="hidden md:flex md:w-72 md:flex-col">
      <div class="flex flex-col flex-grow pt-6 pb-4 overflow-y-auto bg-gray-900/50 backdrop-blur-xl border-r border-gray-800/50">
        <!-- Logo section -->
        <div class="flex items-center flex-shrink-0 px-6 mb-8">
          <div class="h-10 w-20 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center shadow-lg">
            <span class="text-white font-bold text-sm tracking-wider">DNOTAS</span>
          </div>
        </div>
        
        <!-- Navigation -->
        <div class="flex-grow flex flex-col">
          <nav class="flex-1 px-4 space-y-2">
            <router-link
              v-for="item in navigation"
              :key="item.name"
              :to="item.href"
              class="sidebar-item group"
              :class="{ 'active': $route.name === item.name }"
            >
              <component
                :is="item.icon"
                class="mr-3 flex-shrink-0 h-5 w-5"
                aria-hidden="true"
              />
              <span class="font-medium">{{ item.label }}</span>
              <span
                v-if="item.badge"
                class="ml-auto inline-flex items-center px-2 py-1 text-xs font-bold rounded-full"
                :class="item.badgeClass || 'bg-red-500/20 text-red-400 border border-red-500/30'"
              >
                {{ item.badge }}
              </span>
            </router-link>
          </nav>
        </div>
        
        <!-- User section -->
        <div class="flex-shrink-0 border-t border-gray-800/50 p-4">
          <div class="flex items-center p-3 bg-gray-800/30 rounded-xl border border-gray-700/50">
            <div class="flex-shrink-0">
              <div class="h-10 w-10 rounded-xl bg-gradient-to-r from-blue-500 to-blue-600 flex items-center justify-center shadow-lg">
                <span class="text-white text-sm font-bold">{{ userInitials }}</span>
              </div>
            </div>
            <div class="ml-3 flex-1">
              <p class="text-sm font-medium text-white">{{ authStore.user?.nome || 'Usuário' }}</p>
              <p class="text-xs text-gray-400 capitalize">{{ authStore.user?.organizacao_nome || 'DNOTAS' }}</p>
            </div>
            <button
              @click="handleLogout"
              class="ml-2 p-2 text-gray-400 hover:text-red-400 transition-colors rounded-lg hover:bg-gray-800/50"
              title="Sair"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Main content -->
    <div class="flex flex-col w-0 flex-1 overflow-hidden">
      <!-- Top bar -->
      <div class="relative z-10 flex-shrink-0 flex h-16 bg-gray-900/80 backdrop-blur-xl border-b border-gray-800/50">
        <button
          type="button"
          class="px-4 border-r border-gray-800/50 text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500 md:hidden transition-colors"
          @click="sidebarOpen = true"
        >
          <span class="sr-only">Open sidebar</span>
          <MenuIcon class="h-6 w-6" aria-hidden="true" />
        </button>
        
        <div class="flex-1 px-6 flex justify-between items-center">
          <!-- Search -->
          <div class="flex-1 max-w-lg">
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <SearchIcon class="h-5 w-5 text-gray-500" aria-hidden="true" />
              </div>
              <input
                v-model="searchQuery"
                class="block w-full pl-10 pr-3 py-2 bg-gray-800/50 border border-gray-700/50 rounded-xl text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                placeholder="Buscar clientes, mensagens..."
                type="search"
              />
            </div>
          </div>
          
          <!-- Right side actions -->
          <div class="ml-6 flex items-center space-x-4">
            <!-- Notifications -->
            <button
              type="button"
              class="relative p-2 text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-xl transition-colors hover:bg-gray-800/50"
            >
              <span class="sr-only">View notifications</span>
              <BellIcon class="h-6 w-6" aria-hidden="true" />
              <span
                v-if="unreadNotifications > 0"
                class="absolute -top-1 -right-1 h-5 w-5 bg-red-500 rounded-full flex items-center justify-center text-white text-xs font-bold border-2 border-gray-900"
              >
                {{ unreadNotifications }}
              </span>
            </button>

            <!-- Status indicator -->
            <div class="flex items-center space-x-2 px-3 py-2 bg-green-500/10 border border-green-500/20 rounded-xl">
              <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
              <span class="text-green-400 text-sm font-medium">Online</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Page content -->
      <main class="flex-1 relative overflow-y-auto focus:outline-none bg-gray-950">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import {
  MenuIcon,
  SearchIcon,
  BellIcon,
  HomeIcon,
  ChatIcon,
  UsersIcon,
  DocumentReportIcon,
  CurrencyDollarIcon,
  OfficeBuildingIcon,
  UserGroupIcon,
  CogIcon
} from '@heroicons/vue/outline'

const router = useRouter()
const authStore = useAuthStore()

const sidebarOpen = ref(false)
const profileMenuOpen = ref(false)
const searchQuery = ref('')
const unreadNotifications = ref(5)

const navigation = computed(() => {
  const user = authStore.user
  const isMatrizAdmin = user?.organizacao_tipo === 'matriz' && user?.role === 'admin'

  if (isMatrizAdmin) {
    // Menu para administrador da matriz
    return [
      { name: 'admin-dashboard', label: 'Dashboard Admin', href: '/admin/dashboard', icon: HomeIcon },
      { name: 'admin-filiais', label: 'Gestão de Filiais', href: '/admin/filiais', icon: OfficeBuildingIcon },
      { name: 'admin-funcionarios', label: 'Funcionários', href: '/admin/funcionarios', icon: UserGroupIcon },
      { name: 'clients', label: 'Clientes', href: '/clients', icon: UsersIcon },
      { name: 'reports', label: 'Relatórios', href: '/reports', icon: DocumentReportIcon },
      { name: 'financial', label: 'Financeiro', href: '/financial', icon: CurrencyDollarIcon },
      { 
        name: 'chat', 
        label: 'Atendimento', 
        href: '/chat', 
        icon: ChatIcon,
        badge: 3,
        badgeClass: 'bg-red-100 text-red-800'
      }
    ]
  } else {
    // Menu padrão para funcionários das filiais
    return [
      { name: 'dashboard', label: 'Dashboard', href: '/dashboard', icon: HomeIcon },
      { 
        name: 'chat', 
        label: 'Atendimento', 
        href: '/chat', 
        icon: ChatIcon,
        badge: 3,
        badgeClass: 'bg-red-100 text-red-800'
      },
      { name: 'clients', label: 'Clientes', href: '/clients', icon: UsersIcon },
      { name: 'reports', label: 'Relatórios', href: '/reports', icon: DocumentReportIcon },
      { name: 'financial', label: 'Financeiro', href: '/financial', icon: CurrencyDollarIcon }
    ]
  }
})

const userInitials = computed(() => {
  const name = authStore.user?.nome || 'Admin'
  return name.split(' ').map(n => n[0]).join('').toUpperCase()
})

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>