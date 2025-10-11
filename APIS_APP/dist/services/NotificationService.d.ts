import { Notification, RelatorioVendas, Boleto, NotificationFilters, ApiResponse } from '../types';
export declare class NotificationService {
    private db;
    private firebase;
    constructor();
    criarNotificacao(data: {
        cliente_cnpj: string;
        filial_id: string;
        tipo: 'relatorio' | 'boleto' | 'inatividade' | 'geral';
        titulo: string;
        mensagem: string;
        enviar_push?: boolean;
    }): Promise<Notification>;
    enviarNotificacaoRelatorio(cliente_cnpj: string, filial_id: string, relatorio: RelatorioVendas): Promise<void>;
    enviarNotificacaoBoleto(cliente_cnpj: string, filial_id: string, boleto: Boleto): Promise<void>;
    enviarNotificacaoVencimento(cliente_cnpj: string, filial_id: string, quantidade: number): Promise<void>;
    enviarNotificacaoInatividade(cliente_cnpj: string, filial_id: string, dias: number): Promise<void>;
    obterNotificacoesCliente(cliente_cnpj: string, filial_id: string, filters?: NotificationFilters): Promise<ApiResponse<Notification[]>>;
    obterNotificacoesNaoLidas(cliente_cnpj: string, filial_id: string): Promise<{
        total: number;
        notificacoes: Notification[];
    }>;
    marcarComoLida(id: string, cliente_cnpj: string, filial_id: string): Promise<boolean>;
    marcarTodasComoLidas(cliente_cnpj: string, filial_id: string): Promise<number>;
    excluirNotificacao(id: string, cliente_cnpj: string, filial_id: string): Promise<boolean>;
    private enviarPushNotification;
    verificarClientesInativos(): Promise<void>;
    limparNotificacoesAntigas(diasAntigos?: number): Promise<number>;
}
//# sourceMappingURL=NotificationService.d.ts.map