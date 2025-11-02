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
          <div class="flex items-center space-x-2">
            <span :class="statusConexao.cor" class="text-sm">● {{ statusConexao.texto }}</span>
            <div v-if="statusConexao.loading" class="w-4 h-4 border-2 border-blue-400 border-t-transparent rounded-full animate-spin"></div>
          </div>
        </div>
      </div>
    </header>

    <!-- Notificação de Relatórios Pendentes -->
    <div v-if="solicitacoesPendentes.length > 0 && activeTab !== 'relatorios' && !ocultarNotificacao" 
         class="bg-red-500/90 border-l-4 border-red-700 text-white px-4 py-3 relative backdrop-blur-sm">
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
          <strong class="font-bold">Atenção!</strong>
          <span class="ml-2">
            Você tem {{ solicitacoesPendentes.length }} {{ solicitacoesPendentes.length === 1 ? 'relatório pendente' : 'relatórios pendentes' }} para processar.
          </span>
        </div>
        <div class="flex items-center space-x-2">
          <button 
            @click="activeTab = 'relatorios'" 
            class="bg-white/20 hover:bg-white/30 px-3 py-1 rounded text-sm font-medium transition-colors"
          >
            Ver Relatórios
          </button>
          <button 
            @click="ocultarNotificacao = true" 
            class="text-white hover:text-gray-200 transition-colors"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>

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

          <router-link to="/chat" 
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors bg-gray-800/50 hover:bg-gray-700">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span>Chat</span>
          </router-link>

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
             class="flex items-center space-x-3 px-4 py-3 rounded-lg text-white transition-colors relative">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span>Relatórios</span>
            <!-- Badge de notificação para relatórios pendentes -->
            <span 
              v-if="solicitacoesPendentes.length > 0" 
              class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full h-6 w-6 flex items-center justify-center border-2 border-gray-900 animate-pulse"
            >
              {{ solicitacoesPendentes.length }}
            </span>
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
            <button @click="showNovoCliente = true" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
              + Novo Cliente
            </button>
          </div>
          
          <!-- Lista de Clientes -->
          <div class="bg-gray-900/50 rounded-xl border border-gray-800">
            <div v-if="isLoading" class="p-6 text-center">
              <p class="text-gray-400">Carregando clientes...</p>
            </div>
            
            <div v-else-if="clientes.length === 0" class="p-6 text-center">
              <p class="text-gray-400">Nenhum cliente cadastrado ainda.</p>
            </div>
            
            <div v-else class="overflow-x-auto">
              <table class="w-full">
                <thead class="border-b border-gray-800">
                  <tr>
                    <th class="text-left p-4 text-gray-400 font-medium">Nome</th>
                    <th class="text-left p-4 text-gray-400 font-medium">CNPJ</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Cadastrado</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="cliente in clientes" :key="cliente.id" class="border-b border-gray-800 hover:bg-gray-800/30">
                    <td class="p-4 text-white">{{ cliente.nome_empresa }}</td>
                    <td class="p-4 text-gray-300">{{ formatarCNPJExibicao(cliente.cnpj) }}</td>
                    <td class="p-4 text-gray-300">{{ formatDate(cliente.created_at) }}</td>
                    <td class="p-4">
                      <button @click="editarCliente(cliente)" class="text-blue-400 hover:text-blue-300 mr-3">
                        Editar
                      </button>
                      <button @click="removerCliente(cliente.id)" class="text-red-400 hover:text-red-300">
                        Remover
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Modal Cliente (Criar/Editar) -->
        <div v-if="showNovoCliente || clienteEditando" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div class="bg-gray-900 rounded-xl p-6 w-full max-w-2xl border border-gray-800 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-xl font-bold text-white">
                {{ clienteEditando ? 'Editar Cliente' : 'Novo Cliente' }}
              </h3>
              <button @click="fecharModalCliente" class="text-gray-400 hover:text-white">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </button>
            </div>
            
            <form @submit.prevent="salvarCliente">
              <!-- Dados Básicos -->
              <div class="space-y-4 mb-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="md:col-span-2">
                    <label class="block text-gray-400 text-sm mb-2">Nome da Empresa *</label>
                    <input v-model="novoCliente.nome" type="text" required 
                           class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                  </div>
                  
                  <div>
                    <label class="block text-gray-400 text-sm mb-2">CNPJ *</label>
                    <input v-model="novoCliente.cnpj" 
                           type="text" 
                           required
                           placeholder="00.000.000/0000-00"
                           maxlength="18"
                           @input="formatarCNPJ"
                           :disabled="!!clienteEditando"
                           class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white disabled:opacity-50">
                    <p v-if="clienteEditando" class="text-xs text-gray-500 mt-1">CNPJ não pode ser alterado</p>
                  </div>
                  
                  <div>
                    <label class="block text-gray-400 text-sm mb-2">Email</label>
                    <input v-model="novoCliente.email" type="email" 
                           class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                  </div>
                  
                  <div>
                    <label class="block text-gray-400 text-sm mb-2">Telefone</label>
                    <input v-model="novoCliente.telefone" type="text" 
                           placeholder="(11) 99999-9999"
                           class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                  </div>
                  
                  <div>
                    <label class="block text-gray-400 text-sm mb-2">Senha {{ clienteEditando ? '' : '*' }}</label>
                    <input v-model="novoCliente.senha" type="password" 
                           :required="!clienteEditando"
                           :placeholder="clienteEditando ? 'Deixe em branco para manter a atual' : 'Digite a senha'"
                           class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                  </div>
                </div>
              </div>

              <!-- Seção de Filiais -->
              <div class="border-t border-gray-700 pt-6">
                <div class="flex justify-between items-center mb-4">
                  <h4 class="text-lg font-medium text-white">Filiais</h4>
                  <button type="button" @click="adicionarFilial" 
                          class="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm">
                    + Adicionar Filial
                  </button>
                </div>

                <div v-if="novoCliente.filiais.length === 0" class="text-center py-8 bg-gray-800/50 rounded-lg">
                  <p class="text-gray-400">Nenhuma filial cadastrada</p>
                  <p class="text-gray-500 text-sm">Clique em "Adicionar Filial" para incluir filiais</p>
                </div>

                <div v-else class="space-y-4">
                  <div v-for="(filial, index) in novoCliente.filiais" :key="index" 
                       class="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <label class="block text-gray-400 text-sm mb-2">CNPJ da Filial *</label>
                        <input v-model="filial.cnpj" type="text" required
                               placeholder="00.000.000/0000-00"
                               maxlength="18"
                               @input="formatarCnpjFilial(index, $event)"
                               class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                      </div>
                      
                      <div>
                        <label class="block text-gray-400 text-sm mb-2">Nome da Filial *</label>
                        <input v-model="filial.nome" type="text" required
                               placeholder="Ex: Filial Shopping"
                               class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                      </div>
                      
                      <div class="flex items-end">
                        <button type="button" @click="removerFilialFormulario(index)"
                                class="w-full bg-red-600 hover:bg-red-700 text-white px-3 py-2 rounded-lg">
                          Remover
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-700">
                <button type="button" @click="fecharModalCliente" 
                        class="px-4 py-2 text-gray-400 hover:text-white transition-colors">
                  Cancelar
                </button>
                <button type="submit" :disabled="salvandoCliente"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50">
                  {{ salvandoCliente ? 'Salvando...' : (clienteEditando ? 'Atualizar' : 'Salvar') }}
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal Novo Funcionário -->
        <div v-if="showNovoFuncionario" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div class="bg-gray-900 rounded-xl p-6 w-full max-w-md border border-gray-800">
            <h3 class="text-xl font-bold text-white mb-4">Novo Funcionário</h3>
            
            <form @submit.prevent="salvarFuncionario">
              <div class="space-y-4">
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Nome Completo</label>
                  <input v-model="novoFuncionario.nome" type="text" required 
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Email</label>
                  <input v-model="novoFuncionario.email" type="email" required 
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Cargo</label>
                  <input v-model="novoFuncionario.cargo" type="text" required 
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Telefone</label>
                  <input v-model="novoFuncionario.telefone" type="text" 
                         placeholder="(11) 99999-9999"
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Filial</label>
                  <select v-model="novoFuncionario.filial_id" required 
                          class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                    <option value="">Selecione uma filial</option>
                    <option value="11111111-1111-1111-1111-111111111111">Matriz</option>
                    <option v-for="filial in filiais" :key="filial.id" :value="filial.id">
                      {{ filial.nome }}
                    </option>
                  </select>
                </div>
              </div>
              
              <div class="flex justify-end space-x-3 mt-6">
                <button type="button" @click="showNovoFuncionario = false" 
                        class="px-4 py-2 text-gray-400 hover:text-white transition-colors">
                  Cancelar
                </button>
                <button type="submit" :disabled="salvandoFuncionario"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50">
                  {{ salvandoFuncionario ? 'Salvando...' : 'Salvar' }}
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal Nova Filial -->
        <div v-if="showNovaFilial" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div class="bg-gray-900 rounded-xl p-6 w-full max-w-md border border-gray-800">
            <h3 class="text-xl font-bold text-white mb-4">Nova Filial</h3>
            
            <form @submit.prevent="salvarFilial">
              <div class="space-y-4">
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Nome da Filial</label>
                  <input v-model="novaFilial.nome" type="text" required 
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Código</label>
                  <input v-model="novaFilial.codigo" type="text" required
                         placeholder="FIL001"
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
              </div>
              
              <div class="flex justify-end space-x-3 mt-6">
                <button type="button" @click="showNovaFilial = false" 
                        class="px-4 py-2 text-gray-400 hover:text-white transition-colors">
                  Cancelar
                </button>
                <button type="submit" :disabled="salvandoFilial"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50">
                  {{ salvandoFilial ? 'Salvando...' : 'Salvar' }}
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal de Processamento de Relatório -->
        <div v-if="modalRelatorioAberto" class="fixed inset-0 z-50 overflow-y-auto">
          <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div class="fixed inset-0 transition-opacity">
              <div class="absolute inset-0 bg-gray-500 opacity-75" @click="fecharModalRelatorio"></div>
            </div>

            <div class="inline-block align-bottom bg-gray-900 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full border border-gray-800">
              <div class="bg-gray-900 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="sm:flex sm:items-start">
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                    <h3 class="text-lg leading-6 font-medium text-white mb-4">
                      Processar Relatório
                    </h3>
                    
                    <div v-if="solicitacaoSelecionada" class="space-y-4">
                      <div class="bg-gray-800 p-3 rounded">
                        <p class="text-white"><strong>Cliente:</strong> {{ solicitacaoSelecionada.cliente_cnpj }}</p>
                        <p class="text-white"><strong>Período:</strong> {{ formatPeriodo(solicitacaoSelecionada) }}</p>
                      </div>

                      <div v-for="(data, index) in datasParaProcessar" :key="index" class="border border-gray-700 rounded p-3">
                        <h4 class="font-medium text-white mb-2">{{ data.data_relatorio }}</h4>
                        <div class="grid grid-cols-3 gap-4">
                          <div>
                            <label class="block text-xs font-medium text-gray-400">Crédito</label>
                            <input 
                              v-model.number="data.vendas_credito" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-400">Débito</label>
                            <input 
                              v-model.number="data.vendas_debito" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-400">PIX</label>
                            <input 
                              v-model.number="data.vendas_pix" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-400">Vale</label>
                            <input 
                              v-model.number="data.vendas_vale" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-400">Dinheiro</label>
                            <input 
                              v-model.number="data.vendas_dinheiro" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-gray-400">Transferência</label>
                            <input 
                              v-model.number="data.vendas_transferencia" 
                              type="number" 
                              step="0.01" 
                              class="mt-1 block w-full bg-gray-800 border-gray-600 rounded-md shadow-sm text-white text-sm"
                            >
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="bg-gray-800 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <button 
                  @click="processarRelatorio"
                  :disabled="processandoRelatorio"
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 disabled:opacity-50 sm:ml-3 sm:w-auto sm:text-sm"
                >
                  <span v-if="processandoRelatorio">Processando...</span>
                  <span v-else>Salvar Relatório</span>
                </button>
                <button 
                  @click="fecharModalRelatorio"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-600 shadow-sm px-4 py-2 bg-gray-800 text-base font-medium text-gray-300 hover:bg-gray-700 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
                >
                  Cancelar
                </button>
              </div>
            </div>
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
          
          <!-- Solicitações Pendentes -->
          <div class="bg-gray-900/50 rounded-xl border border-gray-800">
            <div class="px-6 py-4 border-b border-gray-800">
              <div class="flex items-center justify-between">
                <h3 class="text-lg font-medium text-white">Solicitações Pendentes</h3>
                <div class="flex items-center">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                    {{ solicitacoesPendentes.length }} pendentes
                  </span>
                  <button 
                    @click="loadSolicitacoes"
                    class="ml-3 inline-flex items-center px-3 py-1 border border-gray-600 rounded-md text-sm font-medium text-gray-300 bg-gray-800 hover:bg-gray-700"
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
              <div v-if="loadingRelatorios" class="flex justify-center">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              </div>
              
              <div v-else-if="solicitacoesPendentes.length === 0" class="text-center py-8">
                <svg class="mx-auto h-12 w-12 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                <h4 class="mt-2 text-sm font-medium text-white">Nenhuma solicitação pendente</h4>
                <p class="mt-1 text-sm text-gray-400">Todas as solicitações estão processadas.</p>
              </div>
              
              <div v-else class="space-y-4">
                <div 
                  v-for="solicitacao in solicitacoesPendentes" 
                  :key="solicitacao.id"
                  class="border border-gray-700 rounded-lg p-4 hover:bg-gray-800/30"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <div class="flex items-center">
                        <h4 class="text-sm font-medium text-white">{{ solicitacao.cliente_cnpj }}</h4>
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
                      <div class="mt-1 text-sm text-gray-400">
                        <p><strong>Período:</strong> {{ formatPeriodo(solicitacao) }}</p>
                        <p><strong>Tipo:</strong> {{ solicitacao.tipo_periodo === 'dia_unico' ? 'Dia único' : 'Intervalo' }}</p>
                        <p><strong>Solicitado em:</strong> {{ formatDateRelatorio(solicitacao.data_solicitacao) }}</p>
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
        </div>

        <!-- Funcionários Tab -->
        <div v-if="activeTab === 'funcionarios'">
          <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-white">Gestão de Funcionários</h2>
            <button @click="showNovoFuncionario = true" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
              + Novo Funcionário
            </button>
          </div>
          
          <!-- Lista de Funcionários -->
          <div class="bg-gray-900/50 rounded-xl border border-gray-800">
            <div v-if="isLoadingFuncionarios" class="p-6 text-center">
              <p class="text-gray-400">Carregando funcionários...</p>
            </div>
            
            <div v-else-if="funcionarios.length === 0" class="p-6 text-center">
              <p class="text-gray-400">Nenhum funcionário cadastrado ainda.</p>
            </div>
            
            <div v-else class="overflow-x-auto">
              <table class="w-full">
                <thead class="border-b border-gray-800">
                  <tr>
                    <th class="text-left p-4 text-gray-400 font-medium">Nome</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Email</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Cargo</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Filial</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Status</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="funcionario in funcionarios" :key="funcionario.id" class="border-b border-gray-800 hover:bg-gray-800/30">
                    <td class="p-4 text-white">{{ funcionario.nome }}</td>
                    <td class="p-4 text-gray-300">{{ funcionario.email }}</td>
                    <td class="p-4 text-gray-300">{{ funcionario.cargo }}</td>
                    <td class="p-4 text-gray-300">{{ funcionario.organizacao_id }}</td>
                    <td class="p-4">
                      <span :class="funcionario.ativo ? 'text-green-400' : 'text-red-400'">
                        {{ funcionario.ativo ? 'Ativo' : 'Inativo' }}
                      </span>
                    </td>
                    <td class="p-4">
                      <button @click="editarFuncionario(funcionario)" class="text-blue-400 hover:text-blue-300 mr-3">
                        Editar
                      </button>
                      <button @click="removerFuncionario(funcionario.id)" class="text-red-400 hover:text-red-300">
                        Remover
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Filiais Tab -->
        <div v-if="activeTab === 'filiais'">
          <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-white">Gestão de Filiais</h2>
            <button @click="showNovaFilial = true" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors">
              + Nova Filial
            </button>
          </div>
          
          <!-- Lista de Filiais -->
          <div class="bg-gray-900/50 rounded-xl border border-gray-800">
            <div v-if="isLoadingFiliais" class="p-6 text-center">
              <p class="text-gray-400">Carregando filiais...</p>
            </div>
            
            <div v-else-if="filiais.length === 0" class="p-6 text-center">
              <p class="text-gray-400">Nenhuma filial cadastrada ainda.</p>
            </div>
            
            <div v-else class="overflow-x-auto">
              <table class="w-full">
                <thead class="border-b border-gray-800">
                  <tr>
                    <th class="text-left p-4 text-gray-400 font-medium">Nome</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Código</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Status</th>
                    <th class="text-left p-4 text-gray-400 font-medium">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="filial in filiais" :key="filial.id" class="border-b border-gray-800 hover:bg-gray-800/30">
                    <td class="p-4 text-white">{{ filial.nome }}</td>
                    <td class="p-4 text-gray-300">{{ filial.codigo }}</td>
                    <td class="p-4">
                      <span :class="filial.ativo ? 'text-green-400' : 'text-red-400'">
                        {{ filial.ativo ? 'Ativa' : 'Inativa' }}
                      </span>
                    </td>
                    <td class="p-4">
                      <button @click="editarFilial(filial)" class="text-blue-400 hover:text-blue-300 mr-3">
                        Editar
                      </button>
                      <button @click="removerFilial(filial.id)" class="text-red-400 hover:text-red-300">
                        Remover
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase, testarConexao } from '../services/supabase.js'

