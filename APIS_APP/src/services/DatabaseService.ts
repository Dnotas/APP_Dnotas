import { Pool, QueryResult } from 'pg';
import pool from '../config/database';

export class DatabaseService {
  private static instance: DatabaseService;
  private pool: Pool;

  private constructor() {
    this.pool = pool;
  }

  public static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  public static async initialize(): Promise<void> {
    const instance = DatabaseService.getInstance();
    try {
      await instance.pool.query('SELECT NOW()');
      console.log('✅ Conexão com Supabase PostgreSQL estabelecida');
    } catch (error) {
      console.error('❌ Erro ao conectar com Supabase:', error);
      throw error;
    }
  }

  public static async close(): Promise<void> {
    const instance = DatabaseService.getInstance();
    await instance.pool.end();
    console.log('🔌 Conexões com PostgreSQL fechadas');
  }

  public async query<T = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    const start = Date.now();
    try {
      const result = await this.pool.query<T>(text, params);
      const duration = Date.now() - start;
      
      if (process.env.NODE_ENV === 'development') {
        console.log(`🔍 Query executada em ${duration}ms:`, text.substring(0, 100));
      }
      
      return result;
    } catch (error) {
      console.error('❌ Erro na query:', error);
      console.error('📝 SQL:', text);
      console.error('📋 Params:', params);
      throw error;
    }
  }

  public async transaction<T>(callback: (query: (text: string, params?: any[]) => Promise<QueryResult>) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    
    try {
      await client.query('BEGIN');
      
      const transactionQuery = async (text: string, params?: any[]) => {
        return await client.query(text, params);
      };
      
      const result = await callback(transactionQuery);
      await client.query('COMMIT');
      
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  public async exists(table: string, condition: string, params: any[]): Promise<boolean> {
    const query = `SELECT EXISTS(SELECT 1 FROM ${table} WHERE ${condition})`;
    const result = await this.query(query, params);
    return result.rows[0].exists;
  }

  public async count(table: string, condition?: string, params?: any[]): Promise<number> {
    let query = `SELECT COUNT(*) FROM ${table}`;
    if (condition) {
      query += ` WHERE ${condition}`;
    }
    const result = await this.query(query, params);
    return parseInt(result.rows[0].count);
  }
}