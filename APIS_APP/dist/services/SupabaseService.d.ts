export declare class SupabaseService {
    private static instance;
    private client;
    private constructor();
    static getInstance(): SupabaseService;
    static initialize(): Promise<void>;
    getClientes(filialId?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    getClienteByCnpj(cnpj: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    createCliente(cliente: any): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    getRelatoriosVendas(clienteCnpj?: string, filialId?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    createRelatorioVendas(relatorio: any): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    getBoletos(clienteCnpj?: string, filialId?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    createBoleto(boleto: any): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    updateBoletoStatus(id: string, status: string, dataPagamento?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    getMensagens(clienteCnpj?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    createMensagem(mensagem: any): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    getNotificacoes(clienteCnpj?: string): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    createNotificacao(notificacao: any): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any>>;
    getFiliais(): Promise<import("@supabase/supabase-js").PostgrestSingleResponse<any[]>>;
    executeQuery(tableName: string, operation: 'select' | 'insert' | 'update' | 'delete', data?: any, filters?: any): Promise<import("@supabase/postgrest-js").PostgrestResponseFailure | import("@supabase/postgrest-js").PostgrestResponseSuccess<any[]> | import("@supabase/postgrest-js").PostgrestQueryBuilder<any, any, any, string, unknown> | import("@supabase/postgrest-js").PostgrestResponseSuccess<null>>;
    query(sql: string, params?: any[]): Promise<{
        rows: any[];
    }>;
    exists(table: string, condition: string, params: any[]): Promise<boolean>;
    count(table: string): Promise<number>;
}
export declare const databaseService: SupabaseService;
//# sourceMappingURL=SupabaseService.d.ts.map