const activeTab = ref('dashboard')

// Status da conexão com Supabase
const statusConexao = ref({
  texto: 'Conectando...',
  cor: 'text-yellow-400',
  loading: true
})

// Dados reais do banco
const stats = ref({
  totalClientes: 0,
  nfesMes: 0,
  receitaMensal: 0,
  mensagensHoje: 0
})

const clientes = ref([])
const isLoading = ref(false)
const showNovoCliente = ref(false)
const salvandoCliente = ref(false)

const funcionarios = ref([])
const isLoadingFuncionarios = ref(false)
const showNovoFuncionario = ref(false)
const salvandoFuncionario = ref(false)

const filiais = ref([])
const isLoadingFiliais = ref(false)
const showNovaFilial = ref(false)
const salvandoFilial = ref(false)

const novoCliente = ref({
  nome: '',
  cnpj: '',
  email: '',
  telefone: '',
  senha: '',
  filiais: []
})

const clienteEditando = ref(null)

const novoFuncionario = ref({
  nome: '',
  email: '',
  cargo: '',
  telefone: '',
  filial_id: ''
})

const novaFilial = ref({
  nome: '',
  codigo: ''
})

// Variáveis para relatórios
const loadingRelatorios = ref(false)
const solicitacoesPendentes = ref([])
const modalRelatorioAberto = ref(false)
const solicitacaoSelecionada = ref(null)
const datasParaProcessar = ref([])
const processandoRelatorio = ref(false)
const ocultarNotificacao = ref(false)

