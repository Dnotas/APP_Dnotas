export declare class FirebaseService {
    private static instance;
    private app;
    private constructor();
    static getInstance(): FirebaseService;
    enviarNotificacao(token: string, titulo: string, mensagem: string, dados?: Record<string, string>): Promise<void>;
    enviarNotificacaoMultipla(tokens: string[], titulo: string, mensagem: string, dados?: Record<string, string>): Promise<{
        successCount: number;
        failureCount: number;
        failedTokens: string[];
    }>;
    verificarTokenValido(token: string): Promise<boolean>;
    criarTopico(topico: string, tokens: string[]): Promise<void>;
    removerDoTopico(topico: string, tokens: string[]): Promise<void>;
    enviarParaTopico(topico: string, titulo: string, mensagem: string, dados?: Record<string, string>): Promise<void>;
}
//# sourceMappingURL=FirebaseService.d.ts.map