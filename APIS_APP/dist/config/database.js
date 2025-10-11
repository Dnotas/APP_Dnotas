"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.pool = exports.supabase = void 0;
const supabase_js_1 = require("@supabase/supabase-js");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const supabaseUrl = process.env.SUPABASE_URL || 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';
exports.supabase = (0, supabase_js_1.createClient)(supabaseUrl, supabaseServiceKey);
exports.pool = {
    query: async (text, params) => {
        console.log('🔍 Supabase Query:', text.substring(0, 100));
        if (text.includes('SELECT') && text.includes('FROM')) {
            const tableName = extractTableName(text);
            return await executeSupabaseQuery(tableName, text, params);
        }
        throw new Error('Query complexa não suportada - use métodos específicos do Supabase');
    },
    connect: () => ({
        query: exports.pool.query,
        release: () => { },
    }),
    end: async () => {
        console.log('🔌 Conexões com Supabase finalizadas');
    }
};
function extractTableName(query) {
    const match = query.match(/FROM\s+(\w+)/i);
    return match ? match[1] : '';
}
async function executeSupabaseQuery(tableName, query, params) {
    if (query.includes('SELECT') && tableName) {
        const { data, error } = await exports.supabase.from(tableName).select('*');
        if (error)
            throw error;
        return { rows: data };
    }
    throw new Error('Query não suportada - use métodos específicos do Supabase');
}
exports.default = exports.pool;
//# sourceMappingURL=database.js.map