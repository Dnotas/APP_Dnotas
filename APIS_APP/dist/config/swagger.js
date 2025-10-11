"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.swaggerSpec = void 0;
const swagger_jsdoc_1 = __importDefault(require("swagger-jsdoc"));
const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'DNOTAS API',
            version: '1.0.0',
            description: 'API Backend para DNOTAS APP - Sistema de comunicação e gestão fiscal',
            contact: {
                name: 'DNOTAS Team',
                email: 'dev@dnotas.com'
            }
        },
        servers: [
            {
                url: process.env.NODE_ENV === 'production'
                    ? 'https://api.dnotas.com'
                    : 'http://localhost:3000',
                description: process.env.NODE_ENV === 'production'
                    ? 'Servidor de Produção'
                    : 'Servidor de Desenvolvimento'
            }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                    description: 'Token JWT obtido através do endpoint de login'
                }
            },
            schemas: {
                Error: {
                    type: 'object',
                    properties: {
                        success: {
                            type: 'boolean',
                            example: false
                        },
                        message: {
                            type: 'string',
                            example: 'Mensagem de erro'
                        },
                        errors: {
                            type: 'array',
                            items: {
                                type: 'string'
                            }
                        }
                    }
                },
                User: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'uuid'
                        },
                        cnpj: {
                            type: 'string',
                            pattern: '^\\d{14}$'
                        },
                        nome: {
                            type: 'string'
                        },
                        email: {
                            type: 'string',
                            format: 'email'
                        },
                        telefone: {
                            type: 'string'
                        },
                        filial_id: {
                            type: 'string'
                        },
                        filial_nome: {
                            type: 'string'
                        },
                        ativo: {
                            type: 'boolean'
                        },
                        ultimo_acesso: {
                            type: 'string',
                            format: 'date-time'
                        },
                        created_at: {
                            type: 'string',
                            format: 'date-time'
                        },
                        updated_at: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                RelatorioVendas: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'uuid'
                        },
                        cliente_cnpj: {
                            type: 'string',
                            pattern: '^\\d{14}$'
                        },
                        filial_id: {
                            type: 'string'
                        },
                        data_relatorio: {
                            type: 'string',
                            format: 'date'
                        },
                        vendas_debito: {
                            type: 'number',
                            format: 'decimal'
                        },
                        vendas_credito: {
                            type: 'number',
                            format: 'decimal'
                        },
                        vendas_dinheiro: {
                            type: 'number',
                            format: 'decimal'
                        },
                        vendas_pix: {
                            type: 'number',
                            format: 'decimal'
                        },
                        vendas_vale: {
                            type: 'number',
                            format: 'decimal'
                        },
                        total_vendas: {
                            type: 'number',
                            format: 'decimal'
                        },
                        created_at: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                Boleto: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'uuid'
                        },
                        cliente_cnpj: {
                            type: 'string',
                            pattern: '^\\d{14}$'
                        },
                        filial_id: {
                            type: 'string'
                        },
                        numero_boleto: {
                            type: 'string'
                        },
                        valor: {
                            type: 'number',
                            format: 'decimal'
                        },
                        data_vencimento: {
                            type: 'string',
                            format: 'date'
                        },
                        data_pagamento: {
                            type: 'string',
                            format: 'date-time',
                            nullable: true
                        },
                        status: {
                            type: 'string',
                            enum: ['pendente', 'pago', 'vencido', 'cancelado']
                        },
                        linha_digitavel: {
                            type: 'string'
                        },
                        codigo_barras: {
                            type: 'string'
                        },
                        created_at: {
                            type: 'string',
                            format: 'date-time'
                        },
                        updated_at: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                Notification: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'uuid'
                        },
                        cliente_cnpj: {
                            type: 'string',
                            pattern: '^\\d{14}$'
                        },
                        filial_id: {
                            type: 'string'
                        },
                        tipo: {
                            type: 'string',
                            enum: ['relatorio', 'boleto', 'inatividade', 'geral']
                        },
                        titulo: {
                            type: 'string'
                        },
                        mensagem: {
                            type: 'string'
                        },
                        lida: {
                            type: 'boolean'
                        },
                        data_envio: {
                            type: 'string',
                            format: 'date-time'
                        },
                        created_at: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                Pagination: {
                    type: 'object',
                    properties: {
                        page: {
                            type: 'integer',
                            minimum: 1
                        },
                        limit: {
                            type: 'integer',
                            minimum: 1
                        },
                        total: {
                            type: 'integer',
                            minimum: 0
                        },
                        totalPages: {
                            type: 'integer',
                            minimum: 0
                        }
                    }
                }
            }
        },
        security: [
            {
                bearerAuth: []
            }
        ],
        tags: [
            {
                name: 'Autenticação',
                description: 'Endpoints de autenticação e autorização'
            },
            {
                name: 'Relatórios',
                description: 'Endpoints para gestão de relatórios de vendas'
            },
            {
                name: 'Financeiro',
                description: 'Endpoints para gestão financeira e boletos'
            },
            {
                name: 'Notificações',
                description: 'Endpoints para sistema de notificações'
            }
        ]
    },
    apis: [
        './src/routes/*.ts',
        './src/controllers/*.ts'
    ]
};
exports.swaggerSpec = (0, swagger_jsdoc_1.default)(options);
//# sourceMappingURL=swagger.js.map