const API_BASE_URL = 'https://api.dnotas.com.br:9999'

// Carregar estatísticas reais
const carregarEstatisticas = async () => {
  try {
    isLoading.value = true
    
    // Contar clientes reais da tabela clientes
    const { count: clientesCount } = await supabase
      .from('clientes')
      .select('*', { count: 'exact', head: true })
    
    stats.value.totalClientes = clientesCount || 0
    
    console.log('Estatísticas carregadas:', stats.value)
  } catch (error) {
    console.error('Erro ao carregar estatísticas:', error)
  } finally {
    isLoading.value = false
  }
}

// Carregar lista de clientes reais
const carregarClientes = async () => {
  try {
    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    
    clientes.value = data || []
    console.log('Clientes carregados:', clientes.value)
  } catch (error) {
    console.error('Erro ao carregar clientes:', error)
  }
}

// Salvar novo cliente
const salvarCliente = async () => {
  try {
    salvandoCliente.value = true
    
    // Remover formatação do CNPJ antes de salvar (manter apenas números)
    const cnpjLimpo = novoCliente.value.cnpj.replace(/\D/g, '')
    
    // Validar CNPJ (deve ter 14 dígitos)
    if (cnpjLimpo.length !== 14) {
      alert('CNPJ deve ter exatamente 14 dígitos!')
      return
    }
    
    console.log('CNPJ formatado:', novoCliente.value.cnpj)
    console.log('CNPJ limpo para salvar:', cnpjLimpo)
    
    const { data, error } = await supabase
      .from('clientes')
      .insert([{
        cnpj: cnpjLimpo, // Salvar só números
        nome_empresa: novoCliente.value.nome,
        senha: novoCliente.value.senha,
        filial_id: '11111111-1111-1111-1111-111111111111', // ID da matriz com chaves Asaas
        is_active: true
      }])
      .select()
    
    if (error) throw error
    
    alert('Cliente cadastrado com sucesso!')
    
    // Limpar formulário e fechar modal
    novoCliente.value = { nome: '', cnpj: '', email: '', telefone: '', senha: '', filiais: [] }
    showNovoCliente.value = false
    clienteEditando.value = null
    
    // Recarregar listas
    await carregarClientes()
    await carregarEstatisticas()
    
    console.log('Cliente salvo:', data)
  } catch (error) {
    console.error('Erro ao salvar cliente:', error)
    alert('Erro ao salvar cliente: ' + error.message)
  } finally {
    salvandoCliente.value = false
  }
}

