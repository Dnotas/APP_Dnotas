import { DatabaseService } from './DatabaseService';
import { NotificationService } from './NotificationService';
import { Boleto, BoletoFilters, ApiResponse } from '../types';

export class FinancialService {
  private db: DatabaseService;
  private notificationService: NotificationService;

  constructor() {
    this.db = DatabaseService.getInstance();
    this.notificationService = new NotificationService();
  }

  async criarBoleto(data: {
    cliente_cnpj: string;
    filial_id: string;
    numero_boleto: string;
    valor: number;
    data_vencimento: Date;
    linha_digitavel: string;
    codigo_barras: string;
  }): Promise<Boleto> {
    const query = `
      INSERT INTO boletos (
        cliente_cnpj, filial_id, numero_boleto, valor, 
        data_vencimento, linha_digitavel, codigo_barras, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, 'pendente')
      RETURNING *
    `;

    const params = [
      data.cliente_cnpj,
      data.filial_id,
      data.numero_boleto,
      data.valor,
      data.data_vencimento,
      data.linha_digitavel,
      data.codigo_barras
    ];

    const result = await this.db.query<Boleto>(query, params);
    const boleto = result.rows[0];

    // Enviar notificação para o cliente
    await this.notificationService.enviarNotificacaoBoleto(
      data.cliente_cnpj,
      data.filial_id,
      boleto
    );

    return boleto;
  }

