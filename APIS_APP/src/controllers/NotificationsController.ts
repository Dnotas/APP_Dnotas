import { Request, Response } from 'express';
import { NotificationService } from '../services/NotificationService';
import { NotificationFilters } from '../types';
import { validationResult } from 'express-validator';

export class NotificationsController {
  private notificationService: NotificationService;

  constructor() {
    this.notificationService = new NotificationService();
  }

  // GET /api/notifications - Obter notificações do cliente
  obterNotificacoes = async (req: Request, res: Response): Promise<void> => {
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

      const { cnpj, filial_id } = req.user!;
      const filters: NotificationFilters = {
        page: parseInt(req.query.page as string) || 1,
        limit: parseInt(req.query.limit as string) || 20,
        tipo: req.query.tipo as string,
        lida: req.query.lida === 'true' ? true : req.query.lida === 'false' ? false : undefined,
        dataInicio: req.query.dataInicio as string,
        dataFim: req.query.dataFim as string,
        sortBy: req.query.sortBy as string || 'data_envio',
        sortOrder: (req.query.sortOrder as 'ASC' | 'DESC') || 'DESC'
      };

      const result = await this.notificationService.obterNotificacoesCliente(cnpj, filial_id, filters);
      res.status(200).json(result);
    } catch (error) {
      console.error('Erro ao obter notificações:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/notifications/nao-lidas - Obter notificações não lidas
  obterNotificacoesNaoLidas = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const result = await this.notificationService.obterNotificacoesNaoLidas(cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: 'Notificações não lidas obtidas com sucesso',
        data: result
      });
    } catch (error) {
      console.error('Erro ao obter notificações não lidas:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // PUT /api/notifications/:id/lida - Marcar notificação como lida
  marcarComoLida = async (req: Request, res: Response): Promise<void> => {
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

      const { id } = req.params;
      const { cnpj, filial_id } = req.user!;

      const success = await this.notificationService.marcarComoLida(id, cnpj, filial_id);

      if (!success) {
        res.status(404).json({
          success: false,
          message: 'Notificação não encontrada'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Notificação marcada como lida'
      });
    } catch (error) {
      console.error('Erro ao marcar notificação como lida:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // PUT /api/notifications/marcar-todas-lidas - Marcar todas como lidas
  marcarTodasComoLidas = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const count = await this.notificationService.marcarTodasComoLidas(cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: `${count} notificações marcadas como lidas`,
        data: { count }
      });
    } catch (error) {
      console.error('Erro ao marcar todas as notificações como lidas:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // DELETE /api/notifications/:id - Excluir notificação
  excluirNotificacao = async (req: Request, res: Response): Promise<void> => {
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

      const { id } = req.params;
      const { cnpj, filial_id } = req.user!;

      const success = await this.notificationService.excluirNotificacao(id, cnpj, filial_id);

      if (!success) {
        res.status(404).json({
          success: false,
          message: 'Notificação não encontrada'
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Notificação excluída com sucesso'
      });
    } catch (error) {
      console.error('Erro ao excluir notificação:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/notifications - Criar notificação (apenas administradores)
  criarNotificacao = async (req: Request, res: Response): Promise<void> => {
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

      const {
        cliente_cnpj,
        filial_id,
        tipo,
        titulo,
        mensagem,
        enviar_push
      } = req.body;

      const notification = await this.notificationService.criarNotificacao({
        cliente_cnpj,
        filial_id,
        tipo,
        titulo,
        mensagem,
        enviar_push
      });

      res.status(201).json({
        success: true,
        message: 'Notificação criada com sucesso',
        data: notification
      });
    } catch (error) {
      console.error('Erro ao criar notificação:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/notifications/test-push - Testar push notification (desenvolvimento)
  testarPushNotification = async (req: Request, res: Response): Promise<void> => {
    try {
      if (process.env.NODE_ENV === 'production') {
        res.status(403).json({
          success: false,
          message: 'Endpoint disponível apenas em desenvolvimento'
        });
        return;
      }

      const { cnpj, filial_id } = req.user!;
      const { titulo, mensagem } = req.body;

      await this.notificationService.criarNotificacao({
        cliente_cnpj: cnpj,
        filial_id,
        tipo: 'geral',
        titulo: titulo || 'Teste Push Notification',
        mensagem: mensagem || 'Esta é uma notificação de teste',
        enviar_push: true
      });

      res.status(200).json({
        success: true,
        message: 'Push notification de teste enviada'
      });
    } catch (error) {
      console.error('Erro ao testar push notification:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };
}