"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsController = void 0;
const NotificationService_1 = require("../services/NotificationService");
const express_validator_1 = require("express-validator");
class NotificationsController {
    constructor() {
        this.obterNotificacoes = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { cnpj, filial_id } = req.user;
                const filters = {
                    page: parseInt(req.query.page) || 1,
                    limit: parseInt(req.query.limit) || 20,
                    tipo: req.query.tipo,
                    lida: req.query.lida === 'true' ? true : req.query.lida === 'false' ? false : undefined,
                    dataInicio: req.query.dataInicio,
                    dataFim: req.query.dataFim,
                    sortBy: req.query.sortBy || 'data_envio',
                    sortOrder: req.query.sortOrder || 'DESC'
                };
                const result = await this.notificationService.obterNotificacoesCliente(cnpj, filial_id, filters);
                res.status(200).json(result);
            }
            catch (error) {
                console.error('Erro ao obter notificações:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterNotificacoesNaoLidas = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const result = await this.notificationService.obterNotificacoesNaoLidas(cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: 'Notificações não lidas obtidas com sucesso',
                    data: result
                });
            }
            catch (error) {
                console.error('Erro ao obter notificações não lidas:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.marcarComoLida = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { id } = req.params;
                const { cnpj, filial_id } = req.user;
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
            }
            catch (error) {
                console.error('Erro ao marcar notificação como lida:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.marcarTodasComoLidas = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const count = await this.notificationService.marcarTodasComoLidas(cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: `${count} notificações marcadas como lidas`,
                    data: { count }
                });
            }
            catch (error) {
                console.error('Erro ao marcar todas as notificações como lidas:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.excluirNotificacao = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { id } = req.params;
                const { cnpj, filial_id } = req.user;
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
            }
            catch (error) {
                console.error('Erro ao excluir notificação:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.criarNotificacao = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { cliente_cnpj, filial_id, tipo, titulo, mensagem, enviar_push } = req.body;
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
            }
            catch (error) {
                console.error('Erro ao criar notificação:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.testarPushNotification = async (req, res) => {
            try {
                if (process.env.NODE_ENV === 'production') {
                    res.status(403).json({
                        success: false,
                        message: 'Endpoint disponível apenas em desenvolvimento'
                    });
                    return;
                }
                const { cnpj, filial_id } = req.user;
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
            }
            catch (error) {
                console.error('Erro ao testar push notification:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.notificationService = new NotificationService_1.NotificationService();
    }
}
exports.NotificationsController = NotificationsController;
//# sourceMappingURL=NotificationsController.js.map