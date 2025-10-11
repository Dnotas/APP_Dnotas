import { Request, Response } from 'express';
export declare class ReportsController {
    private reportsService;
    constructor();
    obterRelatorios: (req: Request, res: Response) => Promise<void>;
    obterRelatorioHoje: (req: Request, res: Response) => Promise<void>;
    obterEstatisticas: (req: Request, res: Response) => Promise<void>;
    criarRelatorio: (req: Request, res: Response) => Promise<void>;
    atualizarRelatorio: (req: Request, res: Response) => Promise<void>;
    excluirRelatorio: (req: Request, res: Response) => Promise<void>;
}
//# sourceMappingURL=ReportsController.d.ts.map