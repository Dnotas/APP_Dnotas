/// Configurações de webhook para o ambiente
class WebhookConfig {
  // URLs do webhook para diferentes ambientes
  static const String _prodWebhookUrl = 'https://api.dnotas.com.br:9999/api/webhook/asaas';
  static const String _devWebhookUrl = 'https://api.dnotas.com.br:9999/api/webhook/asaas';
  static const String _localWebhookUrl = 'http://localhost:9999/api/webhook/asaas';

  /// Retorna a URL do webhook baseada no ambiente
  static String get webhookUrl {
    // Usando URL de produção
    return _prodWebhookUrl;
  }

  /// Configurações específicas do webhook
  static const Map<String, dynamic> webhookSettings = {
    'timeout_seconds': 30,
    'retry_attempts': 3,
    'retry_delay_seconds': 5,
  };

  /// Email para notificações de erro do webhook
  static const String webhookErrorEmail = 'admin@dnotas.com.br';

  /// Eventos que queremos receber do Asaas
  static const List<String> subscribedEvents = [
    'PAYMENT_CREATED',
    'PAYMENT_UPDATED', 
    'PAYMENT_CONFIRMED',
    'PAYMENT_RECEIVED',
    'PAYMENT_OVERDUE',
    'PAYMENT_DELETED',
    'PAYMENT_RESTORED',
    'PAYMENT_REFUNDED',
    'PAYMENT_RECEIVED_IN_CASH',
    'PAYMENT_CHARGEBACK_REQUESTED',
    'PAYMENT_CHARGEBACK_DISPUTE',
    'PAYMENT_AWAITING_CHARGEBACK_REVERSAL',
  ];

  /// Verificar se é ambiente de desenvolvimento
  static bool get isDev {
    // Detecta se é debug mode
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }

  /// Verificar se é ambiente de produção
  static bool get isProd {
    return !isDev;
  }
}

/// Instruções para configurar webhook em produção:
/// 
/// 1. Alterar _prodWebhookUrl para sua URL real
/// 2. Configurar SSL/HTTPS obrigatório
/// 3. Implementar autenticação/validação do webhook
/// 4. Configurar logs de auditoria
/// 5. Implementar retry logic para falhas
/// 6. Monitorar saúde do endpoint
/// 
/// Exemplo de configuração no servidor:
/// - nginx com SSL
/// - Rate limiting
/// - IP whitelist do Asaas
/// - Logs estruturados
/// - Healthcheck endpoint