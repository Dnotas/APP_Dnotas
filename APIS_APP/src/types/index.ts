export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  errors?: string[];
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface User {
  id: string;
  cnpj: string;
  nome_empresa: string;
  email: string;
  telefone?: string;
  filial_id: string;
  is_active: boolean;
  last_login?: Date;
  fcm_token?: string;
  reset_token?: string;
  reset_token_expiry?: Date;
  created_at: Date;
}

export interface Filial {
  id: string;
  nome: string;
  codigo?: string;
  cnpj_empresa?: string;
  ativo?: boolean;
  created_at: Date;
}

export interface RelatorioVendas {
  id: string;
  cliente_id: string;
  cliente_cnpj: string;
  filial_id: string;
  data_relatorio: Date;
  vendas_debito: number;
  vendas_credito: number;
  vendas_dinheiro: number;
  vendas_pix: number;
  vendas_vale: number;
  total_vendas: number;
  created_at: Date;
  updated_at?: Date;
}

export interface Boleto {
  id: string;
  cliente_id: string;
  cliente_cnpj: string;
  filial_id: string;
  numero_boleto: string;
  valor: number;
  data_vencimento: Date;
  data_pagamento?: Date;
  status: 'pendente' | 'pago' | 'vencido' | 'cancelado';
  linha_digitavel: string;
  codigo_barras: string;
  created_at: Date;
  updated_at?: Date;
}

export interface Notification {
  id: string;
  cliente_cnpj: string;
  filial_id: string;
  tipo: 'relatorio' | 'boleto' | 'inatividade' | 'geral';
  titulo: string;
  mensagem: string;
  lida: boolean;
  data_envio: Date;
  created_at: Date;
}

export interface AuthToken {
  token: string;
  expiresIn: string;
  user: Omit<User, 'senha'>;
}

export interface LoginCredentials {
  cnpj: string;
  senha: string;
}

export interface RegisterData {
  cnpj: string;
  nome_empresa: string;
  email: string;
  telefone?: string;
  senha: string;
  filial_id: string;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
}

export interface RelatorioFilters extends PaginationParams {
  dataInicio?: string;
  dataFim?: string;
  tipoRelatorio?: 'vendas' | 'financeiro';
}

export interface BoletoFilters extends PaginationParams {
  status?: string;
  dataVencimentoInicio?: string;
  dataVencimentoFim?: string;
}

export interface NotificationFilters extends PaginationParams {
  tipo?: string;
  lida?: boolean;
  dataInicio?: string;
  dataFim?: string;
}