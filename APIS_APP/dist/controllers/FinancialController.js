"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FinancialController = void 0;
const FinancialService_1 = require("../services/FinancialService");
const express_validator_1 = require("express-validator");
class FinancialController {
    constructor() {
        this.obterBoletos = async (req, res) => {
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
                    limit: parseInt(req.query.limit) || 10,
                    status: req.query.status,
                    dataVencimentoInicio: req.query.dataVencimentoInicio,
                    dataVencimentoFim: req.query.dataVencimentoFim,
                    sortBy: req.query.sortBy || 'data_vencimento',
                    sortOrder: req.query.sortOrder || 'ASC'
                };
                const result = await this.financialService.obterBoletosCliente(cnpj, filial_id, filters);
                res.status(200).json(result);
            }
            catch (error) {
                console.error('Erro ao obter boletos:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterBoletosPendentes = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const boletos = await this.financialService.obterBoletosPendentes(cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: 'Boletos pendentes obtidos com sucesso',
                    data: boletos
                });
            }
            catch (error) {
                console.error('Erro ao obter boletos pendentes:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterEstatisticas = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const estatisticas = await this.financialService.obterEstatisticasFinanceiras(cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: 'Estatísticas financeiras obtidas com sucesso',
                    data: estatisticas
                });
            }
            catch (error) {
                console.error('Erro ao obter estatísticas financeiras:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterExtrato = async (req, res) => {
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
                const { dataInicio, dataFim } = req.query;
                const extrato = await this.financialService.obterExtrato(cnpj, filial_id, dataInicio, dataFim);
                res.status(200).json({
                    success: true,
                    message: 'Extrato obtido com sucesso',
                    data: extrato
                });
            }
            catch (error) {
                console.error('Erro ao obter extrato:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.criarBoleto = async (req, res) => {
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
                const { cliente_cnpj, filial_id, numero_boleto, valor, data_vencimento, linha_digitavel, codigo_barras } = req.body;
                const boleto = await this.financialService.criarBoleto({
                    cliente_cnpj,
                    filial_id,
                    numero_boleto,
                    valor: parseFloat(valor),
                    data_vencimento: new Date(data_vencimento),
                    linha_digitavel,
                    codigo_barras
                });
                res.status(201).json({
                    success: true,
                    message: 'Boleto criado com sucesso',
                    data: boleto
                });
            }
            catch (error) {
                console.error('Erro ao criar boleto:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.marcarBoletoPago = async (req, res) => {
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
                const { numero } = req.params;
                const { cnpj, filial_id } = req.user;
                const { data_pagamento } = req.body;
                const boleto = await this.financialService.marcarBoletoPago(numero, cnpj, filial_id, data_pagamento ? new Date(data_pagamento) : undefined);
                res.status(200).json({
                    success: true,
                    message: 'Boleto marcado como pago com sucesso',
                    data: boleto
                });
            }
            catch (error) {
                console.error('Erro ao marcar boleto como pago:', error);
                if (error instanceof Error && error.message.includes('não encontrado')) {
                    res.status(404).json({
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
        this.cancelarBoleto = async (req, res) => {
            try {
                const { numero } = req.params;
                const { cnpj, filial_id } = req.user;
                const boleto = await this.financialService.cancelarBoleto(numero, cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: 'Boleto cancelado com sucesso',
                    data: boleto
                });
            }
            catch (error) {
                console.error('Erro ao cancelar boleto:', error);
                if (error instanceof Error && error.message.includes('não encontrado')) {
                    res.status(404).json({
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
        this.obterBoletosVencidos = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const boletosVencidos = await this.financialService.obterBoletosVencidos(cnpj, filial_id);
                res.status(200).json({
                    success: true,
                    message: 'Boletos vencidos obtidos com sucesso',
                    data: boletosVencidos
                });
            }
            catch (error) {
                console.error('Erro ao obter boletos vencidos:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.financialService = new FinancialService_1.FinancialService();
    }
}
exports.FinancialController = FinancialController;
//# sourceMappingURL=FinancialController.js.map