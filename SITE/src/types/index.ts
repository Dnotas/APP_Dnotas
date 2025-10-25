export interface User {
  id: string
  email: string
  name: string
  filial_id: string
  role: 'admin' | 'operator' | 'manager'
}

export interface Client {
  id: string
  cnpj: string
  nome_empresa: string
  email: string
  telefone?: string
  filial_id: string
  is_active: boolean
  last_login?: string
  created_at: string
}

export interface Message {
  id: string
  content: string
  sender_id: string
  sender_name: string
  timestamp: string
  is_from_client: boolean
  client_cnpj?: string
  read: boolean
}

export interface ChatSession {
  client_cnpj: string
  client_name: string
  last_message: string
  last_message_time: string
  unread_count: number
  is_online: boolean
}

export interface Transaction {
  id: string
  description: string
  amount: number
  type: 'received' | 'sent'
  date: string
  category?: string
}

export interface Boleto {
  id: string
  numero: string
  descricao: string
  valor: number
  data_vencimento: string
  data_pagamento?: string
  status: 'pendente' | 'pago' | 'vencido'
  codigo_barras?: string
  client_cnpj: string
}

export interface DashboardStats {
  total_clients: number
  active_chats: number
  pending_boletos: number
  monthly_revenue: number
  daily_messages: number
  response_time_avg: number
}

export interface ClientFilial {
  id: string
  matriz_cnpj: string
  filial_cnpj: string
  filial_nome: string
  endereco?: string
  telefone?: string
  email?: string
  is_active: boolean
  created_at: string
  updated_at: string
}