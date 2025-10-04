import { Router } from 'express';
import { body, query, param } from 'express-validator';
import { FinancialController } from '../controllers/FinancialController';
import { authMiddleware } from '../middleware/authMiddleware';
import { adminMiddleware } from '../middleware/adminMiddleware';

const router = Router();
const financialController = new FinancialController();

// Middleware de autenticação aplicado a todas as rotas
router.use(authMiddleware);

/**
 * @swagger
 * /api/financial/boletos:
 *   get:
 *     summary: Obter boletos do cliente
 *     tags: [Financeiro]
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
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pendente, pago, vencido, cancelado]
 *         description: Filtro por status do boleto
 *       - in: query
 *         name: dataVencimentoInicio
 *         schema:
 *           type: string
 *           format: date
 *         description: Data inicial do vencimento
 *       - in: query
 *         name: dataVencimentoFim
 *         schema:
 *           type: string
 *           format: date
 *         description: Data final do vencimento
 *     responses:
 *       200:
 *         description: Boletos obtidos com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/boletos',
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    query('status').optional().isIn(['pendente', 'pago', 'vencido', 'cancelado']).withMessage('Status inválido'),
    query('dataVencimentoInicio').optional().isISO8601().withMessage('Data de vencimento inicial inválida'),
    query('dataVencimentoFim').optional().isISO8601().withMessage('Data de vencimento final inválida')
  ],
  financialController.obterBoletos
);

/**
 * @swagger
 * /api/financial/boletos/pendentes:
 *   get:
 *     summary: Obter boletos pendentes do cliente
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Boletos pendentes obtidos com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/boletos/pendentes', financialController.obterBoletosPendentes);

/**
 * @swagger
 * /api/financial/boletos/vencidos:
 *   get:
 *     summary: Verificar e obter boletos vencidos
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Boletos vencidos obtidos com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/boletos/vencidos', financialController.obterBoletosVencidos);

/**
 * @swagger
 * /api/financial/estatisticas:
 *   get:
 *     summary: Obter estatísticas financeiras do cliente
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Estatísticas obtidas com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/estatisticas', financialController.obterEstatisticas);

/**
 * @swagger
 * /api/financial/extrato:
 *   get:
 *     summary: Obter extrato financeiro
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: dataInicio
 *         schema:
 *           type: string
 *           format: date
 *         description: Data inicial do extrato
 *       - in: query
 *         name: dataFim
 *         schema:
 *           type: string
 *           format: date
 *         description: Data final do extrato
 *     responses:
 *       200:
 *         description: Extrato obtido com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/extrato',
  [
    query('dataInicio').optional().isISO8601().withMessage('Data inicial inválida'),
    query('dataFim').optional().isISO8601().withMessage('Data final inválida')
  ],
  financialController.obterExtrato
);

/**
 * @swagger
 * /api/financial/boletos:
 *   post:
 *     summary: Criar novo boleto (apenas administradores)
 *     tags: [Financeiro]
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
 *               - numero_boleto
 *               - valor
 *               - data_vencimento
 *               - linha_digitavel
 *               - codigo_barras
 *             properties:
 *               cliente_cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *               filial_id:
 *                 type: string
 *               numero_boleto:
 *                 type: string
 *               valor:
 *                 type: number
 *                 minimum: 0.01
 *               data_vencimento:
 *                 type: string
 *                 format: date
 *               linha_digitavel:
 *                 type: string
 *               codigo_barras:
 *                 type: string
 *     responses:
 *       201:
 *         description: Boleto criado com sucesso
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Token de acesso inválido
 *       403:
 *         description: Acesso negado - apenas administradores
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/boletos',
  adminMiddleware,
  [
    body('cliente_cnpj').matches(/^\d{14}$/).withMessage('CNPJ deve conter exatamente 14 dígitos'),
    body('filial_id').notEmpty().withMessage('ID da filial é obrigatório'),
    body('numero_boleto').notEmpty().withMessage('Número do boleto é obrigatório'),
    body('valor').isFloat({ min: 0.01 }).withMessage('Valor deve ser maior que zero'),
    body('data_vencimento').isISO8601().withMessage('Data de vencimento inválida'),
    body('linha_digitavel').notEmpty().withMessage('Linha digitável é obrigatória'),
    body('codigo_barras').notEmpty().withMessage('Código de barras é obrigatório')
  ],
  financialController.criarBoleto
);

/**
 * @swagger
 * /api/financial/boletos/{numero}/pagar:
 *   put:
 *     summary: Marcar boleto como pago
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: numero
 *         required: true
 *         schema:
 *           type: string
 *         description: Número do boleto
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               data_pagamento:
 *                 type: string
 *                 format: date-time
 *                 description: Data do pagamento (se não informada, será usada a data atual)
 *     responses:
 *       200:
 *         description: Boleto marcado como pago com sucesso
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Boleto não encontrado
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/boletos/:numero/pagar',
  [
    param('numero').notEmpty().withMessage('Número do boleto é obrigatório'),
    body('data_pagamento').optional().isISO8601().withMessage('Data de pagamento inválida')
  ],
  financialController.marcarBoletoPago
);

/**
 * @swagger
 * /api/financial/boletos/{numero}/cancelar:
 *   put:
 *     summary: Cancelar boleto
 *     tags: [Financeiro]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: numero
 *         required: true
 *         schema:
 *           type: string
 *         description: Número do boleto
 *     responses:
 *       200:
 *         description: Boleto cancelado com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Boleto não encontrado
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/boletos/:numero/cancelar',
  [
    param('numero').notEmpty().withMessage('Número do boleto é obrigatório')
  ],
  financialController.cancelarBoleto
);

export { router as financialRoutes };