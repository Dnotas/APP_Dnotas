import { Request, Response, NextFunction } from 'express';
import { User } from '../types';
interface AuthenticatedRequest extends Request {
    user?: User;
}
export declare const adminMiddleware: (req: AuthenticatedRequest, res: Response, next: NextFunction) => void;
export {};
//# sourceMappingURL=adminMiddleware.d.ts.map