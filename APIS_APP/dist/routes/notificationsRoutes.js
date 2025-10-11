"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationsRoutes = void 0;
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const NotificationsController_1 = require("../controllers/NotificationsController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
exports.notificationsRoutes = router;
const notificationsController = new NotificationsController_1.NotificationsController();
router.use(authMiddleware_1.authMiddleware);
router.get('/', [
    (0, express_validator_1.query)('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    (0, express_validator_1.query)('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    (0, express_validator_1.query)('tipo').optional().isIn(['relatorio', 'boleto', 'inatividade', 'geral']).withMessage('Tipo de notificação inválido'),
    (0, express_validator_1.query)('lida').optional().isBoolean().withMessage('Status de leitura deve ser true ou false'),
    (0, express_validator_1.query)('dataInicio').optional().isISO8601().withMessage('Data inicial inválida'),
    (0, express_validator_1.query)('dataFim').optional().isISO8601().withMessage('Data final inválida')
], notificationsController.obterNotificacoes);
router.get('/nao-lidas', notificationsController.obterNotificacoesNaoLidas);
router.put('/:id/lida', [
    (0, express_validator_1.param)('id').isUUID().withMessage('ID da notificação inválido')
], notificationsController.marcarComoLida);
router.put('/marcar-todas-lidas', notificationsController.marcarTodasComoLidas);
router.delete('/:id', [
    (0, express_validator_1.param)('id').isUUID().withMessage('ID da notificação inválido')
], notificationsController.excluirNotificacao);
router.post('/', adminMiddleware_1.adminMiddleware, [
    (0, express_validator_1.body)('cliente_cnpj').matches(/^\d{14}$/).withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('filial_id').notEmpty().withMessage('ID da filial é obrigatório'),
    (0, express_validator_1.body)('tipo').isIn(['relatorio', 'boleto', 'inatividade', 'geral']).withMessage('Tipo de notificação inválido'),
    (0, express_validator_1.body)('titulo').isLength({ min: 1, max: 100 }).withMessage('Título deve ter entre 1 e 100 caracteres'),
    (0, express_validator_1.body)('mensagem').isLength({ min: 1, max: 500 }).withMessage('Mensagem deve ter entre 1 e 500 caracteres'),
    (0, express_validator_1.body)('enviar_push').optional().isBoolean().withMessage('enviar_push deve ser um valor booleano')
], notificationsController.criarNotificacao);
router.post('/test-push', [
    (0, express_validator_1.body)('titulo').optional().isLength({ min: 1, max: 100 }).withMessage('Título deve ter entre 1 e 100 caracteres'),
    (0, express_validator_1.body)('mensagem').optional().isLength({ min: 1, max: 500 }).withMessage('Mensagem deve ter entre 1 e 500 caracteres')
], notificationsController.testarPushNotification);
//# sourceMappingURL=notificationsRoutes.js.map