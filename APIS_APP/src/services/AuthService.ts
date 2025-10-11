import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { SupabaseService } from './SupabaseService';
import { User, AuthToken, LoginCredentials, RegisterData } from '../types';

export class AuthService {
  private supabase: SupabaseService;

  constructor() {
    this.supabase = SupabaseService.getInstance();
  }

  async login(cnpj: string, senha: string, fcm_token?: string): Promise<AuthToken> {
    try {
      // Buscar cliente por CNPJ usando Supabase
      const { data: cliente, error } = await this.supabase.getClienteByCnpj(cnpj);

      if (error || !cliente || !cliente.is_active) {
        throw new Error('Credenciais inválidas');
      }

      // Verificar senha
      const senhaValida = await bcrypt.compare(senha, cliente.senha);
      if (!senhaValida) {
        throw new Error('Credenciais inválidas');
      }

      // Atualizar último acesso e FCM token se fornecido
      const updateData: any = { last_login: new Date().toISOString() };
      if (fcm_token) {
        updateData.fcm_token = fcm_token;
      }

      await this.supabase.executeQuery('clientes', 'update', updateData, { id: cliente.id });

      // Gerar JWT
      const token = this.generateToken(cliente.id);

      // Remover senha do objeto user
      const { senha: _, ...userSemSenha } = cliente;

      return {
        token,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h',
        user: userSemSenha
      };
    } catch (error) {
      throw new Error('Erro no login: ' + (error as Error).message);
    }
  }

  async register(data: RegisterData & { fcm_token?: string }): Promise<AuthToken> {
    const { cnpj, nome_empresa, email, telefone, senha, filial_id, fcm_token } = data;

    // Verificar se cliente já existe
    const existingUser = await this.db.query(
      'SELECT id FROM clientes WHERE cnpj = $1 OR email = $2',
      [cnpj, email]
    );

    if (existingUser.rows.length > 0) {
      throw new Error('Cliente com este CNPJ ou email já existe');
    }

    // Verificar se filial existe
    const filialExists = await this.db.exists('filiais', 'id = $1 AND ativo = true', [filial_id]);
    if (!filialExists) {
      throw new Error('Filial não encontrada');
    }

    // Hash da senha
    const senhaHash = await bcrypt.hash(senha, 12);

    // Inserir cliente
    const insertQuery = `
      INSERT INTO clientes (cnpj, nome_empresa, email, telefone, senha, filial_id, fcm_token, is_active)
      VALUES ($1, $2, $3, $4, $5, $6, $7, true)
      RETURNING id, cnpj, nome_empresa, email, telefone, filial_id, is_active, created_at
    `;

    const insertParams = [cnpj, nome_empresa, email, telefone, senhaHash, filial_id, fcm_token || null];
    const result = await this.db.query<User>(insertQuery, insertParams);
    const newUser = result.rows[0];

    // Buscar dados completos com filial
    const userQuery = `
      SELECT c.*, f.nome as filial_nome 
      FROM clientes c
      JOIN filiais f ON c.filial_id = f.id
      WHERE c.id = $1
    `;
    const userResult = await this.db.query<User>(userQuery, [newUser.id]);
    const user = userResult.rows[0];

    // Gerar JWT
    const token = this.generateToken(user.id);

    // Remover senha do objeto user
    const { senha: _, ...userSemSenha } = user;

    return {
      token,
      expiresIn: process.env.JWT_EXPIRES_IN || '24h',
      user: userSemSenha
    };
  }

  async refreshToken(currentToken: string): Promise<AuthToken> {
    try {
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        throw new Error('JWT_SECRET não configurado');
      }

      // Verificar token atual (ignora expiração)
      const decoded = jwt.verify(currentToken, jwtSecret, { ignoreExpiration: true }) as any;
      
      // Buscar cliente
      const query = `
        SELECT c.*, f.nome as filial_nome 
        FROM clientes c
        JOIN filiais f ON c.filial_id = f.id
        WHERE c.id = $1 AND c.is_active = true
      `;

      const result = await this.db.query<User>(query, [decoded.userId]);

      if (result.rows.length === 0) {
        throw new Error('Usuário não encontrado');
      }

      const user = result.rows[0];

      // Gerar novo JWT
      const token = this.generateToken(user.id);

      // Remover senha do objeto user
      const { senha: _, ...userSemSenha } = user;

      return {
        token,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h',
        user: userSemSenha
      };
    } catch (error) {
      throw new Error('Token inválido');
    }
  }

  async logout(token: string): Promise<void> {
    // Em uma implementação mais robusta, você poderia adicionar o token a uma blacklist
    // Por agora, apenas validamos que o token é válido
    try {
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        throw new Error('JWT_SECRET não configurado');
      }

      jwt.verify(token, jwtSecret);
      // Token válido, logout realizado
    } catch (error) {
      throw new Error('Token inválido');
    }
  }

  async forgotPassword(cnpj: string, email: string): Promise<void> {
    // Buscar cliente
    const query = 'SELECT id, email FROM clientes WHERE cnpj = $1 AND email = $2 AND is_active = true';
    const result = await this.db.query(query, [cnpj, email]);

    if (result.rows.length === 0) {
      // Por segurança, não revelar se o cliente existe
      return;
    }

    const user = result.rows[0];

    // Gerar token de recuperação
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenExpiry = new Date();
    resetTokenExpiry.setHours(resetTokenExpiry.getHours() + 1); // 1 hora

    // Salvar token na base de dados
    await this.db.query(
      'UPDATE clientes SET reset_token = $1, reset_token_expiry = $2 WHERE id = $3',
      [resetToken, resetTokenExpiry, user.id]
    );

    // Aqui você enviaria o email com o token
    // Por agora, apenas logamos o token (remover em produção)
    console.log(`🔑 Token de recuperação para ${email}: ${resetToken}`);
  }

  async resetPassword(token: string, novaSenha: string): Promise<void> {
    // Buscar cliente pelo token
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

    // Hash da nova senha
    const senhaHash = await bcrypt.hash(novaSenha, 12);

    // Atualizar senha e limpar token
    await this.db.query(
      `UPDATE clientes 
       SET senha = $1, reset_token = NULL, reset_token_expiry = NULL
       WHERE id = $2`,
      [senhaHash, user.id]
    );
  }

  async updateFcmToken(jwtToken: string, fcmToken: string): Promise<void> {
    try {
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        throw new Error('JWT_SECRET não configurado');
      }

      const decoded = jwt.verify(jwtToken, jwtSecret) as any;
      
      await this.db.query(
        'UPDATE clientes SET fcm_token = $1 WHERE id = $2',
        [fcmToken, decoded.userId]
      );
    } catch (error) {
      throw new Error('Token inválido');
    }
  }

  private generateToken(userId: string): string {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      throw new Error('JWT_SECRET não configurado');
    }

    return jwt.sign(
      { 
        userId,
        type: 'access'
      },
      jwtSecret,
      { 
        expiresIn: process.env.JWT_EXPIRES_IN || '24h',
        issuer: 'dnotas-api',
        audience: 'dnotas-app'
      }
    );
  }
}