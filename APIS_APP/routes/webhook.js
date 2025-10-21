const express = require('express');
const router = express.Router();
const crypto = require('crypto');

// Middleware para capturar o body raw para validação de webhook
const rawBodySaver = (req, res, next) => {
  req.rawBody = '';
  req.setEncoding('utf8');

  req.on('data', (chunk) => {
    req.rawBody += chunk;
  });

  req.on('end', () => {
    next();
  });
};

/**
 * Endpoint para receber webhooks do Asaas
 * POST /api/webhook/asaas
 */
router.post('/asaas', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    console.log('📥 Webhook Asaas recebido');
    
    // Parse do payload
    const payload = JSON.parse(req.body.toString());
    console.log('Payload:', JSON.stringify(payload, null, 2));

    // Validar estrutura básica do payload
    if (!payload.event || !payload.payment) {
      console.log('❌ Payload inválido - faltam campos obrigatórios');
      return res.status(400).json({ error: 'Payload inválido' });
    }

    // Processar o webhook
    await processAsaasWebhook(payload);

    // Responder sucesso para o Asaas
    res.status(200).json({ 
      success: true, 
      message: 'Webhook processado com sucesso',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro ao processar webhook Asaas:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      message: error.message 
    });
  }
});

/**
 * Processar o webhook do Asaas
 */
async function processAsaasWebhook(payload) {
  const { event, payment } = payload;
  
  console.log(`🔔 Processando evento: ${event} para pagamento: ${payment.id}`);

  switch (event) {
    case 'PAYMENT_CREATED':
      await handlePaymentCreated(payment);
      break;
    
    case 'PAYMENT_UPDATED':
      await handlePaymentUpdated(payment);
      break;
    
    case 'PAYMENT_CONFIRMED':
    case 'PAYMENT_RECEIVED':
    case 'PAYMENT_RECEIVED_IN_CASH':
      await handlePaymentReceived(payment);
      break;
    
    case 'PAYMENT_OVERDUE':
      await handlePaymentOverdue(payment);
      break;
    
    case 'PAYMENT_DELETED':
      await handlePaymentDeleted(payment);
      break;
    
    case 'PAYMENT_REFUNDED':
      await handlePaymentRefunded(payment);
      break;

    default:
      console.log(`⚠️ Evento não tratado: ${event}`);
  }
}

/**
 * Novo boleto criado
 */
async function handlePaymentCreated(payment) {
  try {
    console.log(`💰 Novo boleto criado: ${payment.id}`);
    
    // 1. Buscar dados do cliente
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) {
      console.log(`❌ Cliente não encontrado: ${payment.customer}`);
      return;
    }

    // 2. Salvar boleto no banco de dados local (se necessário)
    await saveBoletoLocally(payment, customer);

    // 3. Enviar notificação push para o cliente
    await sendPushNotification(customer.cnpj, {
      title: '💰 Novo Boleto Disponível',
      body: `R$ ${payment.value.toFixed(2).replace('.', ',')} - Vence em ${formatDate(payment.dueDate)}`,
      data: {
        type: 'new_boleto',
        boleto_id: payment.id,
        customer_id: payment.customer,
        value: payment.value,
        due_date: payment.dueDate
      }
    });

    // 4. Log para auditoria
    console.log(`✅ Notificação enviada para cliente ${customer.cnpj} - Boleto ${payment.id}`);

  } catch (error) {
    console.error(`❌ Erro ao processar novo boleto ${payment.id}:`, error);
  }
}

/**
 * Boleto atualizado
 */
async function handlePaymentUpdated(payment) {
  try {
    console.log(`🔄 Boleto atualizado: ${payment.id}`);
    
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) return;

    // Atualizar dados locais
    await updateBoletoLocally(payment);

    // Notificar apenas se mudança significativa (valor, data, etc.)
    await sendPushNotification(customer.cnpj, {
      title: '🔄 Boleto Atualizado',
      body: `Boleto ${payment.id} foi atualizado`,
      data: {
        type: 'boleto_updated',
        boleto_id: payment.id
      }
    });

  } catch (error) {
    console.error(`❌ Erro ao processar atualização do boleto ${payment.id}:`, error);
  }
}

/**
 * Boleto pago/recebido
 */
async function handlePaymentReceived(payment) {
  try {
    console.log(`✅ Boleto pago: ${payment.id}`);
    
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) return;

    await updateBoletoLocally(payment);

    await sendPushNotification(customer.cnpj, {
      title: '✅ Pagamento Confirmado',
      body: `Boleto de R$ ${payment.value.toFixed(2).replace('.', ',')} foi pago`,
      data: {
        type: 'payment_confirmed',
        boleto_id: payment.id,
        value: payment.value
      }
    });

  } catch (error) {
    console.error(`❌ Erro ao processar pagamento do boleto ${payment.id}:`, error);
  }
}