// Remover cliente
const removerCliente = async (id) => {
  if (!confirm('Tem certeza que deseja remover este cliente?')) return
  
  try {
    const { error } = await supabase
      .from('clientes')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    // Recarregar listas
    await carregarClientes()
    await carregarEstatisticas()
    
    console.log('Cliente removido')
  } catch (error) {
    console.error('Erro ao remover cliente:', error)
    alert('Erro ao remover cliente: ' + error.message)
  }
}

// Fechar modal de cliente
const fecharModalCliente = () => {
  showNovoCliente.value = false
  clienteEditando.value = null
  novoCliente.value = { nome: '', cnpj: '', email: '', telefone: '', senha: '', filiais: [] }
}

// Adicionar filial ao formulário
const adicionarFilial = () => {
  novoCliente.value.filiais.push({
    cnpj: '',
    nome: ''
  })
}

// Remover filial do formulário
const removerFilialFormulario = (index) => {
  novoCliente.value.filiais.splice(index, 1)
}

// Formatar CNPJ da filial
const formatarCnpjFilial = (index, event) => {
  const input = event.target
  let value = input.value.replace(/\D/g, '')
  
  if (value.length <= 14) {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
    novoCliente.value.filiais[index].cnpj = value
  }
}

// Editar cliente
const editarCliente = async (cliente) => {
  console.log('Editar cliente:', cliente)
  clienteEditando.value = cliente
  
  // Preencher formulário com dados do cliente
  novoCliente.value = {
    nome: cliente.nome_empresa,
    cnpj: formatarCNPJExibicao(cliente.cnpj),
    email: cliente.email || '',
    telefone: cliente.telefone || '',
    senha: '',
    filiais: []
  }
  
  // Buscar filiais do cliente (se houver)
  try {
    // TODO: Implementar busca de filiais da API
    // const filiais = await clientFiliaisService.getFiliais(cliente.cnpj)
    // novoCliente.value.filiais = filiais.filiais.filter(f => f.tipo === 'filial')
  } catch (error) {
    console.error('Erro ao carregar filiais:', error)
  }
}

