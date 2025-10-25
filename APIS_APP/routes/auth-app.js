// DNOTAS API - Rotas de Autenticação para o APP
// Endpoints específicos para o app mobile

const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');

// POST /api/auth-app/login - Login com retorno das filiais
router.post('/login', async (req, res) => {
    try {
        const { cnpj, senha } = req.body;
        
        console.log(`📱 APP Login: ${cnpj}`);
        
        // Validações básicas
        if (!cnpj || !senha) {
            return res.status(400).json({
                success: false,
                error: 'CNPJ e senha são obrigatórios'
            });
        }
        
        // Limpar CNPJ
        const cleanCnpj = cnpj.replace(/[^\d]/g, '');
        
        // Buscar cliente via view users_api
        const { data: user, error: userError } = await supabase
            .from('users_api')
            .select('*')
            .eq('cnpj', cleanCnpj)
            .eq('ativo', true)
            .single();
            
        if (userError || !user) {
            console.log(`❌ Cliente não encontrado: ${cleanCnpj}`);
            return res.status(404).json({
                success: false,
                error: 'Cliente não encontrado'
            });
        }
        
        // Verificar senha (assumindo que está hasheada - ajustar conforme necessário)
        // TODO: Implementar verificação de senha hasheada
        if (user.senha !== senha) {
            console.log(`❌ Senha incorreta para: ${cleanCnpj}`);
            return res.status(401).json({
                success: false,
                error: 'Senha incorreta'
            });
        }
        
        // Buscar filiais do cliente usando a função criada
        const { data: filiais, error: filiaisError } = await supabase
            .rpc('get_all_client_cnpjs', { p_matriz_cnpj: cleanCnpj });
            
        if (filiaisError) {
            console.error('❌ Erro ao buscar filiais:', filiaisError);
        }
        
        // Atualizar último login
        await supabase
            .from('clientes')
            .update({ last_login: new Date().toISOString() })
            .eq('cnpj', cleanCnpj);
        
        // Preparar resposta
        const userData = {
            id: user.id,
            cnpj: user.cnpj,
            nome: user.nome,
            email: user.email,
            telefone: user.telefone,
            filial_id: user.filial_id,
            filiais: filiais || [], // Lista de filiais (matriz + filiais)
            created_at: user.created_at,
            last_login: new Date().toISOString()
        };
        
        console.log(`✅ Login APP sucesso: ${cleanCnpj} (${filiais?.length || 0} filiais)`);
        
        res.json({
            success: true,
            user: userData,
            message: 'Login realizado com sucesso'
        });
        
    } catch (error) {
        console.error('❌ Erro no login APP:', error);
        res.status(500).json({
            success: false,
            error: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth-app/register-fcm - Registrar token FCM
router.post('/register-fcm', async (req, res) => {
    try {
        const { cnpj, fcm_token, platform } = req.body;
        
        console.log(`📱 Registrando FCM: ${cnpj} (${platform})`);
        
        if (!cnpj || !fcm_token) {
            return res.status(400).json({
                success: false,
                error: 'CNPJ e FCM token são obrigatórios'
            });
        }
        
        const cleanCnpj = cnpj.replace(/[^\d]/g, '');
        
        // Atualizar token FCM na tabela clientes
        const { error } = await supabase
            .from('clientes')
            .update({ fcm_token: fcm_token })
            .eq('cnpj', cleanCnpj);
            
        if (error) {
            console.error('❌ Erro ao salvar FCM token:', error);
            return res.status(500).json({
                success: false,
                error: 'Erro ao registrar token'
            });
        }
        
        console.log(`✅ FCM token registrado: ${cleanCnpj}`);
        
        res.json({
            success: true,
            message: 'Token FCM registrado com sucesso'
        });
        
    } catch (error) {
        console.error('❌ Erro ao registrar FCM:', error);
        res.status(500).json({
            success: false,
            error: 'Erro interno do servidor'
        });
    }
});

// GET /api/auth-app/filiais/:cnpj - Buscar filiais de um cliente
router.get('/filiais/:cnpj', async (req, res) => {
    try {
        const { cnpj } = req.params;
        const cleanCnpj = cnpj.replace(/[^\d]/g, '');
        
        console.log(`📱 Buscando filiais APP: ${cleanCnpj}`);
        
        // Buscar filiais usando a função
        const { data: filiais, error } = await supabase
            .rpc('get_all_client_cnpjs', { p_matriz_cnpj: cleanCnpj });
            
        if (error) {
            console.error('❌ Erro ao buscar filiais:', error);
            return res.status(500).json({
                success: false,
                error: 'Erro ao buscar filiais'
            });
        }
        
        console.log(`✅ Filiais encontradas: ${filiais?.length || 0}`);
        
        res.json({
            success: true,
            matriz_cnpj: cleanCnpj,
            filiais: filiais || []
        });
        
    } catch (error) {
        console.error('❌ Erro ao buscar filiais:', error);
        res.status(500).json({
            success: false,
            error: 'Erro interno do servidor'
        });
    }
});

// PUT /api/auth-app/profile/:cnpj - Atualizar perfil do cliente
router.put('/profile/:cnpj', async (req, res) => {
    try {
        const { cnpj } = req.params;
        const { telefone, email } = req.body;
        const cleanCnpj = cnpj.replace(/[^\d]/g, '');
        
        console.log(`📱 Atualizando perfil APP: ${cleanCnpj}`);
        
        const updateData = {};
        if (telefone) updateData.telefone = telefone;
        if (email) updateData.email = email;
        
        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Nenhum dado para atualizar'
            });
        }
        
        const { data, error } = await supabase
            .from('clientes')
            .update(updateData)
            .eq('cnpj', cleanCnpj)
            .select()
            .single();
            
        if (error) {
            console.error('❌ Erro ao atualizar perfil:', error);
            return res.status(500).json({
                success: false,
                error: 'Erro ao atualizar perfil'
            });
        }
        
        console.log(`✅ Perfil atualizado: ${cleanCnpj}`);
        
        res.json({
            success: true,
            user: data,
            message: 'Perfil atualizado com sucesso'
        });
        
    } catch (error) {
        console.error('❌ Erro ao atualizar perfil:', error);
        res.status(500).json({
            success: false,
            error: 'Erro interno do servidor'
        });
    }
});

module.exports = router;