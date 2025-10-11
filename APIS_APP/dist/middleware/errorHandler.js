"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const errorHandler = (error, req, res, next) => {
    console.error('🔥 Erro capturado pelo middleware:', {
        message: error.message,
        stack: error.stack,
        url: req.url,
        method: req.method,
        ip: req.ip,
        userAgent: req.get('User-Agent')
    });
    if (error.name === 'ValidationError') {
        res.status(400).json({
            success: false,
            message: 'Dados de entrada inválidos',
            errors: error.message
        });
        return;
    }
    if (error.code === '23505') {
        res.status(409).json({
            success: false,
            message: 'Registro já existe'
        });
        return;
    }
    if (error.code === '23503') {
        res.status(400).json({
            success: false,
            message: 'Referência inválida - registro relacionado não encontrado'
        });
        return;
    }
    if (error.code === '23502') {
        res.status(400).json({
            success: false,
            message: 'Campo obrigatório não fornecido'
        });
        return;
    }
    if (error.code === '42601' || error.code === '42701' || error.code === '42703') {
        res.status(500).json({
            success: false,
            message: 'Erro interno do servidor - consulta SQL inválida'
        });
        return;
    }
    if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
        res.status(503).json({
            success: false,
            message: 'Serviço temporariamente indisponível - erro de conexão com banco de dados'
        });
        return;
    }
    if (error.name === 'JsonWebTokenError') {
        res.status(401).json({
            success: false,
            message: 'Token de acesso inválido'
        });
        return;
    }
    if (error.name === 'TokenExpiredError') {
        res.status(401).json({
            success: false,
            message: 'Token de acesso expirado'
        });
        return;
    }
    if (error.code === 'LIMIT_FILE_SIZE') {
        res.status(413).json({
            success: false,
            message: 'Arquivo muito grande'
        });
        return;
    }
    if (error.code === 'UNSUPPORTED_MEDIA_TYPE') {
        res.status(415).json({
            success: false,
            message: 'Tipo de arquivo não suportado'
        });
        return;
    }
    const status = error.status || error.statusCode || 500;
    if (status < 500) {
        res.status(status).json({
            success: false,
            message: error.message || 'Erro na requisição'
        });
        return;
    }
    res.status(500).json({
        success: false,
        message: process.env.NODE_ENV === 'production'
            ? 'Erro interno do servidor'
            : error.message,
        ...(process.env.NODE_ENV === 'development' && {
            stack: error.stack,
            details: error
        })
    });
};
exports.errorHandler = errorHandler;
//# sourceMappingURL=errorHandler.js.map