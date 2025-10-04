import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import swaggerUi from 'swagger-ui-express';
import dotenv from 'dotenv';

import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import { authRoutes } from './routes/authRoutes';
import { reportsRoutes } from './routes/reportsRoutes';
import { financialRoutes } from './routes/financialRoutes';
import { notificationsRoutes } from './routes/notificationsRoutes';
import { DatabaseService } from './services/DatabaseService';
import { swaggerSpec } from './config/swagger';
import { CronJobs } from './config/cronJobs';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: 'Muitas requisições deste IP, tente novamente em 15 minutos.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Middlewares globais
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));
app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(requestLogger);

// Documentação da API
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});

// Rotas principais
app.use('/api/auth', authRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/financial', financialRoutes);
app.use('/api/notifications', notificationsRoutes);

// Middleware de tratamento de erros
app.use(errorHandler);

// Rota 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint não encontrado',
    path: req.originalUrl
  });
});

// Inicialização do servidor
async function startServer() {
  try {
    // Inicializar conexão com banco de dados
    await DatabaseService.initialize();
    console.log('✅ Conexão com banco de dados estabelecida');

    // Inicializar tarefas agendadas
    const cronJobs = new CronJobs();
    cronJobs.initializeCronJobs();

    app.listen(PORT, () => {
      console.log(`🚀 Servidor rodando na porta ${PORT}`);
      console.log(`📚 Documentação disponível em http://localhost:${PORT}/api-docs`);
      console.log(`🏥 Health check em http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('❌ Erro ao inicializar servidor:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🔄 Iniciando graceful shutdown...');
  await DatabaseService.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🔄 Iniciando graceful shutdown...');
  await DatabaseService.close();
  process.exit(0);
});

startServer();