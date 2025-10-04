import { Router } from 'express';
import { body, query, param } from 'express-validator';
import { ReportsController } from '../controllers/ReportsController';
import { authMiddleware } from '../middleware/authMiddleware';
import { adminMiddleware } from '../middleware/adminMiddleware';

const router = Router();
const reportsController = new ReportsController();

// Middleware de autenticação aplicado a todas as rotas
router.use(authMiddleware);

/**
 * @swagger
 * /api/reports:
 *   get:
 *     summary: Obter relatórios do cliente
 *     tags: [Relatórios]
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
 *         name: dataInicio
 *         schema:
 *           type: string
 *           format: date
 *         description: Data de início do filtro
 *       - in: query
 *         name: dataFim
 *         schema:
 *           type: string
 *           format: date
 *         description: Data de fim do filtro
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [data_relatorio, total_vendas]
 *         description: Campo para ordenação
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *         description: Ordem da classificação
 *     responses:
 *       200:
 *         description: Relatórios obtidos com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/', 
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    query('dataInicio').optional().isISO8601().withMessage('Data de início inválida'),
    query('dataFim').optional().isISO8601().withMessage('Data de fim inválida'),
    query('sortBy').optional().isIn(['data_relatorio', 'total_vendas']).withMessage('Campo de ordenação inválido'),
    query('sortOrder').optional().isIn(['ASC', 'DESC']).withMessage('Ordem deve ser ASC ou DESC')
  ],
  reportsController.obterRelatorios
);

/**
 * @swagger
 * /api/reports/hoje:
 *   get:
 *     summary: Obter relatório do dia atual
 *     tags: [Relatórios]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Relatório do dia obtido com sucesso
 *       404:
 *         description: Nenhum relatório encontrado para hoje
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/hoje', reportsController.obterRelatorioHoje);

/**
 * @swagger
 * /api/reports/estatisticas:
 *   get:
 *     summary: Obter estatísticas de vendas
 *     tags: [Relatórios]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: dias
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 365
 *         description: Número de dias para calcular estatísticas (padrão 30)
 *     responses:
 *       200:
 *         description: Estatísticas obtidas com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.get('/estatisticas',
  [
    query('dias').optional().isInt({ min: 1, max: 365 }).withMessage('Dias deve ser entre 1 e 365')
  ],
  reportsController.obterEstatisticas
);

/**
 * @swagger
 * /api/reports:
 *   post:
 *     summary: Criar novo relatório (apenas administradores)
 *     tags: [Relatórios]
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
 *               - data_relatorio
 *               - vendas_debito
 *               - vendas_credito
 *               - vendas_dinheiro
 *               - vendas_pix
 *               - vendas_vale
 *             properties:
 *               cliente_cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *               filial_id:
 *                 type: string
 *               data_relatorio:
 *                 type: string
 *                 format: date
 *               vendas_debito:
 *                 type: number
 *                 minimum: 0
 *               vendas_credito:
 *                 type: number
 *                 minimum: 0
 *               vendas_dinheiro:
 *                 type: number
 *                 minimum: 0
 *               vendas_pix:
 *                 type: number
 *                 minimum: 0
 *               vendas_vale:
 *                 type: number
 *                 minimum: 0
 *     responses:
 *       201:
 *         description: Relatório criado com sucesso
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
    body('data_relatorio').isISO8601().withMessage('Data do relatório inválida'),
    body('vendas_debito').isFloat({ min: 0 }).withMessage('Vendas débito deve ser um valor positivo'),
    body('vendas_credito').isFloat({ min: 0 }).withMessage('Vendas crédito deve ser um valor positivo'),
    body('vendas_dinheiro').isFloat({ min: 0 }).withMessage('Vendas dinheiro deve ser um valor positivo'),
    body('vendas_pix').isFloat({ min: 0 }).withMessage('Vendas PIX deve ser um valor positivo'),
    body('vendas_vale').isFloat({ min: 0 }).withMessage('Vendas vale deve ser um valor positivo')
  ],
  reportsController.criarRelatorio
);

/**
 * @swagger
 * /api/reports/{id}:
 *   put:
 *     summary: Atualizar relatório
 *     tags: [Relatórios]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do relatório
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               vendas_debito:
 *                 type: number
 *                 minimum: 0
 *               vendas_credito:
 *                 type: number
 *                 minimum: 0
 *               vendas_dinheiro:
 *                 type: number
 *                 minimum: 0
 *               vendas_pix:
 *                 type: number
 *                 minimum: 0
 *               vendas_vale:
 *                 type: number
 *                 minimum: 0
 *     responses:
 *       200:
 *         description: Relatório atualizado com sucesso
 *       400:
 *         description: Dados inválidos
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Relatório não encontrado
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/:id',
  [
    param('id').isUUID().withMessage('ID do relatório inválido'),
    body('vendas_debito').optional().isFloat({ min: 0 }).withMessage('Vendas débito deve ser um valor positivo'),
    body('vendas_credito').optional().isFloat({ min: 0 }).withMessage('Vendas crédito deve ser um valor positivo'),
    body('vendas_dinheiro').optional().isFloat({ min: 0 }).withMessage('Vendas dinheiro deve ser um valor positivo'),
    body('vendas_pix').optional().isFloat({ min: 0 }).withMessage('Vendas PIX deve ser um valor positivo'),
    body('vendas_vale').optional().isFloat({ min: 0 }).withMessage('Vendas vale deve ser um valor positivo')
  ],
  reportsController.atualizarRelatorio
);

/**
 * @swagger
 * /api/reports/{id}:
 *   delete:
 *     summary: Excluir relatório
 *     tags: [Relatórios]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do relatório
 *     responses:
 *       200:
 *         description: Relatório excluído com sucesso
 *       401:
 *         description: Token de acesso inválido
 *       404:
 *         description: Relatório não encontrado
 *       500:
 *         description: Erro interno do servidor
 */
router.delete('/:id',
  [
    param('id').isUUID().withMessage('ID do relatório inválido')
  ],
  reportsController.excluirRelatorio
);

export { router as reportsRoutes };