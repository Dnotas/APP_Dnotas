import { createClient, SupabaseClient } from '@supabase/supabase-js';

export class SupabaseService {
  private static instance: SupabaseService;
  private client: SupabaseClient;

  private constructor() {
    const supabaseUrl = process.env.SUPABASE_URL || 'https://cqqeylhspmpilzgmqfiu.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';
    
    this.client = createClient(supabaseUrl, supabaseServiceKey);
  }

  public static getInstance(): SupabaseService {
    if (!SupabaseService.instance) {
      SupabaseService.instance = new SupabaseService();
    }
    return SupabaseService.instance;
  }

  public static async initialize(): Promise<void> {
    const instance = SupabaseService.getInstance();
    try {
      // Testar conexão
      const { data, error } = await instance.client.from('clientes').select('count').limit(1);
      if (error) {
        console.log('⚠️ Aviso: Não foi possível conectar ao Supabase:', error.message);
      } else {
        console.log('✅ Conexão com Supabase estabelecida');
      }
    } catch (error) {
      console.log('⚠️ Aviso: Não foi possível conectar ao Supabase:', error);
    }
  }

  // Métodos para clientes
  async getClientes(filialId?: string) {
    let query = this.client.from('clientes').select('*');
    if (filialId) {
      query = query.eq('filial_id', filialId);
    }
    return await query;
  }

  async getClienteByCnpj(cnpj: string) {
    return await this.client
      .from('clientes')
      .select('*')
      .eq('cnpj', cnpj)
      .single();
  }

  async createCliente(cliente: any) {
    return await this.client
      .from('clientes')
      .insert(cliente)
      .select()
      .single();
  }

  // Métodos para relatórios
  async getRelatoriosVendas(clienteCnpj?: string, filialId?: string) {
    let query = this.client.from('relatorios_vendas').select('*');
    if (clienteCnpj) {
      query = query.eq('cliente_cnpj', clienteCnpj);
    }
    if (filialId) {
      query = query.eq('filial_id', filialId);
    }
    return await query.order('data_relatorio', { ascending: false });
  }

  async createRelatorioVendas(relatorio: any) {
    return await this.client
      .from('relatorios_vendas')
      .insert(relatorio)
      .select()
      .single();
  }

  // Métodos para boletos
  async getBoletos(clienteCnpj?: string, filialId?: string) {
    let query = this.client.from('boletos').select('*');
    if (clienteCnpj) {
      query = query.eq('cliente_cnpj', clienteCnpj);
    }
    if (filialId) {
      query = query.eq('filial_id', filialId);
    }
    return await query.order('data_vencimento', { ascending: true });
  }

  async createBoleto(boleto: any) {
    return await this.client
      .from('boletos')
      .insert(boleto)
      .select()
      .single();
  }

  async updateBoletoStatus(id: string, status: string, dataPagamento?: string) {
    const updateData: any = { status };
    if (dataPagamento) {
      updateData.data_pagamento = dataPagamento;
    }
    
    return await this.client
      .from('boletos')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();
  }

  // Métodos para mensagens
  async getMensagens(clienteCnpj?: string) {
    let query = this.client.from('mensagens').select('*');
    if (clienteCnpj) {
      query = query.eq('cliente_cnpj', clienteCnpj);
    }
    return await query.order('created_at', { ascending: true });
  }

  async createMensagem(mensagem: any) {
    return await this.client
      .from('mensagens')
      .insert(mensagem)
      .select()
      .single();
  }

  // Métodos para notificações
  async getNotificacoes(clienteCnpj?: string) {
    let query = this.client.from('notificacoes').select('*');
    if (clienteCnpj) {
      query = query.eq('cliente_cnpj', clienteCnpj);
    }
    return await query.order('created_at', { ascending: false });
  }

  async createNotificacao(notificacao: any) {
    return await this.client
      .from('notificacoes')
      .insert(notificacao)
      .select()
      .single();
  }

  // Métodos para filiais
  async getFiliais() {
    return await this.client
      .from('filiais')
      .select('*')
      .eq('ativo', true);
  }

  // Método genérico para executar queries personalizadas
  async executeQuery(tableName: string, operation: 'select' | 'insert' | 'update' | 'delete', data?: any, filters?: any) {
    let query = this.client.from(tableName);
    
    switch (operation) {
      case 'select':
        query = query.select(data || '*');
        break;
      case 'insert':
        return await query.insert(data).select();
      case 'update':
        return await query.update(data);
      case 'delete':
        return await query.delete();
    }
    
    // Aplicar filtros
    if (filters) {
      Object.keys(filters).forEach(key => {
        query = query.eq(key, filters[key]);
      });
    }
    
    return await query;
  }

  // Para compatibilidade com DatabaseService
  async query(sql: string, params?: any[]): Promise<{ rows: any[] }> {
    // Para queries simples, tentar mapear para Supabase
    console.log('⚠️ Query SQL não é suportada diretamente. Use métodos específicos do SupabaseService');
    return { rows: [] };
  }

  async exists(table: string, condition: string, params: any[]): Promise<boolean> {
    try {
      const { data, error } = await this.client
        .from(table)
        .select('id')
        .limit(1);
      
      return !error && data && data.length > 0;
    } catch {
      return false;
    }
  }

  async count(table: string): Promise<number> {
    try {
      const { count, error } = await this.client
        .from(table)
        .select('*', { count: 'exact', head: true });
      
      return error ? 0 : count || 0;
    } catch {
      return 0;
    }
  }
}

// Para compatibilidade com código existente
export const databaseService = SupabaseService.getInstance();