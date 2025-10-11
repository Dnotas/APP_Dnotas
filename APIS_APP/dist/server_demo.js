"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const compression_1 = __importDefault(require("compression"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
const limiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: 'Muitas requisições deste IP, tente novamente em 15 minutos.',
});
app.use((0, helmet_1.default)());
app.use((0, compression_1.default)());
app.use((0, cors_1.default)({
    origin: ['http://localhost:3000', 'http://localhost:3001', 'http://127.0.0.1:3000'],
    credentials: true
}));
app.use(limiter);
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
    next();
});
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV
    });
});
const mockTransactions = [
    {
        id: '1',
        description: 'Zara Tha',
        amount: 1856.78,
        type: 'received',
        date: new Date().toISOString(),
        category: 'Vendas'
    },
    {
        id: '2',
        description: 'Received',
        amount: 100.00,
        type: 'received',
        date: new Date(Date.now() - 86400000).toISOString(),
        category: 'Transferência'
    }
];
const mockBoletos = [
    {
        id: '1',
        numero: '00001',
        descricao: 'Mensalidade - Dezembro 2024',
        valor: 850.00,
        data_vencimento: new Date(Date.now() + 5 * 86400000).toISOString(),
        status: 'pendente',
        codigo_barras: '34191.79001 01043.510047 91020.150008 1 85420000085000'
    },
    {
        id: '2',
        numero: '00002',
        descricao: 'Taxa de Serviços - Novembro 2024',
        valor: 450.00,
        data_vencimento: new Date(Date.now() - 10 * 86400000).toISOString(),
        status: 'vencido',
        codigo_barras: '34191.79001 01043.510047 91020.150008 2 85420000045000'
    }
];
const mockMessages = [
    {
        id: '1',
        content: 'Olá! Como podemos ajudá-lo hoje?',
        sender_id: 'support',
        sender_name: 'Suporte DNOTAS',
        timestamp: new Date(Date.now() - 2 * 3600000).toISOString(),
        is_from_client: false
    },
    {
        id: '2',
        content: 'Preciso do relatório de vendas do mês passado',
        sender_id: 'client',
        sender_name: 'Você',
        timestamp: new Date(Date.now() - 90 * 60000).toISOString(),
        is_from_client: true
    }
];
app.get('/api/reports', (req, res) => {
    const totalBalance = 36400.12;
    const dailySales = mockTransactions.reduce((sum, t) => sum + t.amount, 0);
    res.json({
        success: true,
        data: {
            transactions: mockTransactions,
            balance: totalBalance,
            daily_sales: dailySales
        }
    });
});
app.get('/api/financial', (req, res) => {
    res.json({
        success: true,
        data: mockBoletos
    });
});
app.get('/api/chat/messages', (req, res) => {
    res.json({
        success: true,
        data: mockMessages
    });
});
app.post('/api/chat/send', (req, res) => {
    const { message } = req.body;
    const newMessage = {
        id: Date.now().toString(),
        content: message,
        sender_id: 'client',
        sender_name: 'Cliente',
        timestamp: new Date().toISOString(),
        is_from_client: true
    };
    const responses = [
        'Recebido! Vou verificar isso para você.',
        'Obrigado pela mensagem. Em breve retornamos.',
        'Entendi. Nossa equipe está analisando.',
        'Perfeito! Vou providenciar as informações.'
    ];
    const autoResponse = {
        id: (Date.now() + 1).toString(),
        content: responses[Math.floor(Math.random() * responses.length)],
        sender_id: 'support',
        sender_name: 'Suporte DNOTAS',
        timestamp: new Date(Date.now() + 2000).toISOString(),
        is_from_client: false
    };
    res.json({
        success: true,
        message: 'Mensagem enviada com sucesso',
        data: {
            sent: newMessage,
            response: autoResponse
        }
    });
});
app.post('/api/auth/login', (req, res) => {
    const { cnpj, password } = req.body;
    if (cnpj && password) {
        res.json({
            success: true,
            message: 'Login realizado com sucesso',
            data: {
                user: {
                    cnpj,
                    nome_empresa: 'Empresa Teste LTDA',
                    email: 'teste@empresa.com',
                    filial_id: 'matriz'
                },
                token: 'mock_jwt_token_' + Date.now()
            }
        });
    }
    else {
        res.status(400).json({
            success: false,
            message: 'CNPJ e senha são obrigatórios'
        });
    }
});
app.use((err, req, res, next) => {
    console.error('Erro:', err);
    res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
    });
});
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Endpoint não encontrado',
        path: req.originalUrl
    });
});
app.listen(PORT, () => {
    console.log(`🚀 Servidor Demo DNOTAS rodando na porta ${PORT}`);
    console.log(`🏥 Health check em http://localhost:${PORT}/health`);
    console.log(`📱 API endpoints:`);
    console.log(`   - GET  /api/reports - Relatórios e transações`);
    console.log(`   - GET  /api/financial - Boletos e financeiro`);
    console.log(`   - GET  /api/chat/messages - Mensagens do chat`);
    console.log(`   - POST /api/chat/send - Enviar mensagem`);
    console.log(`   - POST /api/auth/login - Login`);
});
process.on('SIGTERM', () => {
    console.log('🔄 Iniciando graceful shutdown...');
    process.exit(0);
});
process.on('SIGINT', () => {
    console.log('🔄 Iniciando graceful shutdown...');
    process.exit(0);
});
//# sourceMappingURL=server_demo.js.map