// Formatar data
const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('pt-BR')
}

// Formatar CNPJ para exibição
const formatarCNPJExibicao = (cnpj) => {
  if (!cnpj) return ''
  
  // Remove qualquer formatação existente
  const cnpjLimpo = cnpj.replace(/\D/g, '')
  
  // Se não tem 14 dígitos, retorna como está
  if (cnpjLimpo.length !== 14) return cnpj
  
  // Aplica a formatação XX.XXX.XXX/XXXX-XX
  return cnpjLimpo.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
}

// Carregar funcionários
const carregarFuncionarios = async () => {
  try {
    isLoadingFuncionarios.value = true
    const { data, error } = await supabase
      .from('funcionarios')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    
    funcionarios.value = data || []
    console.log('Funcionários carregados:', funcionarios.value)
  } catch (error) {
    console.error('Erro ao carregar funcionários:', error)
  } finally {
    isLoadingFuncionarios.value = false
  }
}

// Carregar filiais
const carregarFiliais = async () => {
  try {
    isLoadingFiliais.value = true
    const { data, error } = await supabase
      .from('filiais')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    
    filiais.value = data || []
    console.log('Filiais carregadas:', filiais.value)
  } catch (error) {
    console.error('Erro ao carregar filiais:', error)
  } finally {
    isLoadingFiliais.value = false
  }
}

