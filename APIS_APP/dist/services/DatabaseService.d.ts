import { QueryResult } from 'pg';
export declare class DatabaseService {
    private static instance;
    private pool;
    private constructor();
    static getInstance(): DatabaseService;
    static initialize(): Promise<void>;
    static close(): Promise<void>;
    query<T = any>(text: string, params?: any[]): Promise<QueryResult<T>>;
    transaction<T>(callback: (query: (text: string, params?: any[]) => Promise<QueryResult>) => Promise<T>): Promise<T>;
    exists(table: string, condition: string, params: any[]): Promise<boolean>;
    count(table: string, condition?: string, params?: any[]): Promise<number>;
}
//# sourceMappingURL=DatabaseService.d.ts.map