"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const AuthService_1 = require("../services/AuthService");
const express_validator_1 = require("express-validator");
class AuthController {
    constructor() {
        this.login = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { cnpj, senha, fcm_token } = req.body;
                const result = await this.authService.login(cnpj, senha, fcm_token);
                res.status(200).json({
                    success: true,
                    message: 'Login realizado com sucesso',
                    data: result
                });
            }
            catch (error) {
                console.error('Erro no login:', error);
                if (error instanceof Error && error.message.includes('Credenciais inválidas')) {
                    res.status(401).json({
                        success: false,
                        message: error.message
                    });
                    return;
                }
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.register = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const registerData = req.body;
                const result = await this.authService.register(registerData);
                res.status(201).json({
                    success: true,
                    message: 'Usuário registrado com sucesso',
                    data: result
                });
            }
            catch (error) {
                console.error('Erro no registro:', error);
                if (error instanceof Error && error.message.includes('já existe')) {
                    res.status(400).json({
                        success: false,
                        message: error.message
                    });
                    return;
                }
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.refreshToken = async (req, res) => {
            try {
                const token = req.header('Authorization')?.replace('Bearer ', '');
                if (!token) {
                    res.status(401).json({
                        success: false,
                        message: 'Token não fornecido'
                    });
                    return;
                }
                const result = await this.authService.refreshToken(token);
                res.status(200).json({
                    success: true,
                    message: 'Token renovado com sucesso',
                    data: result
                });
            }
            catch (error) {
                console.error('Erro ao renovar token:', error);
                if (error instanceof Error && error.message.includes('Token')) {
                    res.status(401).json({
                        success: false,
                        message: error.message
                    });
                    return;
                }
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.logout = async (req, res) => {
            try {
                const token = req.header('Authorization')?.replace('Bearer ', '');
                if (!token) {
                    res.status(401).json({
                        success: false,
                        message: 'Token não fornecido'
                    });
                    return;
                }
                await this.authService.logout(token);
                res.status(200).json({
                    success: true,
                    message: 'Logout realizado com sucesso'
                });
            }
            catch (error) {
                console.error('Erro no logout:', error);
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.forgotPassword = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { cnpj, email } = req.body;
                await this.authService.forgotPassword(cnpj, email);
                res.status(200).json({
                    success: true,
                    message: 'Se o email estiver cadastrado, você receberá instruções para recuperação da senha'
                });
            }
            catch (error) {
                console.error('Erro na recuperação de senha:', error);
                res.status(200).json({
                    success: true,
                    message: 'Se o email estiver cadastrado, você receberá instruções para recuperação da senha'
                });
            }
        };
        this.resetPassword = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const { token, nova_senha } = req.body;
                await this.authService.resetPassword(token, nova_senha);
                res.status(200).json({
                    success: true,
                    message: 'Senha redefinida com sucesso'
                });
            }
            catch (error) {
                console.error('Erro ao redefinir senha:', error);
                if (error instanceof Error && error.message.includes('Token')) {
                    res.status(400).json({
                        success: false,
                        message: error.message
                    });
                    return;
                }
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.updateFcmToken = async (req, res) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    res.status(400).json({
                        success: false,
                        message: 'Dados inválidos',
                        errors: errors.array()
                    });
                    return;
                }
                const token = req.header('Authorization')?.replace('Bearer ', '');
                const { fcm_token } = req.body;
                if (!token) {
                    res.status(401).json({
                        success: false,
                        message: 'Token de acesso não fornecido'
                    });
                    return;
                }
                await this.authService.updateFcmToken(token, fcm_token);
                res.status(200).json({
                    success: true,
                    message: 'Token FCM atualizado com sucesso'
                });
            }
            catch (error) {
                console.error('Erro ao atualizar token FCM:', error);
                if (error instanceof Error && error.message.includes('Token')) {
                    res.status(401).json({
                        success: false,
                        message: error.message
                    });
                    return;
                }
                res.status(500).json({
                    success: false,
                    message: 'Erro interno do servidor'
                });
            }
        };
        this.authService = new AuthService_1.AuthService();
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=AuthController.js.map