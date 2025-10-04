import { Request, Response } from 'express';
import { AuthService } from '../services/AuthService';
import { LoginCredentials, RegisterData } from '../types';
import { validationResult } from 'express-validator';

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  // POST /api/auth/login
  login = async (req: Request, res: Response): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: errors.array()
        });
        return;
      }

      const { cnpj, senha, fcm_token }: LoginCredentials & { fcm_token?: string } = req.body;
      
      const result = await this.authService.login(cnpj, senha, fcm_token);

      res.status(200).json({
        success: true,
        message: 'Login realizado com sucesso',
        data: result
      });
    } catch (error) {
      console.error('Erro no login:', error);
      
      if (error instanceof Error && error.message.includes('Credenciais inválidas')) {
        res.status(401).json({
          success: false,
          message: error.message
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/auth/register
  register = async (req: Request, res: Response): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: errors.array()
        });
        return;
      }

      const registerData: RegisterData & { fcm_token?: string } = req.body;
      
      const result = await this.authService.register(registerData);

      res.status(201).json({
        success: true,
        message: 'Usuário registrado com sucesso',
        data: result
      });
    } catch (error) {
      console.error('Erro no registro:', error);
      
      if (error instanceof Error && error.message.includes('já existe')) {
        res.status(400).json({
          success: false,
          message: error.message
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/auth/refresh-token
  refreshToken = async (req: Request, res: Response): Promise<void> => {
    try {
      const token = req.header('Authorization')?.replace('Bearer ', '');

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Token não fornecido'
        });
        return;
      }

      const result = await this.authService.refreshToken(token);

      res.status(200).json({
        success: true,
        message: 'Token renovado com sucesso',
        data: result
      });
    } catch (error) {
      console.error('Erro ao renovar token:', error);
      
      if (error instanceof Error && error.message.includes('Token')) {
        res.status(401).json({
          success: false,
          message: error.message
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/auth/logout
  logout = async (req: Request, res: Response): Promise<void> => {
    try {
      const token = req.header('Authorization')?.replace('Bearer ', '');

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Token não fornecido'
        });
        return;
      }

      await this.authService.logout(token);

      res.status(200).json({
        success: true,
        message: 'Logout realizado com sucesso'
      });
    } catch (error) {
      console.error('Erro no logout:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/auth/forgot-password
  forgotPassword = async (req: Request, res: Response): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: errors.array()
        });
        return;
      }

      const { cnpj, email } = req.body;
      
      await this.authService.forgotPassword(cnpj, email);

      res.status(200).json({
        success: true,
        message: 'Se o email estiver cadastrado, você receberá instruções para recuperação da senha'
      });
    } catch (error) {
      console.error('Erro na recuperação de senha:', error);
      
      // Sempre retornar sucesso por segurança (não revelar se email existe)
      res.status(200).json({
        success: true,
        message: 'Se o email estiver cadastrado, você receberá instruções para recuperação da senha'
      });
    }
  };

  // POST /api/auth/reset-password
  resetPassword = async (req: Request, res: Response): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: errors.array()
        });
        return;
      }

      const { token, nova_senha } = req.body;
      
      await this.authService.resetPassword(token, nova_senha);

      res.status(200).json({
        success: true,
        message: 'Senha redefinida com sucesso'
      });
    } catch (error) {
      console.error('Erro ao redefinir senha:', error);
      
      if (error instanceof Error && error.message.includes('Token')) {
        res.status(400).json({
          success: false,
          message: error.message
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // PUT /api/auth/update-fcm-token
  updateFcmToken = async (req: Request, res: Response): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: errors.array()
        });
        return;
      }

      const token = req.header('Authorization')?.replace('Bearer ', '');
      const { fcm_token } = req.body;

      if (!token) {
        res.status(401).json({
          success: false,
          message: 'Token de acesso não fornecido'
        });
        return;
      }

      await this.authService.updateFcmToken(token, fcm_token);

      res.status(200).json({
        success: true,
        message: 'Token FCM atualizado com sucesso'
      });
    } catch (error) {
      console.error('Erro ao atualizar token FCM:', error);
      
      if (error instanceof Error && error.message.includes('Token')) {
        res.status(401).json({
          success: false,
          message: error.message
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };
}