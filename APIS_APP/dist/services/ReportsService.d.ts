import { RelatorioVendas, RelatorioFilters, ApiResponse } from '../types';
export declare class ReportsService {
    private db;
    private notificationService;
    constructor();
    criarRelatorioVendas(data: {
        cliente_cnpj: string;
        filial_id: string;
        data_relatorio: Date;
        vendas_debito: number;
        vendas_credito: number;
        vendas_dinheiro: number;
        vendas_pix: number;
        vendas_vale: number;
    }): Promise<RelatorioVendas>;
    obterRelatoriosCliente(cliente_cnpj: string, filial_id: string, filters?: RelatorioFilters): Promise<ApiResponse<RelatorioVendas[]>>;
    obterRelatorioHoje(cliente_cnpj: string, filial_id: string): Promise<RelatorioVendas | null>;
    obterEstatisticasVendas(cliente_cnpj: string, filial_id: string, dias?: number): Promise<{
        total_periodo: number;
        media_diaria: number;
        maior_venda: number;
        menor_venda: number;
        vendas_por_tipo: {
            debito: number;
            credito: number;
            dinheiro: number;
            pix: number;
            vale: number;
        };
    }>;
    atualizarRelatorioVendas(id: string, cliente_cnpj: string, filial_id: string, data: Partial<RelatorioVendas>): Promise<RelatorioVendas>;
    excluirRelatorio(id: string, cliente_cnpj: string, filial_id: string): Promise<boolean>;
}
//# sourceMappingURL=ReportsService.d.ts.map