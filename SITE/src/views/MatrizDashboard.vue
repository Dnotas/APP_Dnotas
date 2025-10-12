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

        <!-- Modal Novo Cliente -->
        <div v-if="showNovoCliente" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div class="bg-gray-900 rounded-xl p-6 w-full max-w-md border border-gray-800">
            <h3 class="text-xl font-bold text-white mb-4">Novo Cliente</h3>
            
            <form @submit.prevent="salvarCliente">
              <div class="space-y-4">
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Nome da Empresa</label>
                  <input v-model="novoCliente.nome" type="text" required 
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">CNPJ</label>
                  <input v-model="novoCliente.cnpj" 
                         type="text" 
                         required
                         placeholder="00.000.000/0000-00"
                         maxlength="18"
                         @input="formatarCNPJ"
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
                
                <div>
                  <label class="block text-gray-400 text-sm mb-2">Senha</label>
                  <input v-model="novoCliente.senha" type="password" required 
                         placeholder="Digite a senha do cliente"
                         class="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white">
                </div>
              </div>
              
              <div class="flex justify-end space-x-3 mt-6">
                <button type="button" @click="showNovoCliente = false" 
                        class="px-4 py-2 text-gray-400 hover:text-white transition-colors">
                  Cancelar
                </button>
                <button type="submit" :disabled="salvandoCliente"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50">
                  {{ salvandoCliente ? 'Salvando...' : 'Salvar' }}
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
                    <option value="matriz-id">Matriz</option>
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
  senha: ''
})

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
        filial_id: 'matriz-id', // ID que existe na tabela filiais
        is_active: true
      }])
      .select()
    
    if (error) throw error
    
    alert('Cliente cadastrado com sucesso!')
    
    // Limpar formulário e fechar modal
    novoCliente.value = { nome: '', cnpj: '', senha: '' }
    showNovoCliente.value = false
    
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

// Editar cliente (placeholder)
const editarCliente = (cliente) => {
  console.log('Editar cliente:', cliente)
  // TODO: implementar modal de edição
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
        carregarFiliais()
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