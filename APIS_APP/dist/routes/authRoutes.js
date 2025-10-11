"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRoutes = void 0;
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const AuthController_1 = require("../controllers/AuthController");
const router = (0, express_1.Router)();
exports.authRoutes = router;
const authController = new AuthController_1.AuthController();
router.post('/login', [
    (0, express_validator_1.body)('cnpj')
        .matches(/^\d{14}$/)
        .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('senha')
        .isLength({ min: 6 })
        .withMessage('Senha deve ter pelo menos 6 caracteres'),
    (0, express_validator_1.body)('fcm_token')
        .optional()
        .isString()
        .withMessage('Token FCM deve ser uma string')
], authController.login);
router.post('/register', [
    (0, express_validator_1.body)('cnpj')
        .matches(/^\d{14}$/)
        .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('nome')
        .isLength({ min: 2, max: 100 })
        .withMessage('Nome deve ter entre 2 e 100 caracteres'),
    (0, express_validator_1.body)('email')
        .isEmail()
        .withMessage('Email inválido'),
    (0, express_validator_1.body)('telefone')
        .matches(/^\d{10,11}$/)
        .withMessage('Telefone deve conter 10 ou 11 dígitos'),
    (0, express_validator_1.body)('senha')
        .isLength({ min: 6 })
        .withMessage('Senha deve ter pelo menos 6 caracteres'),
    (0, express_validator_1.body)('filial_id')
        .notEmpty()
        .withMessage('ID da filial é obrigatório'),
    (0, express_validator_1.body)('fcm_token')
        .optional()
        .isString()
        .withMessage('Token FCM deve ser uma string')
], authController.register);
router.post('/refresh-token', authController.refreshToken);
router.post('/logout', authController.logout);
router.post('/forgot-password', [
    (0, express_validator_1.body)('cnpj')
        .matches(/^\d{14}$/)
        .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    (0, express_validator_1.body)('email')
        .isEmail()
        .withMessage('Email inválido')
], authController.forgotPassword);
router.post('/reset-password', [
    (0, express_validator_1.body)('token')
        .notEmpty()
        .withMessage('Token de recuperação é obrigatório'),
    (0, express_validator_1.body)('nova_senha')
        .isLength({ min: 6 })
        .withMessage('Nova senha deve ter pelo menos 6 caracteres')
], authController.resetPassword);
router.put('/update-fcm-token', [
    (0, express_validator_1.body)('fcm_token')
        .notEmpty()
        .withMessage('Token FCM é obrigatório')
], authController.updateFcmToken);
//# sourceMappingURL=authRoutes.js.map