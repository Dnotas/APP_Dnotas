"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportsController = void 0;
const ReportsService_1 = require("../services/ReportsService");
const express_validator_1 = require("express-validator");
class ReportsController {
    constructor() {
        this.obterRelatorios = async (req, res) => {
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
                    dataInicio: req.query.dataInicio,
                    dataFim: req.query.dataFim,
                    sortBy: req.query.sortBy || 'data_relatorio',
                    sortOrder: req.query.sortOrder || 'DESC'
                };
                const result = await this.reportsService.obterRelatoriosCliente(cnpj, filial_id, filters);
                res.status(200).json(result);
            }
            catch (error) {
                console.error('Erro ao obter relatórios:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterRelatorioHoje = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const relatorio = await this.reportsService.obterRelatorioHoje(cnpj, filial_id);
                if (!relatorio) {
                    res.status(404).json({
                        success: false,
                        message: 'Nenhum relatório encontrado para hoje'
                    });
                    return;
                }
                res.status(200).json({
                    success: true,
                    message: 'Relatório do dia obtido com sucesso',
                    data: relatorio
                });
            }
            catch (error) {
                console.error('Erro ao obter relatório de hoje:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.obterEstatisticas = async (req, res) => {
            try {
                const { cnpj, filial_id } = req.user;
                const dias = parseInt(req.query.dias) || 30;
                const estatisticas = await this.reportsService.obterEstatisticasVendas(cnpj, filial_id, dias);
                res.status(200).json({
                    success: true,
                    message: 'Estatísticas obtidas com sucesso',
                    data: estatisticas
                });
            }
            catch (error) {
                console.error('Erro ao obter estatísticas:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.criarRelatorio = async (req, res) => {
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
                const { cliente_cnpj, filial_id, data_relatorio, vendas_debito, vendas_credito, vendas_dinheiro, vendas_pix, vendas_vale } = req.body;
                const relatorio = await this.reportsService.criarRelatorioVendas({
                    cliente_cnpj,
                    filial_id,
                    data_relatorio: new Date(data_relatorio),
                    vendas_debito: parseFloat(vendas_debito),
                    vendas_credito: parseFloat(vendas_credito),
                    vendas_dinheiro: parseFloat(vendas_dinheiro),
                    vendas_pix: parseFloat(vendas_pix),
                    vendas_vale: parseFloat(vendas_vale)
                });
                res.status(201).json({
                    success: true,
                    message: 'Relatório criado com sucesso',
                    data: relatorio
                });
            }
            catch (error) {
                console.error('Erro ao criar relatório:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.atualizarRelatorio = async (req, res) => {
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
                const updateData = req.body;
                const relatorio = await this.reportsService.atualizarRelatorioVendas(id, cnpj, filial_id, updateData);
                res.status(200).json({
                    success: true,
                    message: 'Relatório atualizado com sucesso',
                    data: relatorio
                });
            }
            catch (error) {
                console.error('Erro ao atualizar relatório:', error);
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
        this.excluirRelatorio = async (req, res) => {
            try {
                const { id } = req.params;
                const { cnpj, filial_id } = req.user;
                const deleted = await this.reportsService.excluirRelatorio(id, cnpj, filial_id);
                if (!deleted) {
                    res.status(404).json({
                        success: false,
                        message: 'Relatório não encontrado ou sem permissão'
                    });
                    return;
                }
                res.status(200).json({
                    success: true,
                    message: 'Relatório excluído com sucesso'
                });
            }
            catch (error) {
                console.error('Erro ao excluir relatório:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.reportsService = new ReportsService_1.ReportsService();
    }
}
exports.ReportsController = ReportsController;
//# sourceMappingURL=ReportsController.js.map