/**
 * Boleto vencido
 */
async function handlePaymentOverdue(payment) {
  try {
    console.log(`⚠️ Boleto vencido: ${payment.id}`);
    
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) return;

    await updateBoletoLocally(payment);

    await sendPushNotification(customer.cnpj, {
      title: '🚨 Boleto Vencido',
      body: `Boleto de R$ ${payment.value.toFixed(2).replace('.', ',')} venceu`,
      data: {
        type: 'payment_overdue',
        boleto_id: payment.id,
        value: payment.value,
        due_date: payment.dueDate
      }
    });

  } catch (error) {
    console.error(`❌ Erro ao processar vencimento do boleto ${payment.id}:`, error);
  }
}

/**
 * Boleto deletado
 */
async function handlePaymentDeleted(payment) {
  try {
    console.log(`🗑️ Boleto deletado: ${payment.id}`);
    
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) return;

    await deleteBoletoLocally(payment.id);

    await sendPushNotification(customer.cnpj, {
      title: '🗑️ Boleto Cancelado',
      body: `Boleto ${payment.id} foi cancelado`,
      data: {
        type: 'payment_deleted',
        boleto_id: payment.id
      }
    });

  } catch (error) {
    console.error(`❌ Erro ao processar exclusão do boleto ${payment.id}:`, error);
  }
}

/**
 * Boleto estornado
 */
async function handlePaymentRefunded(payment) {
  try {
    console.log(`💸 Boleto estornado: ${payment.id}`);
    
    const customer = await findCustomerByCnpj(payment.customer);
    if (!customer) return;

    await updateBoletoLocally(payment);

    await sendPushNotification(customer.cnpj, {
      title: '💸 Pagamento Estornado',
      body: `Estorno de R$ ${payment.value.toFixed(2).replace('.', ',')} processado`,
      data: {
        type: 'payment_refunded',
        boleto_id: payment.id,
        value: payment.value
      }
    });

  } catch (error) {
    console.error(`❌ Erro ao processar estorno do boleto ${payment.id}:`, error);
  }
}

/**
 * Funções auxiliares (implementar conforme sua arquitetura)
 */

// Buscar cliente pelo CNPJ (implementar conforme seu banco de dados)
async function findCustomerByCnpj(customerAsaasId) {
  // Implementar busca no seu banco de dados
  // Exemplo com PostgreSQL:
  /*
  const { Pool } = require('pg');
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  
  const result = await pool.query(
    'SELECT * FROM clientes WHERE asaas_customer_id = $1',
    [customerAsaasId]
  );
  
  return result.rows[0];
  */
  
  // Por enquanto, retorna um mock
  return {
    id: customerAsaasId,
    cnpj: '12345678000195', // Buscar CNPJ real do banco
    nome_empresa: 'Empresa Exemplo'
  };
}

// Salvar boleto no banco local
async function saveBoletoLocally(payment, customer) {
  // Implementar salvamento no banco de dados
  console.log(`💾 Salvando boleto ${payment.id} localmente`);
}

// Atualizar boleto no banco local
async function updateBoletoLocally(payment) {
  // Implementar atualização no banco de dados
  console.log(`🔄 Atualizando boleto ${payment.id} localmente`);
}

// Deletar boleto do banco local
async function deleteBoletoLocally(paymentId) {
  // Implementar exclusão do banco de dados
  console.log(`🗑️ Deletando boleto ${paymentId} localmente`);
}

// Enviar notificação push
async function sendPushNotification(customerCnpj, notification) {
  try {
    // Implementar envio de notificação usando Firebase Admin SDK
    console.log(`📤 Enviando notificação para ${customerCnpj}:`, notification);
    
    // Exemplo com Firebase Admin:
    /*
    const admin = require('firebase-admin');
    
    // Buscar token FCM do cliente
    const fcmToken = await getFCMToken(customerCnpj);
    
    if (fcmToken) {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: notification.data,
        token: fcmToken
      };
      
      const response = await admin.messaging().send(message);
      console.log('✅ Notificação enviada:', response);
    }
    */
    
  } catch (error) {
    console.error('❌ Erro ao enviar notificação:', error);
  }
}

// Formatar data
function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('pt-BR');
}

// Endpoint para testar o webhook (desenvolvimento)
router.post('/test', async (req, res) => {
  try {
    const testPayload = {
      event: 'PAYMENT_CREATED',
      payment: {
        id: 'pay_test_123',
        customer: 'cus_test_123',
        value: 150.00,
        dueDate: '2024-01-30',
        status: 'PENDING',
        description: 'Teste de webhook',
        billingType: 'BOLETO'
      }
    };

    await processAsaasWebhook(testPayload);
    
    res.json({ 
      success: true, 
      message: 'Webhook de teste processado com sucesso' 
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;