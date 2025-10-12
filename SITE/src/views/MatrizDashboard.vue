<template>
  <div class="min-h-screen bg-gray-950">
    <!-- Header -->
    <header class="bg-gray-900/80 backdrop-blur-sm border-b border-gray-800">
      <div class="container mx-auto px-4 py-4 flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
            <span class="text-white font-bold text-lg">DN</span>
          </div>
          <div>
            <h1 class="text-xl font-bold text-white">DNOTAS - Matriz</h1>
            <p class="text-gray-400 text-sm">Sistema Administrativo</p>
          </div>
        </div>
        <div class="flex items-center space-x-4">
          <span class="text-green-400 text-sm">● Online</span>
        </div>
      </div>
    </header>

    <div class="flex">
      <!-- Sidebar -->
      <aside class="w-64 h-screen bg-gray-900/50 border-r border-gray-800">
        <nav class="p-4 space-y-2">
          <a href="#" @click="activeTab = 'dashboard'" 
             :class="[activeTab === 'dashboard' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            <span>Dashboard</span>
          </a>

          <a href="#" @click="activeTab = 'clientes'" 
             :class="[activeTab === 'clientes' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
            </svg>
            <span>Clientes</span>
          </a>

          <a href="#" @click="activeTab = 'chat'" 
             :class="[activeTab === 'chat' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span>Chat</span>
          </a>

          <a href="#" @click="activeTab = 'financeiro'" 
             :class="[activeTab === 'financeiro' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
            </svg>
            <span>Financeiro</span>
          </a>

          <a href="#" @click="activeTab = 'relatorios'" 
             :class="[activeTab === 'relatorios' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span>Relatórios</span>
          </a>

          <a href="#" @click="activeTab = 'funcionarios'" 
             :class="[activeTab === 'funcionarios' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            <span>Funcionários</span>
          </a>

          <a href="#" @click="activeTab = 'filiais'" 
             :class="[activeTab === 'filiais' ? 'bg-blue-600' : 'bg-gray-800/50 hover:bg-gray-700']" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
            <span>Filiais</span>
          </a>
        </nav>
      </aside>

      <!-- Main Content -->
      <main class="flex-1 p-6">
        <!-- Dashboard Tab -->
        <div v-if="activeTab === 'dashboard'">
          <h2 class="text-2xl font-bold text-white mb-6">Dashboard - Matriz</h2>
          
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-gray-400 text-sm">Total Clientes</p>
                  <p class="text-2xl font-bold text-white">{{ stats.totalClientes }}</p>
                </div>
                <div class="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center">
                  <svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                  </svg>
                </div>
              </div>
            </div>

            <div class="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-gray-400 text-sm">NF-e do Mês</p>
                  <p class="text-2xl font-bold text-white">{{ stats.nfesMes }}</p>
                </div>
                <div class="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center">
                  <svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
              </div>
            </div>

            <div class="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-gray-400 text-sm">Receita Mensal</p>
                  <p class="text-2xl font-bold text-white">R$ {{ stats.receitaMensal.toLocaleString() }}</p>
                </div>
                <div class="w-12 h-12 bg-yellow-500/20 rounded-lg flex items-center justify-center">
                  <svg class="w-6 h-6 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                  </svg>
                </div>
              </div>
            </div>

            <div class="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-gray-400 text-sm">Mensagens Hoje</p>
                  <p class="text-2xl font-bold text-white">{{ stats.mensagensHoje }}</p>
                </div>
                <div class="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center">
                  <svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Clientes Tab -->
        <div v-if="activeTab === 'clientes'">
          <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-white">Gestão de Clientes</h2>
            <button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
              + Novo Cliente
            </button>
          </div>
          
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema de cadastro de clientes será implementado aqui.</p>
          </div>
        </div>

        <!-- Chat Tab -->
        <div v-if="activeTab === 'chat'">
          <h2 class="text-2xl font-bold text-white mb-6">Centro de Mensagens</h2>
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema de chat será implementado aqui.</p>
          </div>
        </div>

        <!-- Financeiro Tab -->
        <div v-if="activeTab === 'financeiro'">
          <h2 class="text-2xl font-bold text-white mb-6">Gestão Financeira</h2>
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema financeiro será implementado aqui.</p>
          </div>
        </div>

        <!-- Relatórios Tab -->
        <div v-if="activeTab === 'relatorios'">
          <h2 class="text-2xl font-bold text-white mb-6">Relatórios</h2>
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema de relatórios será implementado aqui.</p>
          </div>
        </div>

        <!-- Funcionários Tab -->
        <div v-if="activeTab === 'funcionarios'">
          <h2 class="text-2xl font-bold text-white mb-6">Gestão de Funcionários</h2>
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema de funcionários será implementado aqui.</p>
          </div>
        </div>

        <!-- Filiais Tab -->
        <div v-if="activeTab === 'filiais'">
          <h2 class="text-2xl font-bold text-white mb-6">Gestão de Filiais</h2>
          <div class="bg-gray-900/50 rounded-xl border border-gray-800 p-6">
            <p class="text-gray-400">Sistema de filiais será implementado aqui.</p>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const activeTab = ref('dashboard')

const stats = ref({
  totalClientes: 248,
  nfesMes: 1205,
  receitaMensal: 45230,
  mensagensHoje: 67
})
</script>