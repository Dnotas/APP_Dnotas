import { DatabaseService } from './DatabaseService';
import { FirebaseService } from './FirebaseService';
import { Notification, RelatorioVendas, Boleto, NotificationFilters, ApiResponse } from '../types';

export class NotificationService {
  private db: DatabaseService;
  private firebase: FirebaseService;

  constructor() {
    this.db = DatabaseService.getInstance();
    this.firebase = new FirebaseService();
  }

  async criarNotificacao(data: {
    cliente_cnpj: string;
    filial_id: string;
    tipo: 'relatorio' | 'boleto' | 'inatividade' | 'geral';
    titulo: string;
    mensagem: string;
    enviar_push?: boolean;
  }): Promise<Notification> {
    const query = `
      INSERT INTO notifications (
        cliente_cnpj, filial_id, tipo, titulo, mensagem, lida, data_envio
      ) VALUES ($1, $2, $3, $4, $5, false, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    const params = [
      data.cliente_cnpj,
      data.filial_id,
      data.tipo,
      data.titulo,
      data.mensagem
    ];

    const result = await this.db.query<Notification>(query, params);
    const notification = result.rows[0];

    // Enviar push notification se solicitado
    if (data.enviar_push !== false) {
      await this.enviarPushNotification(data.cliente_cnpj, data.titulo, data.mensagem);
    }

    return notification;
  }

  async enviarNotificacaoRelatorio(
    cliente_cnpj: string,
    filial_id: string,
    relatorio: RelatorioVendas
  ): Promise<void> {
    const titulo = 'Novo Relatório de Vendas';
    const mensagem = `Seu relatório de vendas de ${relatorio.data_relatorio.toLocaleDateString('pt-BR')} está disponível. Total: R$ ${relatorio.total_vendas.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;

    await this.criarNotificacao({
      cliente_cnpj,
      filial_id,
      tipo: 'relatorio',
      titulo,
      mensagem,
      enviar_push: true
    });
  }

  async enviarNotificacaoBoleto(
    cliente_cnpj: string,
    filial_id: string,
    boleto: Boleto
  ): Promise<void> {
    const titulo = 'Novo Boleto Disponível';
    const mensagem = `Novo boleto no valor de R$ ${boleto.valor.toLocaleString('pt-BR', { minimumFractionDigits: 2 })} com vencimento em ${boleto.data_vencimento.toLocaleDateString('pt-BR')}`;

    await this.criarNotificacao({
      cliente_cnpj,
      filial_id,
      tipo: 'boleto',
      titulo,
      mensagem,
      enviar_push: true
    });
  }

  async enviarNotificacaoVencimento(
    cliente_cnpj: string,
    filial_id: string,
    quantidade: number
  ): Promise<void> {
    const titulo = 'Boletos Vencendo';
    const mensagem = quantidade === 1 
      ? 'Você tem 1 boleto vencendo nos próximos 3 dias'
      : `Você tem ${quantidade} boletos vencendo nos próximos 3 dias`;

    await this.criarNotificacao({
      cliente_cnpj,
      filial_id,
      tipo: 'boleto',
      titulo,
      mensagem,
      enviar_push: true
    });
  }

  async enviarNotificacaoInatividade(cliente_cnpj: string, filial_id: string, dias: number): Promise<void> {
    const titulo = 'Sua Presença Faz Falta!';
    const mensagem = `Notamos que você não acessa o app há ${dias} dias. Há novidades importantes esperando por você!`;

    await this.criarNotificacao({
      cliente_cnpj,
      filial_id,
      tipo: 'inatividade',
      titulo,
      mensagem,
      enviar_push: true
    });
  }

  async obterNotificacoesCliente(
    cliente_cnpj: string,
    filial_id: string,
    filters: NotificationFilters = {}
  ): Promise<ApiResponse<Notification[]>> {
    const {
      page = 1,
      limit = 20,
      tipo,
      lida,
      dataInicio,
      dataFim,
      sortBy = 'data_envio',
      sortOrder = 'DESC'
    } = filters;

    const offset = (page - 1) * limit;
    
    let whereConditions = ['cliente_cnpj = $1', 'filial_id = $2'];
    let params: any[] = [cliente_cnpj, filial_id];
    let paramIndex = 3;

    if (tipo) {
      whereConditions.push(`tipo = $${paramIndex}`);
      params.push(tipo);
      paramIndex++;
    }

    if (lida !== undefined) {
      whereConditions.push(`lida = $${paramIndex}`);
      params.push(lida);
      paramIndex++;
    }

    if (dataInicio) {
      whereConditions.push(`data_envio >= $${paramIndex}`);
      params.push(dataInicio);
      paramIndex++;
    }

    if (dataFim) {
      whereConditions.push(`data_envio <= $${paramIndex}`);
      params.push(dataFim);
      paramIndex++;
    }

    const whereClause = whereConditions.join(' AND ');

    // Consulta principal
    const query = `
      SELECT * FROM notifications 
      WHERE ${whereClause}
      ORDER BY ${sortBy} ${sortOrder}
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
    params.push(limit, offset);

    // Consulta para total de registros
    const countQuery = `
      SELECT COUNT(*) FROM notifications 
      WHERE ${whereClause}
    `;
    const countParams = params.slice(0, paramIndex - 1);

    const [dataResult, countResult] = await Promise.all([
      this.db.query<Notification>(query, params),
      this.db.query(countQuery, countParams)
    ]);

    const total = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      message: 'Notificações obtidas com sucesso',
      data: dataResult.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages
      }
    };
  }

  async obterNotificacoesNaoLidas(cliente_cnpj: string, filial_id: string): Promise<{
    total: number;
    notificacoes: Notification[];
  }> {
    const query = `
      SELECT * FROM notifications 
      WHERE cliente_cnpj = $1 AND filial_id = $2 AND lida = false
      ORDER BY data_envio DESC
      LIMIT 10
    `;

    const countQuery = `
      SELECT COUNT(*) FROM notifications 
      WHERE cliente_cnpj = $1 AND filial_id = $2 AND lida = false
    `;

    const [dataResult, countResult] = await Promise.all([
      this.db.query<Notification>(query, [cliente_cnpj, filial_id]),
      this.db.query(countQuery, [cliente_cnpj, filial_id])
    ]);

    return {
      total: parseInt(countResult.rows[0].count),
      notificacoes: dataResult.rows
    };
  }

  async marcarComoLida(id: string, cliente_cnpj: string, filial_id: string): Promise<boolean> {
    const query = `
      UPDATE notifications 
      SET lida = true, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1 AND cliente_cnpj = $2 AND filial_id = $3
    `;

    const result = await this.db.query(query, [id, cliente_cnpj, filial_id]);
    return result.rowCount > 0;
  }

  async marcarTodasComoLidas(cliente_cnpj: string, filial_id: string): Promise<number> {
    const query = `
      UPDATE notifications 
      SET lida = true, updated_at = CURRENT_TIMESTAMP
      WHERE cliente_cnpj = $1 AND filial_id = $2 AND lida = false
    `;

    const result = await this.db.query(query, [cliente_cnpj, filial_id]);
    return result.rowCount;
  }

  async excluirNotificacao(id: string, cliente_cnpj: string, filial_id: string): Promise<boolean> {
    const query = `
      DELETE FROM notifications 
      WHERE id = $1 AND cliente_cnpj = $2 AND filial_id = $3
    `;

    const result = await this.db.query(query, [id, cliente_cnpj, filial_id]);
    return result.rowCount > 0;
  }

  private async enviarPushNotification(cliente_cnpj: string, titulo: string, mensagem: string): Promise<void> {
    try {
      // Buscar token FCM do usuário
      const tokenQuery = 'SELECT fcm_token FROM users WHERE cnpj = $1 AND fcm_token IS NOT NULL';
      const tokenResult = await this.db.query(tokenQuery, [cliente_cnpj]);

      if (tokenResult.rows.length === 0) {
        console.log(`Nenhum token FCM encontrado para o cliente ${cliente_cnpj}`);
        return;
      }

      const fcmToken = tokenResult.rows[0].fcm_token;
      await this.firebase.enviarNotificacao(fcmToken, titulo, mensagem);
    } catch (error) {
      console.error('Erro ao enviar push notification:', error);
    }
  }

  // Método para verificar clientes inativos e enviar notificações
  async verificarClientesInativos(): Promise<void> {
    const diasInatividade = 7; // 7 dias sem acesso
    const dataLimite = new Date();
    dataLimite.setDate(dataLimite.getDate() - diasInatividade);

    const query = `
      SELECT DISTINCT u.cnpj, u.filial_id, 
             EXTRACT(DAY FROM CURRENT_TIMESTAMP - u.ultimo_acesso) as dias_inativo
      FROM users u
      LEFT JOIN notifications n ON u.cnpj = n.cliente_cnpj 
        AND n.tipo = 'inatividade' 
        AND n.data_envio >= CURRENT_TIMESTAMP - INTERVAL '7 days'
      WHERE u.ultimo_acesso < $1 
        AND u.ativo = true
        AND n.id IS NULL
    `;

    const result = await this.db.query(query, [dataLimite]);

    for (const row of result.rows) {
      await this.enviarNotificacaoInatividade(
        row.cnpj,
        row.filial_id,
        Math.floor(row.dias_inativo)
      );
    }
  }

  // Método para limpeza de notificações antigas
  async limparNotificacoesAntigas(diasAntigos: number = 90): Promise<number> {
    const dataLimite = new Date();
    dataLimite.setDate(dataLimite.getDate() - diasAntigos);

    const query = `
      DELETE FROM notifications 
      WHERE data_envio < $1 AND lida = true
    `;

    const result = await this.db.query(query, [dataLimite]);
    return result.rowCount;
  }
}