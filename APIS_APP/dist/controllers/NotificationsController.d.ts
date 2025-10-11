import { Request, Response } from 'express';
export declare class NotificationsController {
    private notificationService;
    constructor();
    obterNotificacoes: (req: Request, res: Response) => Promise<void>;
    obterNotificacoesNaoLidas: (req: Request, res: Response) => Promise<void>;
    marcarComoLida: (req: Request, res: Response) => Promise<void>;
    marcarTodasComoLidas: (req: Request, res: Response) => Promise<void>;
    excluirNotificacao: (req: Request, res: Response) => Promise<void>;
    criarNotificacao: (req: Request, res: Response) => Promise<void>;
    testarPushNotification: (req: Request, res: Response) => Promise<void>;
}
//# sourceMappingURL=NotificationsController.d.ts.map