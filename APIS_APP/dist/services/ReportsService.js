"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportsService = void 0;
const DatabaseService_1 = require("./DatabaseService");
const NotificationService_1 = require("./NotificationService");
class ReportsService {
    constructor() {
        this.db = DatabaseService_1.DatabaseService.getInstance();
        this.notificationService = new NotificationService_1.NotificationService();
    }
    async criarRelatorioVendas(data) {
        const clienteQuery = 'SELECT id FROM clientes WHERE cnpj = $1 AND filial_id = $2';
        const clienteResult = await this.db.query(clienteQuery, [data.cliente_cnpj, data.filial_id]);
        if (clienteResult.rows.length === 0) {
            throw new Error('Cliente não encontrado');
        }
        const cliente_id = clienteResult.rows[0].id;
        const total_vendas = data.vendas_debito + data.vendas_credito + data.vendas_dinheiro + data.vendas_pix + data.vendas_vale;
        const query = `
      INSERT INTO relatorios_vendas (
        cliente_id, cliente_cnpj, filial_id, data_relatorio, vendas_debito, 
        vendas_credito, vendas_dinheiro, vendas_pix, vendas_vale, total_vendas
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
    `;
        const params = [
            cliente_id,
            data.cliente_cnpj,
            data.filial_id,
            data.data_relatorio,
            data.vendas_debito,
            data.vendas_credito,
            data.vendas_dinheiro,
            data.vendas_pix,
            data.vendas_vale,
            total_vendas
        ];
        const result = await this.db.query(query, params);
        const relatorio = result.rows[0];
        await this.notificationService.enviarNotificacaoRelatorio(data.cliente_cnpj, data.filial_id, relatorio);
        return relatorio;
    }
    async obterRelatoriosCliente(cliente_cnpj, filial_id, filters = {}) {
        const { page = 1, limit = 10, dataInicio, dataFim, sortBy = 'data_relatorio', sortOrder = 'DESC' } = filters;
        const offset = (page - 1) * limit;
        let whereConditions = ['cliente_cnpj = $1', 'filial_id = $2'];
        let params = [cliente_cnpj, filial_id];
        let paramIndex = 3;
        if (dataInicio) {
            whereConditions.push(`data_relatorio >= $${paramIndex}`);
            params.push(dataInicio);
            paramIndex++;
        }
        if (dataFim) {
            whereConditions.push(`data_relatorio <= $${paramIndex}`);
            params.push(dataFim);
            paramIndex++;
        }
        const whereClause = whereConditions.join(' AND ');
        const query = `
      SELECT * FROM relatorios_vendas 
      WHERE ${whereClause}
      ORDER BY ${sortBy} ${sortOrder}
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
        params.push(limit, offset);
        const countQuery = `
      SELECT COUNT(*) FROM relatorios_vendas 
      WHERE ${whereClause}
    `;
        const countParams = params.slice(0, paramIndex - 1);
        const [dataResult, countResult] = await Promise.all([
            this.db.query(query, params),
            this.db.query(countQuery, countParams)
        ]);
        const total = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(total / limit);
        return {
            success: true,
            message: 'Relatórios obtidos com sucesso',
            data: dataResult.rows,
            pagination: {
                page,
                limit,
                total,
                totalPages
            }
        };
    }
    async obterRelatorioHoje(cliente_cnpj, filial_id) {
        const hoje = new Date();
        const inicioDodia = new Date(hoje.setHours(0, 0, 0, 0));
        const fimDoDia = new Date(hoje.setHours(23, 59, 59, 999));
        const query = `
      SELECT * FROM relatorios_vendas 
      WHERE cliente_cnpj = $1 AND filial_id = $2 
      AND data_relatorio >= $3 AND data_relatorio <= $4
      ORDER BY data_relatorio DESC
      LIMIT 1
    `;
        const result = await this.db.query(query, [cliente_cnpj, filial_id, inicioDodia, fimDoDia]);
        return result.rows[0] || null;
    }
    async obterEstatisticasVendas(cliente_cnpj, filial_id, dias = 30) {
        const dataLimite = new Date();
        dataLimite.setDate(dataLimite.getDate() - dias);
        const query = `
      SELECT 
        COUNT(*) as total_relatorios,
        SUM(total_vendas) as total_periodo,
        AVG(total_vendas) as media_diaria,
        MAX(total_vendas) as maior_venda,
        MIN(total_vendas) as menor_venda,
        SUM(vendas_debito) as total_debito,
        SUM(vendas_credito) as total_credito,
        SUM(vendas_dinheiro) as total_dinheiro,
        SUM(vendas_pix) as total_pix,
        SUM(vendas_vale) as total_vale
      FROM relatorios_vendas 
      WHERE cliente_cnpj = $1 AND filial_id = $2 
      AND data_relatorio >= $3
    `;
        const result = await this.db.query(query, [cliente_cnpj, filial_id, dataLimite]);
        const stats = result.rows[0];
        return {
            total_periodo: parseFloat(stats.total_periodo) || 0,
            media_diaria: parseFloat(stats.media_diaria) || 0,
            maior_venda: parseFloat(stats.maior_venda) || 0,
            menor_venda: parseFloat(stats.menor_venda) || 0,
            vendas_por_tipo: {
                debito: parseFloat(stats.total_debito) || 0,
                credito: parseFloat(stats.total_credito) || 0,
                dinheiro: parseFloat(stats.total_dinheiro) || 0,
                pix: parseFloat(stats.total_pix) || 0,
                vale: parseFloat(stats.total_vale) || 0
            }
        };
    }
    async atualizarRelatorioVendas(id, cliente_cnpj, filial_id, data) {
        const allowedFields = [
            'vendas_debito', 'vendas_credito', 'vendas_dinheiro',
            'vendas_pix', 'vendas_vale'
        ];
        const updateFields = Object.keys(data)
            .filter(key => allowedFields.includes(key))
            .map((key, index) => `${key} = $${index + 4}`)
            .join(', ');
        if (!updateFields) {
            throw new Error('Nenhum campo válido para atualização');
        }
        const values = Object.keys(data)
            .filter(key => allowedFields.includes(key))
            .map(key => data[key]);
        const query = `
      UPDATE relatorios_vendas 
      SET ${updateFields}, 
          total_vendas = vendas_debito + vendas_credito + vendas_dinheiro + vendas_pix + vendas_vale,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1 AND cliente_cnpj = $2 AND filial_id = $3
      RETURNING *
    `;
        const params = [id, cliente_cnpj, filial_id, ...values];
        const result = await this.db.query(query, params);
        if (result.rows.length === 0) {
            throw new Error('Relatório não encontrado ou sem permissão');
        }
        return result.rows[0];
    }
    async excluirRelatorio(id, cliente_cnpj, filial_id) {
        const query = `
      DELETE FROM relatorios_vendas 
      WHERE id = $1 AND cliente_cnpj = $2 AND filial_id = $3
    `;
        const result = await this.db.query(query, [id, cliente_cnpj, filial_id]);
        return result.rowCount > 0;
    }
}
exports.ReportsService = ReportsService;
//# sourceMappingURL=ReportsService.js.map