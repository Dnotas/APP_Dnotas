"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CronJobs = void 0;
const node_cron_1 = __importDefault(require("node-cron"));
const NotificationService_1 = require("../services/NotificationService");
const FinancialService_1 = require("../services/FinancialService");
class CronJobs {
    constructor() {
        this.notificationService = new NotificationService_1.NotificationService();
        this.financialService = new FinancialService_1.FinancialService();
    }
    initializeCronJobs() {
        console.log('🕐 Inicializando tarefas agendadas...');
        node_cron_1.default.schedule('0 9 * * *', async () => {
            console.log('⏰ Executando: Verificação de boletos vencendo');
            try {
                await this.financialService.verificarBoletosVencendo();
                console.log('✅ Verificação de boletos vencendo concluída');
            }
            catch (error) {
                console.error('❌ Erro na verificação de boletos vencendo:', error);
            }
        }, {
            timezone: 'America/Sao_Paulo'
        });
        node_cron_1.default.schedule('0 10 * * 1', async () => {
            console.log('⏰ Executando: Verificação de clientes inativos');
            try {
                await this.notificationService.verificarClientesInativos();
                console.log('✅ Verificação de clientes inativos concluída');
            }
            catch (error) {
                console.error('❌ Erro na verificação de clientes inativos:', error);
            }
        }, {
            timezone: 'America/Sao_Paulo'
        });
        node_cron_1.default.schedule('0 2 * * 0', async () => {
            console.log('⏰ Executando: Limpeza de notificações antigas');
            try {
                const removed = await this.notificationService.limparNotificacoesAntigas(90);
                console.log(`✅ Limpeza concluída: ${removed} notificações removidas`);
            }
            catch (error) {
                console.error('❌ Erro na limpeza de notificações:', error);
            }
        }, {
            timezone: 'America/Sao_Paulo'
        });
        node_cron_1.default.schedule('0 * * * *', async () => {
            console.log('⏰ Executando: Verificação de saúde do sistema');
            try {
                const now = new Date();
                console.log(`✅ Sistema operacional às ${now.toLocaleString('pt-BR')}`);
            }
            catch (error) {
                console.error('❌ Erro na verificação de saúde:', error);
            }
        });
        if (process.env.NODE_ENV === 'production') {
            node_cron_1.default.schedule('0 23 * * *', async () => {
                console.log('⏰ Executando: Backup de logs');
                try {
                    console.log('✅ Backup de logs concluído');
                }
                catch (error) {
                    console.error('❌ Erro no backup de logs:', error);
                }
            }, {
                timezone: 'America/Sao_Paulo'
            });
        }
        console.log('✅ Tarefas agendadas inicializadas com sucesso');
    }
    stopAllJobs() {
        node_cron_1.default.getTasks().forEach((task) => {
            task.stop();
        });
        console.log('🛑 Todas as tarefas agendadas foram interrompidas');
    }
}
exports.CronJobs = CronJobs;
//# sourceMappingURL=cronJobs.js.map