// Salvar funcionário
const salvarFuncionario = async () => {
  try {
    salvandoFuncionario.value = true
    
    // Gerar senha temporária
    const senhaTemporaria = Math.random().toString(36).slice(-8)
    
    const { data, error } = await supabase
      .from('funcionarios')
      .insert([{
        nome: novoFuncionario.value.nome,
        email: novoFuncionario.value.email,
        cargo: novoFuncionario.value.cargo,
        telefone: novoFuncionario.value.telefone,
        organizacao_id: novoFuncionario.value.filial_id, // Usar organizacao_id
        senha: senhaTemporaria,
        ativo: true // Usar ativo ao invés de is_active
      }])
      .select()
    
    if (error) throw error
    
    alert(`Funcionário cadastrado com sucesso!\\nSenha temporária: ${senhaTemporaria}`)
    
    // Limpar formulário e fechar modal
    novoFuncionario.value = { nome: '', email: '', cargo: '', telefone: '', filial_id: '' }
    showNovoFuncionario.value = false
    
    // Recarregar lista
    await carregarFuncionarios()
    
    console.log('Funcionário salvo:', data)
  } catch (error) {
    console.error('Erro ao salvar funcionário:', error)
    alert('Erro ao salvar funcionário: ' + error.message)
  } finally {
    salvandoFuncionario.value = false
  }
}

