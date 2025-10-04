import { Router } from 'express';
import { body } from 'express-validator';
import { AuthController } from '../controllers/AuthController';

const router = Router();
const authController = new AuthController();

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Fazer login do usuário
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cnpj
 *               - senha
 *             properties:
 *               cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *                 description: CNPJ do cliente (14 dígitos)
 *               senha:
 *                 type: string
 *                 minLength: 6
 *                 description: Senha do usuário
 *               fcm_token:
 *                 type: string
 *                 description: Token FCM para notificações push (opcional)
 *     responses:
 *       200:
 *         description: Login realizado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     token:
 *                       type: string
 *                     expiresIn:
 *                       type: string
 *                     user:
 *                       type: object
 *       401:
 *         description: Credenciais inválidas
 *       400:
 *         description: Dados inválidos
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/login',
  [
    body('cnpj')
      .matches(/^\d{14}$/)
      .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    body('senha')
      .isLength({ min: 6 })
      .withMessage('Senha deve ter pelo menos 6 caracteres'),
    body('fcm_token')
      .optional()
      .isString()
      .withMessage('Token FCM deve ser uma string')
  ],
  authController.login
);

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Registrar novo usuário
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cnpj
 *               - nome
 *               - email
 *               - telefone
 *               - senha
 *               - filial_id
 *             properties:
 *               cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *               nome:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 100
 *               email:
 *                 type: string
 *                 format: email
 *               telefone:
 *                 type: string
 *                 pattern: '^\d{10,11}$'
 *               senha:
 *                 type: string
 *                 minLength: 6
 *               filial_id:
 *                 type: string
 *               fcm_token:
 *                 type: string
 *                 description: Token FCM para notificações push (opcional)
 *     responses:
 *       201:
 *         description: Usuário registrado com sucesso
 *       400:
 *         description: Dados inválidos ou usuário já existe
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/register',
  [
    body('cnpj')
      .matches(/^\d{14}$/)
      .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    body('nome')
      .isLength({ min: 2, max: 100 })
      .withMessage('Nome deve ter entre 2 e 100 caracteres'),
    body('email')
      .isEmail()
      .withMessage('Email inválido'),
    body('telefone')
      .matches(/^\d{10,11}$/)
      .withMessage('Telefone deve conter 10 ou 11 dígitos'),
    body('senha')
      .isLength({ min: 6 })
      .withMessage('Senha deve ter pelo menos 6 caracteres'),
    body('filial_id')
      .notEmpty()
      .withMessage('ID da filial é obrigatório'),
    body('fcm_token')
      .optional()
      .isString()
      .withMessage('Token FCM deve ser uma string')
  ],
  authController.register
);

/**
 * @swagger
 * /api/auth/refresh-token:
 *   post:
 *     summary: Renovar token de acesso
 *     tags: [Autenticação]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Token renovado com sucesso
 *       401:
 *         description: Token inválido ou expirado
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/refresh-token', authController.refreshToken);

/**
 * @swagger
 * /api/auth/logout:
 *   post:
 *     summary: Fazer logout do usuário
 *     tags: [Autenticação]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logout realizado com sucesso
 *       401:
 *         description: Token inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/logout', authController.logout);

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Solicitar recuperação de senha
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cnpj
 *               - email
 *             properties:
 *               cnpj:
 *                 type: string
 *                 pattern: '^\d{14}$'
 *               email:
 *                 type: string
 *                 format: email
 *     responses:
 *       200:
 *         description: Instruções de recuperação enviadas
 *       400:
 *         description: Dados inválidos
 *       404:
 *         description: Usuário não encontrado
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/forgot-password',
  [
    body('cnpj')
      .matches(/^\d{14}$/)
      .withMessage('CNPJ deve conter exatamente 14 dígitos'),
    body('email')
      .isEmail()
      .withMessage('Email inválido')
  ],
  authController.forgotPassword
);

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     summary: Redefinir senha usando token de recuperação
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - nova_senha
 *             properties:
 *               token:
 *                 type: string
 *               nova_senha:
 *                 type: string
 *                 minLength: 6
 *     responses:
 *       200:
 *         description: Senha redefinida com sucesso
 *       400:
 *         description: Token inválido ou expirado
 *       500:
 *         description: Erro interno do servidor
 */
router.post('/reset-password',
  [
    body('token')
      .notEmpty()
      .withMessage('Token de recuperação é obrigatório'),
    body('nova_senha')
      .isLength({ min: 6 })
      .withMessage('Nova senha deve ter pelo menos 6 caracteres')
  ],
  authController.resetPassword
);

/**
 * @swagger
 * /api/auth/update-fcm-token:
 *   put:
 *     summary: Atualizar token FCM para notificações push
 *     tags: [Autenticação]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fcm_token
 *             properties:
 *               fcm_token:
 *                 type: string
 *     responses:
 *       200:
 *         description: Token FCM atualizado com sucesso
 *       400:
 *         description: Token FCM inválido
 *       401:
 *         description: Token de acesso inválido
 *       500:
 *         description: Erro interno do servidor
 */
router.put('/update-fcm-token',
  [
    body('fcm_token')
      .notEmpty()
      .withMessage('Token FCM é obrigatório')
  ],
  authController.updateFcmToken
);

export { router as authRoutes };