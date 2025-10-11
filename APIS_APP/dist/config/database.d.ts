export declare const supabase: import("@supabase/supabase-js").SupabaseClient<any, "public", "public", any, any>;
export declare const pool: {
    query: (text: string, params?: any[]) => Promise<{
        rows: any[];
    }>;
    connect: () => {
        query: (text: string, params?: any[]) => Promise<{
            rows: any[];
        }>;
        release: () => void;
    };
    end: () => Promise<void>;
};
export default pool;
//# sourceMappingURL=database.d.ts.map