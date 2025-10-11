"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.financialRoutes = void 0;
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const FinancialController_1 = require("../controllers/FinancialController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
exports.financialRoutes = router;
const financialController = new FinancialController_1.FinancialController();
router.use(authMiddleware_1.authMiddleware);
router.get('/boletos', [
    (0, express_validator_1.query)('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número positivo'),
    (0, express_validator_1.query)('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    (0, express_validator_1.query)('status').optional().isIn(['pendente', 'pago', 'vencido', 'cancelado']).withMessage('Status inválido'),
    (0, express_validator_1.query)('dataVencimentoInicio').optional().isISO8601().withMessage('Data de vencimento inicial inválida'),
    (0, express_validator_1.query)('dataVencimentoFim').optional().isISO8601().withMessage('Data de vencimento final inválida')
], financialController.obterBoletos);
router.get('/boletos/pendentes', financialController.obterBoletosPendentes);
router.get('/boletos/vencidos', financialController.obterBoletosVencidos);
router.get('/estatisticas', financialController.obterEstatisticas);
router.get('/extrato', [
    (0, express_validator_1.query)('dataInicio').optional().isISO8601().withMessage('Data inicial inválida'),
    (0, express_validator_1.query)('dataFim').optional().isISO8601().withMessage('Data final inválida')
], financialController.obterExtrato);
router.post('/boletos', adminMiddleware_1.adminMiddleware, [
    (0, express_validator_1.body)('cliente_cnpj').matches(/^\d{14}$/).withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('filial_id').notEmpty().withMessage('ID da filial é obrigatório'),
    (0, express_validator_1.body)('numero_boleto').notEmpty().withMessage('Número do boleto é obrigatório'),
    (0, express_validator_1.body)('valor').isFloat({ min: 0.01 }).withMessage('Valor deve ser maior que zero'),
    (0, express_validator_1.body)('data_vencimento').isISO8601().withMessage('Data de vencimento inválida'),
    (0, express_validator_1.body)('linha_digitavel').notEmpty().withMessage('Linha digitável é obrigatória'),
    (0, express_validator_1.body)('codigo_barras').notEmpty().withMessage('Código de barras é obrigatório')
], financialController.criarBoleto);
router.put('/boletos/:numero/pagar', [
    (0, express_validator_1.param)('numero').notEmpty().withMessage('Número do boleto é obrigatório'),
    (0, express_validator_1.body)('data_pagamento').optional().isISO8601().withMessage('Data de pagamento inválida')
], financialController.marcarBoletoPago);
router.put('/boletos/:numero/cancelar', [
    (0, express_validator_1.param)('numero').notEmpty().withMessage('Número do boleto é obrigatório')
], financialController.cancelarBoleto);
//# sourceMappingURL=financialRoutes.js.map