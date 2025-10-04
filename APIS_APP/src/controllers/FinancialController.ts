import { Request, Response } from 'express';
import { FinancialService } from '../services/FinancialService';
import { BoletoFilters } from '../types';
import { validationResult } from 'express-validator';

export class FinancialController {
  private financialService: FinancialService;

  constructor() {
    this.financialService = new FinancialService();
  }

  // GET /api/financial/boletos - Obter boletos do cliente
  obterBoletos = async (req: Request, res: Response): Promise<void> => {
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
      const filters: BoletoFilters = {
        page: parseInt(req.query.page as string) || 1,
        limit: parseInt(req.query.limit as string) || 10,
        status: req.query.status as string,
        dataVencimentoInicio: req.query.dataVencimentoInicio as string,
        dataVencimentoFim: req.query.dataVencimentoFim as string,
        sortBy: req.query.sortBy as string || 'data_vencimento',
        sortOrder: (req.query.sortOrder as 'ASC' | 'DESC') || 'ASC'
      };

      const result = await this.financialService.obterBoletosCliente(cnpj, filial_id, filters);
      res.status(200).json(result);
    } catch (error) {
      console.error('Erro ao obter boletos:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/financial/boletos/pendentes - Obter boletos pendentes
  obterBoletosPendentes = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const boletos = await this.financialService.obterBoletosPendentes(cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: 'Boletos pendentes obtidos com sucesso',
        data: boletos
      });
    } catch (error) {
      console.error('Erro ao obter boletos pendentes:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/financial/estatisticas - Obter estatísticas financeiras
  obterEstatisticas = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const estatisticas = await this.financialService.obterEstatisticasFinanceiras(cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: 'Estatísticas financeiras obtidas com sucesso',
        data: estatisticas
      });
    } catch (error) {
      console.error('Erro ao obter estatísticas financeiras:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // GET /api/financial/extrato - Obter extrato financeiro
  obterExtrato = async (req: Request, res: Response): Promise<void> => {
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
      const { dataInicio, dataFim } = req.query;

      const extrato = await this.financialService.obterExtrato(
        cnpj,
        filial_id,
        dataInicio as string,
        dataFim as string
      );

      res.status(200).json({
        success: true,
        message: 'Extrato obtido com sucesso',
        data: extrato
      });
    } catch (error) {
      console.error('Erro ao obter extrato:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // POST /api/financial/boletos - Criar novo boleto (apenas administradores)
  criarBoleto = async (req: Request, res: Response): Promise<void> => {
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
        numero_boleto,
        valor,
        data_vencimento,
        linha_digitavel,
        codigo_barras
      } = req.body;

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
    } catch (error) {
      console.error('Erro ao criar boleto:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };

  // PUT /api/financial/boletos/:numero/pagar - Marcar boleto como pago
  marcarBoletoPago = async (req: Request, res: Response): Promise<void> => {
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

      const { numero } = req.params;
      const { cnpj, filial_id } = req.user!;
      const { data_pagamento } = req.body;

      const boleto = await this.financialService.marcarBoletoPago(
        numero,
        cnpj,
        filial_id,
        data_pagamento ? new Date(data_pagamento) : undefined
      );

      res.status(200).json({
        success: true,
        message: 'Boleto marcado como pago com sucesso',
        data: boleto
      });
    } catch (error) {
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

  // PUT /api/financial/boletos/:numero/cancelar - Cancelar boleto
  cancelarBoleto = async (req: Request, res: Response): Promise<void> => {
    try {
      const { numero } = req.params;
      const { cnpj, filial_id } = req.user!;

      const boleto = await this.financialService.cancelarBoleto(numero, cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: 'Boleto cancelado com sucesso',
        data: boleto
      });
    } catch (error) {
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

  // GET /api/financial/boletos/vencidos - Verificar e obter boletos vencidos
  obterBoletosVencidos = async (req: Request, res: Response): Promise<void> => {
    try {
      const { cnpj, filial_id } = req.user!;
      const boletosVencidos = await this.financialService.obterBoletosVencidos(cnpj, filial_id);

      res.status(200).json({
        success: true,
        message: 'Boletos vencidos obtidos com sucesso',
        data: boletosVencidos
      });
    } catch (error) {
      console.error('Erro ao obter boletos vencidos:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  };
}