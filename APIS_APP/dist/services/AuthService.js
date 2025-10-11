"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const crypto_1 = __importDefault(require("crypto"));
const SupabaseService_1 = require("./SupabaseService");
class AuthService {
    constructor() {
        this.supabase = SupabaseService_1.SupabaseService.getInstance();
    }
    async login(cnpj, senha, fcm_token) {
        try {
            const { data: cliente, error } = await this.supabase.getClienteByCnpj(cnpj);
            if (error || !cliente || !cliente.is_active) {
                throw new Error('Credenciais inválidas');
            }
            const senhaValida = await bcryptjs_1.default.compare(senha, cliente.senha);
            if (!senhaValida) {
                throw new Error('Credenciais inválidas');
            }
            const updateData = { last_login: new Date().toISOString() };
            if (fcm_token) {
                updateData.fcm_token = fcm_token;
            }
            await this.supabase.executeQuery('clientes', 'update', updateData, { id: cliente.id });
            const token = this.generateToken(cliente.id);
            const { senha: _, ...userSemSenha } = cliente;
            return {
                token,
                expiresIn: process.env.JWT_EXPIRES_IN || '24h',
                user: userSemSenha
            };
        }
        catch (error) {
            throw new Error('Erro no login: ' + error.message);
        }
    }
    async register(data) {
        const { cnpj, nome_empresa, email, telefone, senha, filial_id, fcm_token } = data;
        const existingUser = await this.db.query('SELECT id FROM clientes WHERE cnpj = $1 OR email = $2', [cnpj, email]);
        if (existingUser.rows.length > 0) {
            throw new Error('Cliente com este CNPJ ou email já existe');
        }
        const filialExists = await this.db.exists('filiais', 'id = $1 AND ativo = true', [filial_id]);
        if (!filialExists) {
            throw new Error('Filial não encontrada');
        }
        const senhaHash = await bcryptjs_1.default.hash(senha, 12);
        const insertQuery = `
      INSERT INTO clientes (cnpj, nome_empresa, email, telefone, senha, filial_id, fcm_token, is_active)
      VALUES ($1, $2, $3, $4, $5, $6, $7, true)
      RETURNING id, cnpj, nome_empresa, email, telefone, filial_id, is_active, created_at
    `;
        const insertParams = [cnpj, nome_empresa, email, telefone, senhaHash, filial_id, fcm_token || null];
        const result = await this.db.query(insertQuery, insertParams);
        const newUser = result.rows[0];
        const userQuery = `
      SELECT c.*, f.nome as filial_nome 
      FROM clientes c
      JOIN filiais f ON c.filial_id = f.id
      WHERE c.id = $1
    `;
        const userResult = await this.db.query(userQuery, [newUser.id]);
        const user = userResult.rows[0];
        const token = this.generateToken(user.id);
        const { senha: _, ...userSemSenha } = user;
        return {
            token,
            expiresIn: process.env.JWT_EXPIRES_IN || '24h',
            user: userSemSenha
        };
    }
    async refreshToken(currentToken) {
        try {
            const jwtSecret = process.env.JWT_SECRET;
            if (!jwtSecret) {
                throw new Error('JWT_SECRET não configurado');
            }
            const decoded = jsonwebtoken_1.default.verify(currentToken, jwtSecret, { ignoreExpiration: true });
            const query = `
        SELECT c.*, f.nome as filial_nome 
        FROM clientes c
        JOIN filiais f ON c.filial_id = f.id
        WHERE c.id = $1 AND c.is_active = true
      `;
            const result = await this.db.query(query, [decoded.userId]);
            if (result.rows.length === 0) {
                throw new Error('Usuário não encontrado');
            }
            const user = result.rows[0];
            const token = this.generateToken(user.id);
            const { senha: _, ...userSemSenha } = user;
            return {
                token,
                expiresIn: process.env.JWT_EXPIRES_IN || '24h',
                user: userSemSenha
            };
        }
        catch (error) {
            throw new Error('Token inválido');
        }
    }
    async logout(token) {
        try {
            const jwtSecret = process.env.JWT_SECRET;
            if (!jwtSecret) {
                throw new Error('JWT_SECRET não configurado');
            }
            jsonwebtoken_1.default.verify(token, jwtSecret);
        }
        catch (error) {
            throw new Error('Token inválido');
        }
    }
    async forgotPassword(cnpj, email) {
        const query = 'SELECT id, email FROM clientes WHERE cnpj = $1 AND email = $2 AND is_active = true';
        const result = await this.db.query(query, [cnpj, email]);
        if (result.rows.length === 0) {
            return;
        }
        const user = result.rows[0];
        const resetToken = crypto_1.default.randomBytes(32).toString('hex');
        const resetTokenExpiry = new Date();
        resetTokenExpiry.setHours(resetTokenExpiry.getHours() + 1);
        await this.db.query('UPDATE clientes SET reset_token = $1, reset_token_expiry = $2 WHERE id = $3', [resetToken, resetTokenExpiry, user.id]);
        console.log(`🔑 Token de recuperação para ${email}: ${resetToken}`);
    }
    async resetPassword(token, novaSenha) {
        const query = `
      SELECT id FROM clientes 
      WHERE reset_token = $1 
      AND reset_token_expiry > CURRENT_TIMESTAMP 
      AND is_active = true
    `;
        const result = await this.db.query(query, [token]);
        if (result.rows.length === 0) {
            throw new Error('Token inválido ou expirado');
        }
        const user = result.rows[0];
        const senhaHash = await bcryptjs_1.default.hash(novaSenha, 12);
        await this.db.query(`UPDATE clientes 
       SET senha = $1, reset_token = NULL, reset_token_expiry = NULL
       WHERE id = $2`, [senhaHash, user.id]);
    }
    async updateFcmToken(jwtToken, fcmToken) {
        try {
            const jwtSecret = process.env.JWT_SECRET;
            if (!jwtSecret) {
                throw new Error('JWT_SECRET não configurado');
            }
            const decoded = jsonwebtoken_1.default.verify(jwtToken, jwtSecret);
            await this.db.query('UPDATE clientes SET fcm_token = $1 WHERE id = $2', [fcmToken, decoded.userId]);
        }
        catch (error) {
            throw new Error('Token inválido');
        }
    }
    generateToken(userId) {
        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            throw new Error('JWT_SECRET não configurado');
        }
        return jsonwebtoken_1.default.sign({
            userId,
            type: 'access'
        }, jwtSecret, {
            expiresIn: process.env.JWT_EXPIRES_IN || '24h',
            issuer: 'dnotas-api',
            audience: 'dnotas-app'
        });
    }
}
exports.AuthService = AuthService;
//# sourceMappingURL=AuthService.js.map