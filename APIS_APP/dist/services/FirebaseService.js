"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseService = void 0;
const admin = __importStar(require("firebase-admin"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
class FirebaseService {
    constructor() {
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
                credential: admin.credential.cert(serviceAccount),
                projectId: process.env.FIREBASE_PROJECT_ID
            });
        }
        else {
            this.app = admin.apps[0];
        }
    }
    static getInstance() {
        if (!FirebaseService.instance) {
            FirebaseService.instance = new FirebaseService();
        }
        return FirebaseService.instance;
    }
    async enviarNotificacao(token, titulo, mensagem, dados) {
        try {
            const payload = {
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
                        priority: 'high',
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
        }
        catch (error) {
            console.error('❌ Erro ao enviar push notification:', error);
            if (error instanceof Error && error.message.includes('invalid-registration-token')) {
                console.log('Token FCM inválido, deve ser removido do banco de dados');
                throw new Error('TOKEN_INVALID');
            }
            throw error;
        }
    }
    async enviarNotificacaoMultipla(tokens, titulo, mensagem, dados) {
        try {
            const payload = {
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
                        priority: 'high',
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
            const failedTokens = [];
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
        }
        catch (error) {
            console.error('❌ Erro ao enviar push notifications múltiplas:', error);
            throw error;
        }
    }
    async verificarTokenValido(token) {
        try {
            await admin.messaging().send({
                token,
                notification: {
                    title: 'Test',
                    body: 'Test'
                }
            }, true);
            return true;
        }
        catch (error) {
            console.log('Token FCM inválido:', token);
            return false;
        }
    }
    async criarTopico(topico, tokens) {
        try {
            await admin.messaging().subscribeToTopic(tokens, topico);
            console.log(`✅ Tokens inscritos no tópico ${topico}`);
        }
        catch (error) {
            console.error(`❌ Erro ao inscrever no tópico ${topico}:`, error);
            throw error;
        }
    }
    async removerDoTopico(topico, tokens) {
        try {
            await admin.messaging().unsubscribeFromTopic(tokens, topico);
            console.log(`✅ Tokens removidos do tópico ${topico}`);
        }
        catch (error) {
            console.error(`❌ Erro ao remover do tópico ${topico}:`, error);
            throw error;
        }
    }
    async enviarParaTopico(topico, titulo, mensagem, dados) {
        try {
            const payload = {
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
                        priority: 'high',
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
        }
        catch (error) {
            console.error(`❌ Erro ao enviar para tópico ${topico}:`, error);
            throw error;
        }
    }
}
exports.FirebaseService = FirebaseService;
//# sourceMappingURL=FirebaseService.js.map