  async obterBoletosCliente(
    cliente_cnpj: string,
    filial_id: string,
    filters: BoletoFilters = {}
  ): Promise<ApiResponse<Boleto[]>> {
    const {
      page = 1,
      limit = 10,
      status,
      dataVencimentoInicio,
      dataVencimentoFim,
      sortBy = 'data_vencimento',
      sortOrder = 'ASC'
    } = filters;

    const offset = (page - 1) * limit;
    
    let whereConditions = ['cliente_cnpj = $1', 'filial_id = $2'];
    let params: any[] = [cliente_cnpj, filial_id];
    let paramIndex = 3;

    if (status) {
      whereConditions.push(`status = $${paramIndex}`);
      params.push(status);
      paramIndex++;
    }

    if (dataVencimentoInicio) {
      whereConditions.push(`data_vencimento >= $${paramIndex}`);
      params.push(dataVencimentoInicio);
      paramIndex++;
    }

    if (dataVencimentoFim) {
      whereConditions.push(`data_vencimento <= $${paramIndex}`);
      params.push(dataVencimentoFim);
      paramIndex++;
    }

    const whereClause = whereConditions.join(' AND ');

    // Consulta principal
    const query = `
      SELECT * FROM boletos 
      WHERE ${whereClause}
      ORDER BY ${sortBy} ${sortOrder}
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
    params.push(limit, offset);

    // Consulta para total de registros
    const countQuery = `
      SELECT COUNT(*) FROM boletos 
      WHERE ${whereClause}
    `;
    const countParams = params.slice(0, paramIndex - 1);

    const [dataResult, countResult] = await Promise.all([
      this.db.query<Boleto>(query, params),
      this.db.query(countQuery, countParams)
    ]);

    const total = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      message: 'Boletos obtidos com sucesso',
      data: dataResult.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages
      }
    };
  }

  async obterBoletosPendentes(cliente_cnpj: string, filial_id: string): Promise<Boleto[]> {
    const query = `
      SELECT * FROM boletos 
      WHERE cliente_cnpj = $1 AND filial_id = $2 AND status = 'pendente'
      ORDER BY data_vencimento ASC
    `;

    const result = await this.db.query<Boleto>(query, [cliente_cnpj, filial_id]);
    return result.rows;
  }

  async obterBoletosVencidos(cliente_cnpj: string, filial_id: string): Promise<Boleto[]> {
    const hoje = new Date();
    const query = `
      UPDATE boletos 
      SET status = 'vencido', updated_at = CURRENT_TIMESTAMP
      WHERE cliente_cnpj = $1 AND filial_id = $2 
      AND status = 'pendente' AND data_vencimento < $3
      RETURNING *
    `;

    const result = await this.db.query<Boleto>(query, [cliente_cnpj, filial_id, hoje]);
    return result.rows;
  }

  async marcarBoletoPago(
    numero_boleto: string,
    cliente_cnpj: string,
    filial_id: string,
    data_pagamento?: Date
  ): Promise<Boleto> {
    const dataPagamento = data_pagamento || new Date();

    const query = `
      UPDATE boletos 
      SET status = 'pago', data_pagamento = $1, updated_at = CURRENT_TIMESTAMP
      WHERE numero_boleto = $2 AND cliente_cnpj = $3 AND filial_id = $4
      AND status IN ('pendente', 'vencido')
      RETURNING *
    `;

    const result = await this.db.query<Boleto>(
      query, 
      [dataPagamento, numero_boleto, cliente_cnpj, filial_id]
    );

    if (result.rows.length === 0) {
      throw new Error('Boleto não encontrado ou já foi pago');
    }

    return result.rows[0];
  }

  async cancelarBoleto(
    numero_boleto: string,
    cliente_cnpj: string,
    filial_id: string
  ): Promise<Boleto> {
    const query = `
      UPDATE boletos 
      SET status = 'cancelado', updated_at = CURRENT_TIMESTAMP
      WHERE numero_boleto = $1 AND cliente_cnpj = $2 AND filial_id = $3
      AND status IN ('pendente', 'vencido')
      RETURNING *
    `;

    const result = await this.db.query<Boleto>(query, [numero_boleto, cliente_cnpj, filial_id]);

    if (result.rows.length === 0) {
      throw new Error('Boleto não encontrado ou não pode ser cancelado');
    }

    return result.rows[0];
  }

  async obterEstatisticasFinanceiras(cliente_cnpj: string, filial_id: string): Promise<{
    total_pendente: number;
    total_pago: number;
    total_vencido: number;
    valor_total_pendente: number;
    valor_total_pago: number;
    valor_total_vencido: number;
    proximo_vencimento: Date | null;
    boletos_vencendo_30_dias: number;
  }> {
    const query = `
      SELECT 
        COUNT(CASE WHEN status = 'pendente' THEN 1 END) as total_pendente,
        COUNT(CASE WHEN status = 'pago' THEN 1 END) as total_pago,
        COUNT(CASE WHEN status = 'vencido' THEN 1 END) as total_vencido,
        SUM(CASE WHEN status = 'pendente' THEN valor ELSE 0 END) as valor_total_pendente,
        SUM(CASE WHEN status = 'pago' THEN valor ELSE 0 END) as valor_total_pago,
        SUM(CASE WHEN status = 'vencido' THEN valor ELSE 0 END) as valor_total_vencido,
        MIN(CASE WHEN status = 'pendente' THEN data_vencimento END) as proximo_vencimento,
        COUNT(CASE WHEN status = 'pendente' AND data_vencimento <= CURRENT_DATE + INTERVAL '30 days' THEN 1 END) as boletos_vencendo_30_dias
      FROM boletos 
      WHERE cliente_cnpj = $1 AND filial_id = $2
    `;

    const result = await this.db.query(query, [cliente_cnpj, filial_id]);
    const stats = result.rows[0];

    return {
      total_pendente: parseInt(stats.total_pendente) || 0,
      total_pago: parseInt(stats.total_pago) || 0,
      total_vencido: parseInt(stats.total_vencido) || 0,
      valor_total_pendente: parseFloat(stats.valor_total_pendente) || 0,
      valor_total_pago: parseFloat(stats.valor_total_pago) || 0,
      valor_total_vencido: parseFloat(stats.valor_total_vencido) || 0,
      proximo_vencimento: stats.proximo_vencimento || null,
      boletos_vencendo_30_dias: parseInt(stats.boletos_vencendo_30_dias) || 0
    };
  }

  async obterExtrato(
    cliente_cnpj: string,
    filial_id: string,
    dataInicio?: string,
    dataFim?: string
  ): Promise<{
    boletos: Boleto[];
    resumo: {
      total_emitido: number;
      total_pago: number;
      total_pendente: number;
      total_vencido: number;
    };
  }> {
    let whereConditions = ['cliente_cnpj = $1', 'filial_id = $2'];
    let params: any[] = [cliente_cnpj, filial_id];
    let paramIndex = 3;

    if (dataInicio) {
      whereConditions.push(`created_at >= $${paramIndex}`);
      params.push(dataInicio);
      paramIndex++;
    }

    if (dataFim) {
      whereConditions.push(`created_at <= $${paramIndex}`);
      params.push(dataFim);
      paramIndex++;
    }

    const whereClause = whereConditions.join(' AND ');

    // Buscar boletos
    const boletosQuery = `
      SELECT * FROM boletos 
      WHERE ${whereClause}
      ORDER BY created_at DESC
    `;

    // Calcular resumo
    const resumoQuery = `
      SELECT 
        SUM(valor) as total_emitido,
        SUM(CASE WHEN status = 'pago' THEN valor ELSE 0 END) as total_pago,
        SUM(CASE WHEN status = 'pendente' THEN valor ELSE 0 END) as total_pendente,
        SUM(CASE WHEN status = 'vencido' THEN valor ELSE 0 END) as total_vencido
      FROM boletos 
      WHERE ${whereClause}
    `;

    const [boletosResult, resumoResult] = await Promise.all([
      this.db.query<Boleto>(boletosQuery, params),
      this.db.query(resumoQuery, params)
    ]);

    const resumo = resumoResult.rows[0];

    return {
      boletos: boletosResult.rows,
      resumo: {
        total_emitido: parseFloat(resumo.total_emitido) || 0,
        total_pago: parseFloat(resumo.total_pago) || 0,
        total_pendente: parseFloat(resumo.total_pendente) || 0,
        total_vencido: parseFloat(resumo.total_vencido) || 0
      }
    };
  }

  // Método para verificar boletos vencendo e enviar notificações
  async verificarBoletosVencendo(): Promise<void> {
    const dataLimite = new Date();
    dataLimite.setDate(dataLimite.getDate() + 3); // 3 dias antes do vencimento

    const query = `
      SELECT DISTINCT cliente_cnpj, filial_id, COUNT(*) as quantidade
      FROM boletos 
      WHERE status = 'pendente' 
      AND data_vencimento <= $1 
      AND data_vencimento > CURRENT_DATE
      GROUP BY cliente_cnpj, filial_id
    `;

    const result = await this.db.query(query, [dataLimite]);

    for (const row of result.rows) {
      await this.notificationService.enviarNotificacaoVencimento(
        row.cliente_cnpj,
        row.filial_id,
        row.quantidade
      );
    }
  }
}