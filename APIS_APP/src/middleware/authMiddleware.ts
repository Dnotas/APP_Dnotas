import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { DatabaseService } from '../services/DatabaseService';
import { User } from '../types';

interface AuthenticatedRequest extends Request {
  user?: User;
}

export const authMiddleware = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      res.status(401).json({
        success: false,
        message: 'Token de acesso não fornecido'
      });
      return;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      throw new Error('JWT_SECRET não configurado');
    }

    const decoded = jwt.verify(token, jwtSecret) as any;
    const db = DatabaseService.getInstance();

    // Buscar o usuário no banco de dados
    const query = `
      SELECT u.*, f.nome as filial_nome 
      FROM users u
      JOIN filiais f ON u.filial_id = f.id
      WHERE u.id = $1 AND u.ativo = true
    `;

    const result = await db.query<User>(query, [decoded.userId]);

    if (result.rows.length === 0) {
      res.status(401).json({
        success: false,
        message: 'Usuário não encontrado ou inativo'
      });
      return;
    }

    const user = result.rows[0];

    // Atualizar último acesso
    await db.query(
      'UPDATE users SET ultimo_acesso = CURRENT_TIMESTAMP WHERE id = $1',
      [user.id]
    );

    req.user = user;
    next();
  } catch (error) {
    console.error('Erro na autenticação:', error);
    
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({
        success: false,
        message: 'Token inválido'
      });
      return;
    }

    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        success: false,
        message: 'Token expirado'
      });
      return;
    }

    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor'
    });
  }
};