// Salvar filial
const salvarFilial = async () => {
  try {
    salvandoFilial.value = true
    
    const { data, error } = await supabase
      .from('filiais')
      .insert([{
        nome: novaFilial.value.nome,
        codigo: novaFilial.value.codigo,
        ativo: true // Usar ativo ao invés de is_active
      }])
      .select()
    
    if (error) throw error
    
    alert('Filial cadastrada com sucesso!')
    
    // Limpar formulário e fechar modal
    novaFilial.value = { nome: '', codigo: '' }
    showNovaFilial.value = false
    
    // Recarregar lista
    await carregarFiliais()
    
    console.log('Filial salva:', data)
  } catch (error) {
    console.error('Erro ao salvar filial:', error)
    alert('Erro ao salvar filial: ' + error.message)
  } finally {
    salvandoFilial.value = false
  }
}

// Remover funcionário
const removerFuncionario = async (id) => {
  if (!confirm('Tem certeza que deseja remover este funcionário?')) return
  
  try {
    const { error } = await supabase
      .from('funcionarios')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    await carregarFuncionarios()
    console.log('Funcionário removido')
  } catch (error) {
    console.error('Erro ao remover funcionário:', error)
    alert('Erro ao remover funcionário: ' + error.message)
  }
}

// Remover filial
const removerFilial = async (id) => {
  if (!confirm('Tem certeza que deseja remover esta filial?')) return
  
  try {
    const { error } = await supabase
      .from('filiais')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    await carregarFiliais()
    console.log('Filial removida')
  } catch (error) {
    console.error('Erro ao remover filial:', error)
    alert('Erro ao remover filial: ' + error.message)
  }
}

// Editar funcionário (placeholder)
const editarFuncionario = (funcionario) => {
  console.log('Editar funcionário:', funcionario)
  // TODO: implementar modal de edição
}

// Editar filial (placeholder)
const editarFilial = (filial) => {
  console.log('Editar filial:', filial)
  // TODO: implementar modal de edição
}

