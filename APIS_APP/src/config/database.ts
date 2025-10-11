import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://cqqeylhspmpilzgmqfiu.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI';

export const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Para compatibilidade com código existente que usa pool
export const pool = {
  query: async (text: string, params?: any[]) => {
    console.log('🔍 Supabase Query:', text.substring(0, 100));
    
    // Converter query PostgreSQL para Supabase quando necessário
    if (text.includes('SELECT') && text.includes('FROM')) {
      const tableName = extractTableName(text);
      return await executeSupabaseQuery(tableName, text, params);
    }
    
    // Para queries mais complexas, usar rpc se necessário
    throw new Error('Query complexa não suportada - use métodos específicos do Supabase');
  },
  
  connect: () => ({
    query: pool.query,
    release: () => {},
  }),
  
  end: async () => {
    console.log('🔌 Conexões com Supabase finalizadas');
  }
};

function extractTableName(query: string): string {
  const match = query.match(/FROM\s+(\w+)/i);
  return match ? match[1] : '';
}

async function executeSupabaseQuery(tableName: string, query: string, params?: any[]) {
  // Implementação básica para queries simples
  if (query.includes('SELECT') && tableName) {
    const { data, error } = await supabase.from(tableName).select('*');
    if (error) throw error;
    return { rows: data };
  }
  
  throw new Error('Query não suportada - use métodos específicos do Supabase');
}

export default pool;