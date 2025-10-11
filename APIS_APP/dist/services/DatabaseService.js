"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseService = void 0;
const database_1 = __importDefault(require("../config/database"));
class DatabaseService {
    constructor() {
        this.pool = database_1.default;
    }
    static getInstance() {
        if (!DatabaseService.instance) {
            DatabaseService.instance = new DatabaseService();
        }
        return DatabaseService.instance;
    }
    static async initialize() {
        const instance = DatabaseService.getInstance();
        try {
            await instance.pool.query('SELECT NOW()');
            console.log('✅ Conexão com Supabase PostgreSQL estabelecida');
        }
        catch (error) {
            console.error('❌ Erro ao conectar com Supabase:', error);
            throw error;
        }
    }
    static async close() {
        const instance = DatabaseService.getInstance();
        await instance.pool.end();
        console.log('🔌 Conexões com PostgreSQL fechadas');
    }
    async query(text, params) {
        const start = Date.now();
        try {
            const result = await this.pool.query(text, params);
            const duration = Date.now() - start;
            if (process.env.NODE_ENV === 'development') {
                console.log(`🔍 Query executada em ${duration}ms:`, text.substring(0, 100));
            }
            return result;
        }
        catch (error) {
            console.error('❌ Erro na query:', error);
            console.error('📝 SQL:', text);
            console.error('📋 Params:', params);
            throw error;
        }
    }
    async transaction(callback) {
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');
            const transactionQuery = async (text, params) => {
                return await client.query(text, params);
            };
            const result = await callback(transactionQuery);
            await client.query('COMMIT');
            return result;
        }
        catch (error) {
            await client.query('ROLLBACK');
            throw error;
        }
        finally {
            client.release();
        }
    }
    async exists(table, condition, params) {
        const query = `SELECT EXISTS(SELECT 1 FROM ${table} WHERE ${condition})`;
        const result = await this.query(query, params);
        return result.rows[0].exists;
    }
    async count(table, condition, params) {
        let query = `SELECT COUNT(*) FROM ${table}`;
        if (condition) {
            query += ` WHERE ${condition}`;
        }
        const result = await this.query(query, params);
        return parseInt(result.rows[0].count);
    }
}
exports.DatabaseService = DatabaseService;
//# sourceMappingURL=DatabaseService.js.map