import { Request, Response, NextFunction } from 'express';
import { User } from '../types';
interface AuthenticatedRequest extends Request {
    user?: User;
}
export declare const authMiddleware: (req: AuthenticatedRequest, res: Response, next: NextFunction) => Promise<void>;
export {};
//# sourceMappingURL=authMiddleware.d.ts.map