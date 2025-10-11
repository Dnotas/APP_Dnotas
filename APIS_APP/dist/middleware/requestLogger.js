"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requestLogger = void 0;
const requestLogger = (req, res, next) => {
    const start = Date.now();
    const requestInfo = {
        method: req.method,
        url: req.url,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        timestamp: new Date().toISOString()
    };
    if (process.env.NODE_ENV === 'development') {
        console.log(`📝 ${requestInfo.method} ${requestInfo.url} - ${requestInfo.ip}`);
    }
    const originalSend = res.send;
    res.send = function (data) {
        const duration = Date.now() - start;
        const responseInfo = {
            ...requestInfo,
            statusCode: res.statusCode,
            duration: `${duration}ms`,
            contentLength: res.get('Content-Length') || 0
        };
        if (res.statusCode >= 500) {
            console.error(`❌ ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
        }
        else if (res.statusCode >= 400) {
            console.warn(`⚠️  ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
        }
        else if (process.env.NODE_ENV === 'development') {
            console.log(`✅ ${responseInfo.method} ${responseInfo.url} - ${responseInfo.statusCode} - ${responseInfo.duration}`);
        }
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
exports.requestLogger = requestLogger;
//# sourceMappingURL=requestLogger.js.map