// Função para formatar CNPJ enquanto digita
const formatarCNPJ = (event) => {
  let value = event.target.value.replace(/\D/g, '') // Remove tudo que não é número
  
  // Aplica a máscara XX.XXX.XXX/XXXX-XX
  if (value.length <= 2) {
    value = value
  } else if (value.length <= 5) {
    value = value.replace(/(\d{2})(\d+)/, '$1.$2')
  } else if (value.length <= 8) {
    value = value.replace(/(\d{2})(\d{3})(\d+)/, '$1.$2.$3')
  } else if (value.length <= 12) {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d+)/, '$1.$2.$3/$4')
  } else {
    value = value.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d+)/, '$1.$2.$3/$4-$5')
  }
  
  // Limita a 14 dígitos (18 caracteres com formatação)
  if (value.replace(/\D/g, '').length > 14) {
    value = value.substring(0, 18)
  }
  
  novoCliente.value.cnpj = value
  event.target.value = value
}

// ===============================
// FUNÇÕES PARA RELATÓRIOS
// ===============================

// Carregar solicitações pendentes
async function loadSolicitacoes() {
  loadingRelatorios.value = true
  try {
    console.log('DEBUG DASHBOARD: Carregando solicitações de:', `${API_BASE_URL}/api/admin/solicitacoes/pendentes`)
    const response = await fetch(`${API_BASE_URL}/api/admin/solicitacoes/pendentes`)
    console.log('DEBUG DASHBOARD: Response status:', response.status)
    
    const data = await response.json()
    console.log('DEBUG DASHBOARD: Response data:', data)
    
    if (data.success) {
      solicitacoesPendentes.value = data.data
      console.log('DEBUG DASHBOARD: Solicitações carregadas:', data.data.length)
    } else {
      console.error('DEBUG DASHBOARD: API retornou success=false:', data)
    }
  } catch (error) {
    console.error('Erro ao carregar solicitações:', error)
  } finally {
    loadingRelatorios.value = false
  }
}

// Formatar período do relatório
function formatPeriodo(solicitacao) {
  const inicio = new Date(solicitacao.data_inicio).toLocaleDateString('pt-BR')
  const fim = new Date(solicitacao.data_fim).toLocaleDateString('pt-BR')
  
  if (solicitacao.tipo_periodo === 'dia_unico') {
    return inicio
  } else {
    return `${inicio} até ${fim}`
  }
}

// Formatar data para relatórios
function formatDateRelatorio(dateString) {
  return new Date(dateString).toLocaleString('pt-BR')
}

// Abrir modal de processamento
function abrirModalProcessamento(solicitacao) {
  solicitacaoSelecionada.value = solicitacao
  modalRelatorioAberto.value = true
  
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

// Fechar modal de processamento
function fecharModalRelatorio() {
  modalRelatorioAberto.value = false
  solicitacaoSelecionada.value = null
  datasParaProcessar.value = []
}

// Processar relatório
async function processarRelatorio() {
  if (!solicitacaoSelecionada.value) return
  
  processandoRelatorio.value = true
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
      fecharModalRelatorio()
      loadSolicitacoes() // Recarregar lista
    } else {
      throw new Error(data.error)
    }
  } catch (error) {
    console.error('Erro ao processar relatório:', error)
    alert('Erro ao processar relatório: ' + error.message)
  } finally {
    processandoRelatorio.value = false
  }
}

onMounted(async () => {
  // Testar conexão primeiro
  statusConexao.value = {
    texto: 'Conectando...',
    cor: 'text-yellow-400',
    loading: true
  }
  
  try {
    const conexaoOK = await testarConexao()
    console.log('Status da conexão:', conexaoOK)
    
    if (conexaoOK) {
      statusConexao.value = {
        texto: 'Conectado',
        cor: 'text-green-400',
        loading: false
      }
      
      // Carregar dados
      await Promise.all([
        carregarEstatisticas(),
        carregarClientes(),
        carregarFuncionarios(),
        carregarFiliais(),
        loadSolicitacoes()
      ])
      
      console.log('✅ Todas as operações concluídas com sucesso')
    } else {
      throw new Error('Conexão falhou')
    }
  } catch (error) {
    console.error('❌ Falha na conexão com Supabase:', error)
    statusConexao.value = {
      texto: 'Erro de Conexão',
      cor: 'text-red-400',
      loading: false
    }
  }
})
</script>