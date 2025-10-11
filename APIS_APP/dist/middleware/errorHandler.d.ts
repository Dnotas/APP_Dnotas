import { Request, Response, NextFunction } from 'express';
interface ErrorWithStatus extends Error {
    status?: number;
    statusCode?: number;
    code?: string;
}
export declare const errorHandler: (error: ErrorWithStatus, req: Request, res: Response, next: NextFunction) => void;
export {};
//# sourceMappingURL=errorHandler.d.ts.map