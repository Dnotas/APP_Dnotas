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
const swagger_ui_express_1 = __importDefault(require("swagger-ui-express"));
const dotenv_1 = __importDefault(require("dotenv"));
const errorHandler_1 = require("./middleware/errorHandler");
const requestLogger_1 = require("./middleware/requestLogger");
const authRoutes_1 = require("./routes/authRoutes");
const reportsRoutes_1 = require("./routes/reportsRoutes");
const financialRoutes_1 = require("./routes/financialRoutes");
const notificationsRoutes_1 = require("./routes/notificationsRoutes");
const DatabaseService_1 = require("./services/DatabaseService");
const swagger_1 = require("./config/swagger");
const cronJobs_1 = require("./config/cronJobs");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
const limiter = (0, express_rate_limit_1.default)({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: 'Muitas requisições deste IP, tente novamente em 15 minutos.',
    standardHeaders: true,
    legacyHeaders: false,
});
app.use((0, helmet_1.default)());
app.use((0, compression_1.default)());
app.use((0, cors_1.default)({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true
}));
app.use(limiter);
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
app.use(requestLogger_1.requestLogger);
app.use('/api-docs', swagger_ui_express_1.default.serve, swagger_ui_express_1.default.setup(swagger_1.swaggerSpec));
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV
    });
});
app.use('/api/auth', authRoutes_1.authRoutes);
app.use('/api/reports', reportsRoutes_1.reportsRoutes);
app.use('/api/financial', financialRoutes_1.financialRoutes);
app.use('/api/notifications', notificationsRoutes_1.notificationsRoutes);
app.use(errorHandler_1.errorHandler);
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Endpoint não encontrado',
        path: req.originalUrl
    });
});
async function startServer() {
    try {
        await DatabaseService_1.DatabaseService.initialize();
        console.log('✅ Conexão com banco de dados estabelecida');
        const cronJobs = new cronJobs_1.CronJobs();
        cronJobs.initializeCronJobs();
        app.listen(PORT, () => {
            console.log(`🚀 Servidor rodando na porta ${PORT}`);
            console.log(`📚 Documentação disponível em http://localhost:${PORT}/api-docs`);
            console.log(`🏥 Health check em http://localhost:${PORT}/health`);
        });
    }
    catch (error) {
        console.error('❌ Erro ao inicializar servidor:', error);
        process.exit(1);
    }
}
process.on('SIGTERM', async () => {
    console.log('🔄 Iniciando graceful shutdown...');
    await DatabaseService_1.DatabaseService.close();
    process.exit(0);
});
process.on('SIGINT', async () => {
    console.log('🔄 Iniciando graceful shutdown...');
    await DatabaseService_1.DatabaseService.close();
    process.exit(0);
});
startServer();
//# sourceMappingURL=server.js.map