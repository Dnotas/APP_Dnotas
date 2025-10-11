import { Request, Response } from 'express';
export declare class FinancialController {
    private financialService;
    constructor();
    obterBoletos: (req: Request, res: Response) => Promise<void>;
    obterBoletosPendentes: (req: Request, res: Response) => Promise<void>;
    obterEstatisticas: (req: Request, res: Response) => Promise<void>;
    obterExtrato: (req: Request, res: Response) => Promise<void>;
    criarBoleto: (req: Request, res: Response) => Promise<void>;
    marcarBoletoPago: (req: Request, res: Response) => Promise<void>;
    cancelarBoleto: (req: Request, res: Response) => Promise<void>;
    obterBoletosVencidos: (req: Request, res: Response) => Promise<void>;
}
//# sourceMappingURL=FinancialController.d.ts.map