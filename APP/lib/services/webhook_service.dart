import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para configurar webhooks do Asaas
/// Este arquivo deve ser usado no backend (APIS_APP) para receber webhooks
class WebhookService {
  static const String _baseUrl = 'https://api.asaas.com/v3';
  
  /// Busca chaves Asaas ativas da organização/filial do usuário logado
  static Future<List<String>> _getActiveAsaasKeys() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ Usuário não logado para buscar chaves Asaas');
        return [];
      }

      // Buscar filial_id do usuário
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('filial_id')
          .eq('id', user.id)
          .single();

      final filialId = userResponse['filial_id'];
      
      if (filialId == null) {
        print('❌ Filial não encontrada para o usuário');
        return [];
      }

      // Buscar chaves ativas da filial
      final response = await Supabase.instance.client
          .from('filiais')
          .select('asaas_keys, nome')
          .eq('id', filialId)
          .single();

      final asaasKeys = response['asaas_keys'] as List?;
      
      if (asaasKeys == null || asaasKeys.isEmpty) {
        print('❌ Nenhuma chave Asaas encontrada para a filial');
        return [];
      }

      // Filtrar apenas chaves ativas
      List<String> activeKeys = [];
      for (var keyData in asaasKeys) {
        if (keyData['ativo'] == true && keyData['key'] != null) {
          activeKeys.add(keyData['key']);
        }
      }

      print('🎯 ${activeKeys.length} chaves ativas encontradas para webhooks');
      return activeKeys;
    } catch (e) {
      print('❌ Erro ao buscar chaves Asaas: $e');
      return [];
    }
  }

  /// Busca primeira chave ativa disponível
  static Future<String?> _getFirstActiveKey() async {
    final keys = await _getActiveAsaasKeys();
    return keys.isNotEmpty ? keys.first : null;
  }

  /// Configurar webhook para CPF
  static Future<bool> setupCpfWebhook(String webhookUrl) async {
    final apiKey = await _getFirstActiveKey();
    if (apiKey == null) {
      print('❌ Nenhuma chave Asaas ativa encontrada para configurar webhook CPF');
      return false;
    }
    return await _setupWebhook(apiKey, webhookUrl, 'CPF');
  }

  /// Configurar webhook para CNPJ
  static Future<bool> setupCnpjWebhook(String webhookUrl) async {
    final apiKey = await _getFirstActiveKey();
    if (apiKey == null) {
      print('❌ Nenhuma chave Asaas ativa encontrada para configurar webhook CNPJ');
      return false;
    }
    return await _setupWebhook(apiKey, webhookUrl, 'CNPJ');
  }

  /// Configurar webhook genérico
  static Future<bool> _setupWebhook(String apiKey, String webhookUrl, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/webhooks'),
        headers: {
          'Content-Type': 'application/json',
          'access_token': apiKey,
        },
        body: json.encode({
          'name': 'DNOTAS App Webhook - $type',
          'url': webhookUrl,
          'email': 'contato@dnotas.com.br', // Email para notificações de erro
          'events': [
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
            'PAYMENT_DUNNING_RECEIVED',
            'PAYMENT_DUNNING_REQUESTED',
            'PAYMENT_BANK_SLIP_VIEWED',
            'PAYMENT_CHECKOUT_VIEWED'
          ],
          'enabled': true,
          'interrupted': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Webhook $type configurado: ${data['id']}');
        return true;
      } else {
        print('❌ Erro ao configurar webhook $type: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao configurar webhook $type: $e');
      return false;
    }
  }

  /// Listar webhooks existentes
  static Future<List<Map<String, dynamic>>> listWebhooks(String documentType) async {
    try {
      final apiKey = await _getFirstActiveKey();
      if (apiKey == null) {
        print('❌ Nenhuma chave Asaas ativa encontrada para listar webhooks');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/webhooks'),
        headers: {
          'Content-Type': 'application/json',
          'access_token': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      
      return [];
    } catch (e) {
      print('❌ Erro ao listar webhooks: $e');
      return [];
    }
  }

  /// Deletar webhook
  static Future<bool> deleteWebhook(String webhookId, String documentType) async {
    try {
      final apiKey = await _getFirstActiveKey();
      if (apiKey == null) {
        print('❌ Nenhuma chave Asaas ativa encontrada para deletar webhook');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/webhooks/$webhookId'),
        headers: {
          'Content-Type': 'application/json',
          'access_token': apiKey,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao deletar webhook: $e');
      return false;
    }
  }

  /// Processar payload do webhook (para usar no backend)
  static Map<String, dynamic>? processWebhookPayload(String payload) {
    try {
      final data = json.decode(payload);
      return {
        'event': data['event'],
        'payment': data['payment'],
        'dateCreated': data['dateCreated'],
      };
    } catch (e) {
      print('❌ Erro ao processar payload do webhook: $e');
      return null;
    }
  }
}

/// Exemplo de endpoint para receber webhook no backend (APIS_APP)
/// 
/// POST /webhook/asaas
/// {
///   "event": "PAYMENT_CREATED",
///   "payment": {
///     "id": "pay_123456789",
///     "customer": "cus_123456789",
///     "value": 150.00,
///     "dueDate": "2024-01-15",
///     "status": "PENDING",
///     // ... outros campos
///   }
/// }
/// 
/// Quando receber esse webhook, o backend deve:
/// 1. Validar o payload
/// 2. Atualizar banco de dados local se necessário
/// 3. Enviar notificação push para o cliente específico
/// 4. Retornar status 200 para confirmar recebimento
class WebhookHandler {
  /// Processar webhook recebido
  static Future<void> handleWebhook(Map<String, dynamic> payload) async {
    final event = payload['event'];
    final payment = payload['payment'];
    
    switch (event) {
      case 'PAYMENT_CREATED':
        await _handleNewPayment(payment);
        break;
      case 'PAYMENT_UPDATED':
        await _handlePaymentUpdated(payment);
        break;
      case 'PAYMENT_CONFIRMED':
      case 'PAYMENT_RECEIVED':
        await _handlePaymentReceived(payment);
        break;
      case 'PAYMENT_OVERDUE':
        await _handlePaymentOverdue(payment);
        break;
      default:
        print('Evento não tratado: $event');
    }
  }

  /// Novo pagamento criado
  static Future<void> _handleNewPayment(Map<String, dynamic> payment) async {
    print('💰 Novo boleto criado: ${payment['id']}');
    
    // Aqui você implementaria:
    // 1. Salvar no banco de dados local
    // 2. Buscar CNPJ/CPF do cliente
    // 3. Enviar notificação push para o app do cliente
    // 4. Enviar notificação por email se configurado
  }

  /// Pagamento atualizado
  static Future<void> _handlePaymentUpdated(Map<String, dynamic> payment) async {
    print('🔄 Boleto atualizado: ${payment['id']}');
    
    // Atualizar dados no banco local
  }

  /// Pagamento recebido
  static Future<void> _handlePaymentReceived(Map<String, dynamic> payment) async {
    print('✅ Boleto pago: ${payment['id']}');
    
    // Notificar cliente que pagamento foi confirmado
  }

  /// Pagamento vencido
  static Future<void> _handlePaymentOverdue(Map<String, dynamic> payment) async {
    print('⚠️ Boleto vencido: ${payment['id']}');
    
    // Notificar cliente sobre vencimento
  }
}

/// Instruções para configurar no backend:
/// 
/// 1. No seu servidor (APIS_APP), crie um endpoint:
///    POST /api/webhook/asaas
/// 
/// 2. Configure a URL no Asaas:
///    https://seudominio.com/api/webhook/asaas
/// 
/// 3. O endpoint deve processar assim:
/// 
/// app.post('/api/webhook/asaas', (req, res) => {
///   try {
///     const payload = req.body;
///     WebhookHandler.handleWebhook(payload);
///     res.status(200).json({ success: true });
///   } catch (error) {
///     console.error('Erro no webhook:', error);
///     res.status(500).json({ error: 'Erro interno' });
///   }
/// });
/// 
/// 4. Para testar, use o ambiente sandbox do Asaas primeiro
/// 
/// 5. Configure SSL (HTTPS) - o Asaas só envia para URLs seguras