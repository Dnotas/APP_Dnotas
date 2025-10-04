import { Router } from 'express';
import { body, query, param } from 'express-validator';
import { NotificationsController } from '../controllers/NotificationsController';
import { authMiddleware } from '../middleware/authMiddleware';
import { adminMiddleware } from '../middleware/adminMiddleware';

const router = Router();
const notificationsController = new NotificationsController();

// Middleware de autenticação aplicado a todas as rotas
router.use(authMiddleware);

/**
 * @swagger
 * /api/notifications:
 *   get:
 *     summary: Obter notificações do cliente
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *         description: Número da página
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *         description: Limite de itens por página
 *       - in: query
 *         name: tipo
 *         schema:
 *           type: string
 *           enum: [relatorio, boleto, inatividade, geral]
 *         description: Filtro por tipo de notificação
 *       - in: query
 *         name: lida
 *         schema:
 *           type: boolean
 *         description: Filtro por status de leitura
 *       - in: query
 *         name: dataInicio
 *         schema:
 *           type: string
 *           format: date
 *         description: Data inicial do filtro
 *       - in: query
 *         name: dataFim
 *         schema:
 *           type: string
 *           format: date
 *         description: Data final do filtro
 *     responses:
 *       200:
 *         description: Notificações obtidas com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/',
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    query('tipo').optional().isIn(['relatorio', 'boleto', 'inatividade', 'geral']).withMessage('Tipo de notificação inválido'),
    query('lida').optional().isBoolean().withMessage('Status de leitura deve ser true ou false'),
    query('dataInicio').optional().isISO8601().withMessage('Data inicial inválida'),
    query('dataFim').optional().isISO8601().withMessage('Data final inválida')
  ],
  notificationsController.obterNotificacoes
);

/**
 * @swagger
 * /api/notifications/nao-lidas:
 *   get:
 *     summary: Obter notificações não lidas
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Notificações não lidas obtidas com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/nao-lidas', notificationsController.obterNotificacoesNaoLidas);

/**
 * @swagger
 * /api/notifications/{id}/lida:
 *   put:
 *     summary: Marcar notificação como lida
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID da notificação
 *     responses:
 *       200:
 *         description: Notificação marcada como lida
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Notificação não encontrada
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/:id/lida',
  [
    param('id').isUUID().withMessage('ID da notificação inválido')
  ],
  notificationsController.marcarComoLida
);

/**
 * @swagger
 * /api/notifications/marcar-todas-lidas:
 *   put:
 *     summary: Marcar todas as notificações como lidas
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Todas as notificações marcadas como lidas
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/marcar-todas-lidas', notificationsController.marcarTodasComoLidas);

/**
 * @swagger
 * /api/notifications/{id}:
 *   delete:
 *     summary: Excluir notificação
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID da notificação
 *     responses:
 *       200:
 *         description: Notificação excluída com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Notificação não encontrada
 *       500:
 *         description: Erro interno do servidor
 */
router.delete('/:id',
  [
    param('id').isUUID().withMessage('ID da notificação inválido')
  ],
  notificationsController.excluirNotificacao
);

/**
 * @swagger
 * /api/notifications:
 *   post:
 *     summary: Criar nova notificação (apenas administradores)
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cliente_cnpj
 *               - filial_id
 *               - tipo
 *               - titulo
 *               - mensagem
 *             properties:
 *               cliente_cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *               filial_id:
 *                 type: string
 *               tipo:
 *                 type: string
 *                 enum: [relatorio, boleto, inatividade, geral]
 *               titulo:
 *                 type: string
 *                 minLength: 1
 *                 maxLength: 100
 *               mensagem:
 *                 type: string
 *                 minLength: 1
 *                 maxLength: 500
 *               enviar_push:
 *                 type: boolean
 *                 description: Se deve enviar push notification (padrão true)
 *     responses:
 *       201:
 *         description: Notificação criada com sucesso
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Token de acesso inválido
 *       403:
 *         description: Acesso negado - apenas administradores
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/',
  adminMiddleware,
  [
    body('cliente_cnpj').matches(/^\d{14}$/).withMessage('CNPJ deve conter exatamente 14 dígitos'),
    body('filial_id').notEmpty().withMessage('ID da filial é obrigatório'),
    body('tipo').isIn(['relatorio', 'boleto', 'inatividade', 'geral']).withMessage('Tipo de notificação inválido'),
    body('titulo').isLength({ min: 1, max: 100 }).withMessage('Título deve ter entre 1 e 100 caracteres'),
    body('mensagem').isLength({ min: 1, max: 500 }).withMessage('Mensagem deve ter entre 1 e 500 caracteres'),
    body('enviar_push').optional().isBoolean().withMessage('enviar_push deve ser um valor booleano')
  ],
  notificationsController.criarNotificacao
);

/**
 * @swagger
 * /api/notifications/test-push:
 *   post:
 *     summary: Testar push notification (apenas em desenvolvimento)
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               titulo:
 *                 type: string
 *               mensagem:
 *                 type: string
 *     responses:
 *       200:
 *         description: Push notification de teste enviada
 *       401:
 *         description: Token de acesso inválido
 *       403:
 *         description: Endpoint disponível apenas em desenvolvimento
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/test-push',
  [
    body('titulo').optional().isLength({ min: 1, max: 100 }).withMessage('Título deve ter entre 1 e 100 caracteres'),
    body('mensagem').optional().isLength({ min: 1, max: 500 }).withMessage('Mensagem deve ter entre 1 e 500 caracteres')
  ],
  notificationsController.testarPushNotification
);

export { router as notificationsRoutes };