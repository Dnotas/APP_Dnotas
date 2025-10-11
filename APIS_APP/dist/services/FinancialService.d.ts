import { Boleto, BoletoFilters, ApiResponse } from '../types';
export declare class FinancialService {
    private db;
    private notificationService;
    constructor();
    criarBoleto(data: {
        cliente_cnpj: string;
        filial_id: string;
        numero_boleto: string;
        valor: number;
        data_vencimento: Date;
        linha_digitavel: string;
        codigo_barras: string;
    }): Promise<Boleto>;
    obterBoletosCliente(cliente_cnpj: string, filial_id: string, filters?: BoletoFilters): Promise<ApiResponse<Boleto[]>>;
    obterBoletosPendentes(cliente_cnpj: string, filial_id: string): Promise<Boleto[]>;
    obterBoletosVencidos(cliente_cnpj: string, filial_id: string): Promise<Boleto[]>;
    marcarBoletoPago(numero_boleto: string, cliente_cnpj: string, filial_id: string, data_pagamento?: Date): Promise<Boleto>;
    cancelarBoleto(numero_boleto: string, cliente_cnpj: string, filial_id: string): Promise<Boleto>;
    obterEstatisticasFinanceiras(cliente_cnpj: string, filial_id: string): Promise<{
        total_pendente: number;
        total_pago: number;
        total_vencido: number;
        valor_total_pendente: number;
        valor_total_pago: number;
        valor_total_vencido: number;
        proximo_vencimento: Date | null;
        boletos_vencendo_30_dias: number;
    }>;
    obterExtrato(cliente_cnpj: string, filial_id: string, dataInicio?: string, dataFim?: string): Promise<{
        boletos: Boleto[];
        resumo: {
            total_emitido: number;
            total_pago: number;
            total_pendente: number;
            total_vencido: number;
        };
    }>;
    verificarBoletosVencendo(): Promise<void>;
}
//# sourceMappingURL=FinancialService.d.ts.map