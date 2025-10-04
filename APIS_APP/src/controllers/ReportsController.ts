import { Request, Response } from 'express';
import { ReportsService } from '../services/ReportsService';
import { RelatorioFilters } from '../types';
import { validationResult } from 'express-validator';

export class ReportsController {
  private reportsService: ReportsService;

  constructor() {
    this.reportsService = new ReportsService();
  }

  // GET /api/reports - Obter relatórios do cliente
  obterRelatorios = async (req: Request, res: Response): Promise<void> => {
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
      const filters: RelatorioFilters = {
        page: parseInt(req.query.page as string) || 1,
        limit: parseInt(req.query.limit as string) || 10,
        dataInicio: req.query.dataInicio as string,
        dataFim: req.query.dataFim as string,
        sortBy: req.query.sortBy as string || 'data_relatorio',
        sortOrder: (req.query.sortOrder as 'ASC' | 'DESC') || 'DESC'
      };

      const result = await this.reportsService.obterRelatoriosCliente(cnpj, filial_id, filters);
      res.status(200).json(result);
    } catch (error) {
      console.error('Erro ao obter relatórios:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/reports/hoje - Obter relatório do dia atual
  obterRelatorioHoje = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
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
    } catch (error) {
      console.error('Erro ao obter relatório de hoje:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/reports/estatisticas - Obter estatísticas de vendas
  obterEstatisticas = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const dias = parseInt(req.query.dias as string) || 30;

      const estatisticas = await this.reportsService.obterEstatisticasVendas(cnpj, filial_id, dias);

      res.status(200).json({
        success: true,
        message: 'Estatísticas obtidas com sucesso',
        data: estatisticas
      });
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/reports - Criar novo relatório (usado internamente pela empresa)
  criarRelatorio = async (req: Request, res: Response): Promise<void> => {
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
        data_relatorio,
        vendas_debito,
        vendas_credito,
        vendas_dinheiro,
        vendas_pix,
        vendas_vale
      } = req.body;

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
    } catch (error) {
      console.error('Erro ao criar relatório:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // PUT /api/reports/:id - Atualizar relatório
  atualizarRelatorio = async (req: Request, res: Response): Promise<void> => {
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
      const updateData = req.body;

      const relatorio = await this.reportsService.atualizarRelatorioVendas(
        id,
        cnpj,
        filial_id,
        updateData
      );

      res.status(200).json({
        success: true,
        message: 'Relatório atualizado com sucesso',
        data: relatorio
      });
    } catch (error) {
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

  // DELETE /api/reports/:id - Excluir relatório
  excluirRelatorio = async (req: Request, res: Response): Promise<void> => {
    try {
      const { id } = req.params;
      const { cnpj, filial_id } = req.user!;

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
    } catch (error) {
      console.error('Erro ao excluir relatório:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };
}