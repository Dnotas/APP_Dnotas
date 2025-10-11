<template>
  <div class="min-h-screen relative overflow-hidden bg-gray-950">
    <!-- Background gradient -->
    <div class="absolute inset-0 bg-gradient-to-br from-blue-900/20 via-gray-900 to-purple-900/20"></div>
    
    <!-- Animated background elements -->
    <div class="absolute inset-0">
      <div class="absolute top-10 left-10 w-72 h-72 bg-blue-500/10 rounded-full blur-3xl animate-pulse-slow"></div>
      <div class="absolute bottom-10 right-10 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse-slow delay-1000"></div>
    </div>
    
    <div class="relative z-10 min-h-screen flex items-center justify-center p-8">
      <div class="w-full max-w-md">
        <div class="card-glass glow-effect animate-fade-in">
          <!-- Header -->
          <div class="text-center mb-8">
            <div class="mb-6">
              <div class="w-20 h-10 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mx-auto shadow-xl">
                <span class="text-white font-bold text-lg">DNOTAS</span>
              </div>
            </div>
            
            <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-blue-400 to-blue-500 bg-clip-text text-transparent">
              Cadastrar Funcionário
            </h2>
            <p class="text-gray-400">
              Criar nova conta para funcionário
            </p>
          </div>
          
          <!-- Form -->
          <form @submit.prevent="handleRegister" class="space-y-6">
            <div class="space-y-4">
              <!-- Nome -->
              <div>
                <label for="nome" class="block text-sm font-medium text-gray-300 mb-2">
                  Nome Completo
                </label>
                <input
                  id="nome"
                  v-model="form.nome"
                  type="text"
                  required
                  class="input-field"
                  placeholder="João Silva Santos"
                />
              </div>

              <!-- Email -->
              <div>
                <label for="email" class="block text-sm font-medium text-gray-300 mb-2">
                  Email
                </label>
                <input
                  id="email"
                  v-model="form.email"
                  type="email"
                  required
                  class="input-field"
                  placeholder="joao.silva@dnotas.com"
                />
              </div>

              <!-- Cargo -->
              <div>
                <label for="cargo" class="block text-sm font-medium text-gray-300 mb-2">
                  Cargo
                </label>
                <input
                  id="cargo"
                  v-model="form.cargo"
                  type="text"
                  required
                  class="input-field"
                  placeholder="Atendente, Analista, Gerente..."
                />
              </div>

              <!-- Filial -->
              <div>
                <label for="filial" class="block text-sm font-medium text-gray-300 mb-2">
                  Filial
                </label>
                <select
                  id="filial"
                  v-model="form.filial_id"
                  required
                  class="input-field"
                  @change="console.log('Filial selecionada:', form.filial_id)"
                >
                  <option value="">Selecione a filial</option>
                  <option 
                    v-for="filial in filiais" 
                    :key="filial.id" 
                    :value="filial.id"
                  >
                    {{ filial.tipo === 'matriz' ? '🏢' : '🏪' }} {{ filial.nome }}
                  </option>
                </select>
              </div>

              <!-- Perfil -->
              <div>
                <label for="role" class="block text-sm font-medium text-gray-300 mb-2">
                  Perfil de Acesso
                </label>
                <select
                  id="role"
                  v-model="form.role"
                  required
                  class="input-field"
                >
                  <option value="operator">👤 Operador</option>
                  <option value="manager">👨‍💼 Gerente</option>
                  <option value="admin">👑 Administrador</option>
                </select>
              </div>

              <!-- Senha -->
              <div>
                <label for="senha" class="block text-sm font-medium text-gray-300 mb-2">
                  Senha
                </label>
                <input
                  id="senha"
                  v-model="form.senha"
                  type="password"
                  required
                  class="input-field"
                  placeholder="••••••••"
                  minlength="6"
                />
              </div>

              <!-- Confirmar Senha -->
              <div>
                <label for="confirmarSenha" class="block text-sm font-medium text-gray-300 mb-2">
                  Confirmar Senha
                </label>
                <input
                  id="confirmarSenha"
                  v-model="confirmarSenha"
                  type="password"
                  required
                  class="input-field"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <!-- Error/Success Messages -->
            <div v-if="error" class="p-4 bg-red-500/10 border border-red-500/20 rounded-xl">
              <div class="flex items-center space-x-2">
                <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-red-400 text-sm">{{ error }}</span>
              </div>
            </div>

            <div v-if="success" class="p-4 bg-green-500/10 border border-green-500/20 rounded-xl">
              <div class="flex items-center space-x-2">
                <svg class="w-5 h-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                <span class="text-green-400 text-sm">Funcionário cadastrado com sucesso!</span>
              </div>
            </div>

            <!-- Buttons -->
            <div class="space-y-3">
              <button
                type="submit"
                :disabled="isLoading"
                class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                @click="console.log('Botão clicado!')"
              >
                <span v-if="isLoading" class="flex items-center justify-center">
                  <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Cadastrando...
                </span>
                <span v-else>Cadastrar Funcionário</span>
              </button>

              <router-link
                to="/login"
                class="w-full btn-secondary text-center block"
              >
                ← Voltar ao Login
              </router-link>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { funcionariosService } from '@/services/funcionarios'

const router = useRouter()

const form = ref({
  nome: '',
  email: '',
  cargo: '',
  filial_id: '',
  role: 'operator',
  senha: ''
})

const confirmarSenha = ref('')
const filiais = ref<Array<{id: string, nome: string, tipo: string}>>([])
const isLoading = ref(false)
const error = ref('')
const success = ref(false)

// Carregar filiais
onMounted(async () => {
  console.log('RegisterView: Carregando filiais...')
  try {
    const response = await funcionariosService.getFiliais()
    console.log('RegisterView: Resposta getFiliais:', response)
    if (response.success) {
      filiais.value = response.filiais
      console.log('RegisterView: Filiais carregadas:', filiais.value)
    } else {
      console.error('RegisterView: Erro ao carregar filiais:', response.error)
    }
  } catch (error) {
    console.error('RegisterView: Erro na requisição:', error)
  }
})

const handleRegister = async () => {
  console.log('RegisterView: handleRegister chamado')
  
  if (form.value.senha !== confirmarSenha.value) {
    error.value = 'As senhas não coincidem'
    return
  }

  if (form.value.senha.length < 6) {
    error.value = 'A senha deve ter pelo menos 6 caracteres'
    return
  }

  try {
    isLoading.value = true
    error.value = ''
    success.value = false

    console.log('RegisterView: Dados do formulário:', form.value)
    const response = await funcionariosService.criarFuncionario(form.value)
    console.log('RegisterView: Resposta do cadastro:', response)
    
    if (response.success) {
      success.value = true
      
      // Limpar formulário
      form.value = {
        nome: '',
        email: '',
        cargo: '',
        filial_id: '',
        role: 'operator',
        senha: ''
      }
      confirmarSenha.value = ''

      // Redirecionar após 2 segundos
      setTimeout(() => {
        router.push('/login')
      }, 2000)
    } else {
      error.value = response.error || 'Erro ao cadastrar funcionário'
    }
  } catch (err) {
    error.value = 'Erro de conexão'
    console.error('Register error:', err)
  } finally {
    isLoading.value = false
  }
}
</script>