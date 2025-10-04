import { Request, Response, NextFunction } from 'express';

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();
  
  // Capturar dados da requisição
  const requestInfo = {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  };

  // Log da requisição (apenas em desenvolvimento)
  if (process.env.NODE_ENV === 'development') {
    console.log(`📝 ${requestInfo.method} ${requestInfo.url} - ${requestInfo.ip}`);
  }

  // Interceptar a resposta
  const originalSend = res.send;
  res.send = function(data) {
    const duration = Date.now() - start;
    
    // Log da resposta
    const responseInfo = {
      ...requestInfo,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      contentLength: res.get('Content-Length') || 0
    };

    // Diferentes níveis de log baseado no status
    if (res.statusCode >= 500) {
      console.error(`❌ ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
    } else if (res.statusCode >= 400) {
      console.warn(`⚠️  ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
    } else if (process.env.NODE_ENV === 'development') {
      console.log(`✅ ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
    }

    // Log detalhado para rotas de API em desenvolvimento
    if (process.env.NODE_ENV === 'development' && req.url.startsWith('/api/')) {
      console.log(`📊 API Call Details:`, {
        endpoint: `${requestInfo.method} ${requestInfo.url}`,
        status: res.statusCode,
        duration: responseInfo.duration,
        userAgent: requestInfo.userAgent,
        ip: requestInfo.ip
      });
    }

    return originalSend.call(this, data);
  };

  next();
};