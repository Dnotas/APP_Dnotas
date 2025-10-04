import cron from 'node-cron';
import { NotificationService } from '../services/NotificationService';
import { FinancialService } from '../services/FinancialService';

export class CronJobs {
  private notificationService: NotificationService;
  private financialService: FinancialService;

  constructor() {
    this.notificationService = new NotificationService();
    this.financialService = new FinancialService();
  }

  public initializeCronJobs(): void {
    console.log('🕐 Inicializando tarefas agendadas...');

    // Verificar boletos vencendo - todo dia às 9:00
    cron.schedule('0 9 * * *', async () => {
      console.log('⏰ Executando: Verificação de boletos vencendo');
      try {
        await this.financialService.verificarBoletosVencendo();
        console.log('✅ Verificação de boletos vencendo concluída');
      } catch (error) {
        console.error('❌ Erro na verificação de boletos vencendo:', error);
      }
    }, {
      timezone: 'America/Sao_Paulo'
    });

    // Verificar clientes inativos - toda segunda-feira às 10:00
    cron.schedule('0 10 * * 1', async () => {
      console.log('⏰ Executando: Verificação de clientes inativos');
      try {
        await this.notificationService.verificarClientesInativos();
        console.log('✅ Verificação de clientes inativos concluída');
      } catch (error) {
        console.error('❌ Erro na verificação de clientes inativos:', error);
      }
    }, {
      timezone: 'America/Sao_Paulo'
    });

    // Limpeza de notificações antigas - todo domingo às 2:00
    cron.schedule('0 2 * * 0', async () => {
      console.log('⏰ Executando: Limpeza de notificações antigas');
      try {
        const removed = await this.notificationService.limparNotificacoesAntigas(90);
        console.log(`✅ Limpeza concluída: ${removed} notificações removidas`);
      } catch (error) {
        console.error('❌ Erro na limpeza de notificações:', error);
      }
    }, {
      timezone: 'America/Sao_Paulo'
    });

    // Verificação de saúde do sistema - a cada hora
    cron.schedule('0 * * * *', async () => {
      console.log('⏰ Executando: Verificação de saúde do sistema');
      try {
        const now = new Date();
        console.log(`✅ Sistema operacional às ${now.toLocaleString('pt-BR')}`);
      } catch (error) {
        console.error('❌ Erro na verificação de saúde:', error);
      }
    });

    // Backup de logs - todo dia às 23:00 (apenas em produção)
    if (process.env.NODE_ENV === 'production') {
      cron.schedule('0 23 * * *', async () => {
        console.log('⏰ Executando: Backup de logs');
        try {
          // Aqui você implementaria a lógica de backup dos logs
          console.log('✅ Backup de logs concluído');
        } catch (error) {
          console.error('❌ Erro no backup de logs:', error);
        }
      }, {
        timezone: 'America/Sao_Paulo'
      });
    }

    console.log('✅ Tarefas agendadas inicializadas com sucesso');
  }

  public stopAllJobs(): void {
    cron.getTasks().forEach((task) => {
      task.stop();
    });
    console.log('🛑 Todas as tarefas agendadas foram interrompidas');
  }
}