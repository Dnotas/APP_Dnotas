import { AuthToken, RegisterData } from '../types';
export declare class AuthService {
    private supabase;
    constructor();
    login(cnpj: string, senha: string, fcm_token?: string): Promise<AuthToken>;
    register(data: RegisterData & {
        fcm_token?: string;
    }): Promise<AuthToken>;
    refreshToken(currentToken: string): Promise<AuthToken>;
    logout(token: string): Promise<void>;
    forgotPassword(cnpj: string, email: string): Promise<void>;
    resetPassword(token: string, novaSenha: string): Promise<void>;
    updateFcmToken(jwtToken: string, fcmToken: string): Promise<void>;
    private generateToken;
}
//# sourceMappingURL=AuthService.d.ts.map