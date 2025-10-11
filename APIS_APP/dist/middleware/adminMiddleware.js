"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminMiddleware = void 0;
const adminMiddleware = (req, res, next) => {
    try {
        if (!req.user) {
            res.status(401).json({
                success: false,
                message: 'Usuário não autenticado'
            });
            return;
        }
        const isAdmin = req.user.filial_id === 'matriz' || req.headers['x-admin-key'] === process.env.ADMIN_KEY;
        if (!isAdmin) {
            res.status(403).json({
                success: false,
                message: 'Acesso negado - privilégios de administrador necessários'
            });
            return;
        }
        next();
    }
    catch (error) {
        console.error('Erro na verificação de administrador:', error);
        res.status(500).json({
            success: false,
            message: 'Erro interno do servidor'
        });
    }
};
exports.adminMiddleware = adminMiddleware;
//# sourceMappingURL=adminMiddleware.js.map