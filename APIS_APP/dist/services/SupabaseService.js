"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.databaseService = exports.SupabaseService = void 0;
const supabase_js_1 = require("@supabase/supabase-js");
class SupabaseService {
    constructor() {
        const supabaseUrl = process.env.SUPABASE_URL || 'https://cqqeylhspmpilzgmqfiu.supabase.co';
        const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';
        this.client = (0, supabase_js_1.createClient)(supabaseUrl, supabaseServiceKey);
    }
    static getInstance() {
        if (!SupabaseService.instance) {
            SupabaseService.instance = new SupabaseService();
        }
        return SupabaseService.instance;
    }
    static async initialize() {
        const instance = SupabaseService.getInstance();
        try {
            const { data, error } = await instance.client.from('clientes').select('count').limit(1);
            if (error) {
                console.log('⚠️ Aviso: Não foi possível conectar ao Supabase:', error.message);
            }
            else {
                console.log('✅ Conexão com Supabase estabelecida');
            }
        }
        catch (error) {
            console.log('⚠️ Aviso: Não foi possível conectar ao Supabase:', error);
        }
    }
    async getClientes(filialId) {
        let query = this.client.from('clientes').select('*');
        if (filialId) {
            query = query.eq('filial_id', filialId);
        }
        return await query;
    }
    async getClienteByCnpj(cnpj) {
        return await this.client
            .from('clientes')
            .select('*')
            .eq('cnpj', cnpj)
            .single();
    }
    async createCliente(cliente) {
        return await this.client
            .from('clientes')
            .insert(cliente)
            .select()
            .single();
    }
    async getRelatoriosVendas(clienteCnpj, filialId) {
        let query = this.client.from('relatorios_vendas').select('*');
        if (clienteCnpj) {
            query = query.eq('cliente_cnpj', clienteCnpj);
        }
        if (filialId) {
            query = query.eq('filial_id', filialId);
        }
        return await query.order('data_relatorio', { ascending: false });
    }
    async createRelatorioVendas(relatorio) {
        return await this.client
            .from('relatorios_vendas')
            .insert(relatorio)
            .select()
            .single();
    }
    async getBoletos(clienteCnpj, filialId) {
        let query = this.client.from('boletos').select('*');
        if (clienteCnpj) {
            query = query.eq('cliente_cnpj', clienteCnpj);
        }
        if (filialId) {
            query = query.eq('filial_id', filialId);
        }
        return await query.order('data_vencimento', { ascending: true });
    }
    async createBoleto(boleto) {
        return await this.client
            .from('boletos')
            .insert(boleto)
            .select()
            .single();
    }
    async updateBoletoStatus(id, status, dataPagamento) {
        const updateData = { status };
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
    async getMensagens(clienteCnpj) {
        let query = this.client.from('mensagens').select('*');
        if (clienteCnpj) {
            query = query.eq('cliente_cnpj', clienteCnpj);
        }
        return await query.order('created_at', { ascending: true });
    }
    async createMensagem(mensagem) {
        return await this.client
            .from('mensagens')
            .insert(mensagem)
            .select()
            .single();
    }
    async getNotificacoes(clienteCnpj) {
        let query = this.client.from('notificacoes').select('*');
        if (clienteCnpj) {
            query = query.eq('cliente_cnpj', clienteCnpj);
        }
        return await query.order('created_at', { ascending: false });
    }
    async createNotificacao(notificacao) {
        return await this.client
            .from('notificacoes')
            .insert(notificacao)
            .select()
            .single();
    }
    async getFiliais() {
        return await this.client
            .from('filiais')
            .select('*')
            .eq('ativo', true);
    }
    async executeQuery(tableName, operation, data, filters) {
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
        if (filters) {
            Object.keys(filters).forEach(key => {
                query = query.eq(key, filters[key]);
            });
        }
        return await query;
    }
    async query(sql, params) {
        console.log('⚠️ Query SQL não é suportada diretamente. Use métodos específicos do SupabaseService');
        return { rows: [] };
    }
    async exists(table, condition, params) {
        try {
            const { data, error } = await this.client
                .from(table)
                .select('id')
                .limit(1);
            return !error && data && data.length > 0;
        }
        catch {
            return false;
        }
    }
    async count(table) {
        try {
            const { count, error } = await this.client
                .from(table)
                .select('*', { count: 'exact', head: true });
            return error ? 0 : count || 0;
        }
        catch {
            return 0;
        }
    }
}
exports.SupabaseService = SupabaseService;
exports.databaseService = SupabaseService.getInstance();
//# sourceMappingURL=SupabaseService.js.map