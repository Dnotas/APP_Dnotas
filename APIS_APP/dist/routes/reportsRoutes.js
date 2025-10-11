"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reportsRoutes = void 0;
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const ReportsController_1 = require("../controllers/ReportsController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
exports.reportsRoutes = router;
const reportsController = new ReportsController_1.ReportsController();
router.use(authMiddleware_1.authMiddleware);
router.get('/', [
    (0, express_validator_1.query)('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    (0, express_validator_1.query)('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    (0, express_validator_1.query)('dataInicio').optional().isISO8601().withMessage('Data de início inválida'),
    (0, express_validator_1.query)('dataFim').optional().isISO8601().withMessage('Data de fim inválida'),
    (0, express_validator_1.query)('sortBy').optional().isIn(['data_relatorio', 'total_vendas']).withMessage('Campo de ordenação inválido'),
    (0, express_validator_1.query)('sortOrder').optional().isIn(['ASC', 'DESC']).withMessage('Ordem deve ser ASC ou DESC')
], reportsController.obterRelatorios);
router.get('/hoje', reportsController.obterRelatorioHoje);
router.get('/estatisticas', [
    (0, express_validator_1.query)('dias').optional().isInt({ min: 1, max: 365 }).withMessage('Dias deve ser entre 1 e 365')
], reportsController.obterEstatisticas);
router.post('/', adminMiddleware_1.adminMiddleware, [
    (0, express_validator_1.body)('cliente_cnpj').matches(/^\d{14}$/).withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('filial_id').notEmpty().withMessage('ID da filial é obrigatório'),
    (0, express_validator_1.body)('data_relatorio').isISO8601().withMessage('Data do relatório inválida'),
    (0, express_validator_1.body)('vendas_debito').isFloat({ min: 0 }).withMessage('Vendas débito deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_credito').isFloat({ min: 0 }).withMessage('Vendas crédito deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_dinheiro').isFloat({ min: 0 }).withMessage('Vendas dinheiro deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_pix').isFloat({ min: 0 }).withMessage('Vendas PIX deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_vale').isFloat({ min: 0 }).withMessage('Vendas vale deve ser um valor positivo')
], reportsController.criarRelatorio);
router.put('/:id', [
    (0, express_validator_1.param)('id').isUUID().withMessage('ID do relatório inválido'),
    (0, express_validator_1.body)('vendas_debito').optional().isFloat({ min: 0 }).withMessage('Vendas débito deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_credito').optional().isFloat({ min: 0 }).withMessage('Vendas crédito deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_dinheiro').optional().isFloat({ min: 0 }).withMessage('Vendas dinheiro deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_pix').optional().isFloat({ min: 0 }).withMessage('Vendas PIX deve ser um valor positivo'),
    (0, express_validator_1.body)('vendas_vale').optional().isFloat({ min: 0 }).withMessage('Vendas vale deve ser um valor positivo')
], reportsController.atualizarRelatorio);
router.delete('/:id', [
    (0, express_validator_1.param)('id').isUUID().withMessage('ID do relatório inválido')
], reportsController.excluirRelatorio);
//# sourceMappingURL=reportsRoutes.js.map