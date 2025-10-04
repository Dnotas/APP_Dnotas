import * as admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

export class FirebaseService {
  private static instance: FirebaseService;
  private app: admin.app.App;

  private constructor() {
    if (!admin.apps.length) {
      const serviceAccount = {
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKeyId: process.env.FIREBASE_PRIVATE_KEY_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        clientId: process.env.FIREBASE_CLIENT_ID,
        authUri: process.env.FIREBASE_AUTH_URI,
        tokenUri: process.env.FIREBASE_TOKEN_URI,
      };

      this.app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID
      });
    } else {
      this.app = admin.apps[0]!;
    }
  }

  public static getInstance(): FirebaseService {
    if (!FirebaseService.instance) {
      FirebaseService.instance = new FirebaseService();
    }
    return FirebaseService.instance;
  }

  async enviarNotificacao(
    token: string,
    titulo: string,
    mensagem: string,
    dados?: Record<string, string>
  ): Promise<void> {
    try {
      const payload: admin.messaging.Message = {
        token,
        notification: {
          title: titulo,
          body: mensagem,
        },
        data: {
          tipo: 'notification',
          timestamp: new Date().toISOString(),
          ...dados
        },
        android: {
          notification: {
            channelId: 'dnotas_notifications',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
            color: '#1976D2'
          },
          priority: 'high'
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              alert: {
                title: titulo,
                body: mensagem
              }
            }
          },
          headers: {
            'apns-priority': '10'
          }
        }
      };

      const response = await admin.messaging().send(payload);
      console.log('✅ Push notification enviada com sucesso:', response);
    } catch (error) {
      console.error('❌ Erro ao enviar push notification:', error);
      
      // Se o token for inválido, podemos removê-lo do banco
      if (error instanceof Error && error.message.includes('invalid-registration-token')) {
        console.log('Token FCM inválido, deve ser removido do banco de dados');
        throw new Error('TOKEN_INVALID');
      }
      
      throw error;
    }
  }

  async enviarNotificacaoMultipla(
    tokens: string[],
    titulo: string,
    mensagem: string,
    dados?: Record<string, string>
  ): Promise<{
    successCount: number;
    failureCount: number;
    failedTokens: string[];
  }> {
    try {
      const payload: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title: titulo,
          body: mensagem,
        },
        data: {
          tipo: 'notification',
          timestamp: new Date().toISOString(),
          ...dados
        },
        android: {
          notification: {
            channelId: 'dnotas_notifications',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
            color: '#1976D2'
          },
          priority: 'high'
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              alert: {
                title: titulo,
                body: mensagem
              }
            }
          },
          headers: {
            'apns-priority': '10'
          }
        }
      };

      const response = await admin.messaging().sendMulticast(payload);
      
      // Extrair tokens que falharam
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
        }
      });

      console.log(`✅ Push notifications enviadas: ${response.successCount} sucessos, ${response.failureCount} falhas`);

      return {
        successCount: response.successCount,
        failureCount: response.failureCount,
        failedTokens
      };
    } catch (error) {
      console.error('❌ Erro ao enviar push notifications múltiplas:', error);
      throw error;
    }
  }

  async verificarTokenValido(token: string): Promise<boolean> {
    try {
      // Tenta enviar uma mensagem de teste (dry run)
      await admin.messaging().send({
        token,
        notification: {
          title: 'Test',
          body: 'Test'
        }
      }, true); // dry run = true

      return true;
    } catch (error) {
      console.log('Token FCM inválido:', token);
      return false;
    }
  }

  async criarTopico(topico: string, tokens: string[]): Promise<void> {
    try {
      await admin.messaging().subscribeToTopic(tokens, topico);
      console.log(`✅ Tokens inscritos no tópico ${topico}`);
    } catch (error) {
      console.error(`❌ Erro ao inscrever no tópico ${topico}:`, error);
      throw error;
    }
  }

  async removerDoTopico(topico: string, tokens: string[]): Promise<void> {
    try {
      await admin.messaging().unsubscribeFromTopic(tokens, topico);
      console.log(`✅ Tokens removidos do tópico ${topico}`);
    } catch (error) {
      console.error(`❌ Erro ao remover do tópico ${topico}:`, error);
      throw error;
    }
  }

  async enviarParaTopico(
    topico: string,
    titulo: string,
    mensagem: string,
    dados?: Record<string, string>
  ): Promise<void> {
    try {
      const payload: admin.messaging.Message = {
        topic: topico,
        notification: {
          title: titulo,
          body: mensagem,
        },
        data: {
          tipo: 'topic_notification',
          timestamp: new Date().toISOString(),
          ...dados
        },
        android: {
          notification: {
            channelId: 'dnotas_notifications',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
            color: '#1976D2'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              alert: {
                title: titulo,
                body: mensagem
              }
            }
          }
        }
      };

      const response = await admin.messaging().send(payload);
      console.log(`✅ Notificação enviada para tópico ${topico}:`, response);
    } catch (error) {
      console.error(`❌ Erro ao enviar para tópico ${topico}:`, error);
      throw error;
    }
  }
}