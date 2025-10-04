import { Request, Response, NextFunction } from 'express';
import { User } from '../types';

interface AuthenticatedRequest extends Request {
  user?: User;
}

export const adminMiddleware = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Usuário não autenticado'
      });
      return;
    }

    // Verificar se o usuário tem permissão de administrador
    // Aqui você pode implementar a lógica específica para verificar se é admin
    // Por exemplo, verificar uma coluna 'role' ou 'is_admin' na tabela users
    
    // Para agora, vamos considerar que usuários da matriz são admins
    // Você pode ajustar esta lógica conforme necessário
    const isAdmin = req.user.filial_id === 'matriz' || req.headers['x-admin-key'] === process.env.ADMIN_KEY;

    if (!isAdmin) {
      res.status(403).json({
        success: false,
        message: 'Acesso negado - privilégios de administrador necessários'
      });
      return;
    }

    next();
  } catch (error) {
    console.error('Erro na verificação de administrador:', error);
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor'
    });
  }
};