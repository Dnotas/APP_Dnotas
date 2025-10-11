"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const DatabaseService_1 = require("../services/DatabaseService");
const authMiddleware = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        if (!token) {
            res.status(401).json({
                success: false,
                message: 'Token de acesso não fornecido'
            });
            return;
        }
        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            throw new Error('JWT_SECRET não configurado');
        }
        const decoded = jsonwebtoken_1.default.verify(token, jwtSecret);
        const db = DatabaseService_1.DatabaseService.getInstance();
        const query = `
      SELECT u.*, f.nome as filial_nome 
      FROM users u
      JOIN filiais f ON u.filial_id = f.id
      WHERE u.id = $1 AND u.ativo = true
    `;
        const result = await db.query(query, [decoded.userId]);
        if (result.rows.length === 0) {
            res.status(401).json({
                success: false,
                message: 'Usuário não encontrado ou inativo'
            });
            return;
        }
        const user = result.rows[0];
        await db.query('UPDATE users SET ultimo_acesso = CURRENT_TIMESTAMP WHERE id = $1', [user.id]);
        req.user = user;
        next();
    }
    catch (error) {
        console.error('Erro na autenticação:', error);
        if (error instanceof jsonwebtoken_1.default.JsonWebTokenError) {
            res.status(401).json({
                success: false,
                message: 'Token inválido'
            });
            return;
        }
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            res.status(401).json({
                success: false,
                message: 'Token expirado'
            });
            return;
        }
        res.status(500).json({
            success: false,
            message: 'Erro interno do servidor'
        });
    }
};
exports.authMiddleware = authMiddleware;
//# sourceMappingURL=authMiddleware.js.map