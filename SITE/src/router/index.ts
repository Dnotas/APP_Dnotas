import { createRouter, createWebHashHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import LoginView from '@/views/LoginView.vue'
import RegisterView from '@/views/RegisterView.vue'
import DashboardView from '@/views/DashboardView.vue'
import AdminDashboardView from '@/views/AdminDashboardView.vue'
import FiliaisView from '@/views/FiliaisView.vue'
import FuncionariosView from '@/views/FuncionariosView.vue'
import ChatView from '@/views/ChatView.vue'
import ClientsView from '@/views/ClientsView.vue'
import ReportsView from '@/views/ReportsView.vue'
import FinancialView from '@/views/FinancialView.vue'

const router = createRouter({
  history: createWebHashHistory('/APP_Dnotas/'),
  routes: [
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/MatrizDashboard.vue')
    },
    {
      path: '/admin/dashboard',
      name: 'admin-dashboard',
      component: AdminDashboardView,
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/filiais',
      name: 'admin-filiais',
      component: FiliaisView,
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/funcionarios',
      name: 'admin-funcionarios',
      component: FuncionariosView,
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/chat',
      name: 'chat',
      component: ChatView,
      meta: { requiresAuth: true }
    },
    {
      path: '/clients',
      name: 'clients',
      component: ClientsView,
      meta: { requiresAuth: true }
    },
    {
      path: '/reports',
      name: 'reports',
      component: ReportsView,
      meta: { requiresAuth: true }
    },
    {
      path: '/financial',
      name: 'financial',
      component: FinancialView,
      meta: { requiresAuth: true }
    }
  ]
})

// Sem autenticação - acesso direto
router.beforeEach((to, from, next) => {
  next()
})

export default router