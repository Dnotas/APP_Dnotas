// DNOTAS API - Rotas para Filiais dos Clientes
// Gerenciamento das filiais que cada cliente pode ter

const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');

// GET /api/client-filiais/:cnpj - Lista todas as filiais de um cliente
router.get('/:cnpj', async (req, res) => {
    try {
        const { cnpj } = req.params;
        
        console.log(`🏢 Buscando filiais do cliente: ${cnpj}`);
        
        // Busca matriz + filiais usando a função do banco
        const { data, error } = await supabase
            .rpc('get_all_client_cnpjs', { p_matriz_cnpj: cnpj });
        
        if (error) {
            console.error('❌ Erro ao buscar filiais:', error);
            return res.status(500).json({ 
                success: false, 
                error: 'Erro ao buscar filiais do cliente' 
            });
        }
        
        console.log(`✅ Encontradas ${data.length} entradas para cliente ${cnpj}`);
        
        res.json({
            success: true,
            matriz_cnpj: cnpj,
            filiais: data || []
        });
        
    } catch (error) {
        console.error('❌ Erro interno:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor' 
        });
    }
});

// POST /api/client-filiais - Adiciona nova filial a um cliente
router.post('/', async (req, res) => {
    try {
        const { 
            matriz_cnpj, 
            filial_cnpj, 
            filial_nome, 
            endereco, 
            telefone, 
            email 
        } = req.body;
        
        console.log(`🏢 Adicionando filial ${filial_cnpj} ao cliente ${matriz_cnpj}`);
        
        // Validações básicas
        if (!matriz_cnpj || !filial_cnpj || !filial_nome) {
            return res.status(400).json({
                success: false,
                error: 'CNPJ da matriz, CNPJ da filial e nome são obrigatórios'
            });
        }
        
        // Verifica se matriz existe
        const { data: matrizExists } = await supabase
            .from('users')
            .select('cnpj')
            .eq('cnpj', matriz_cnpj)
            .single();
            
        if (!matrizExists) {
            return res.status(404).json({
                success: false,
                error: 'Cliente matriz não encontrado'
            });
        }
        
        // Adiciona a filial
        const { data, error } = await supabase
            .from('client_filiais')
            .insert([{
                matriz_cnpj,
                filial_cnpj,
                filial_nome,
                endereco,
                telefone,
                email,
                ativo: true
            }])
            .select()
            .single();
            
        if (error) {
            console.error('❌ Erro ao criar filial:', error);
            
            // Tratamento de erro específico para CNPJ duplicado
            if (error.code === '23505') {
                return res.status(409).json({
                    success: false,
                    error: 'Este CNPJ já está cadastrado como filial'
                });
            }
            
            return res.status(500).json({
                success: false,
                error: 'Erro ao criar filial'
            });
        }
        
        console.log(`✅ Filial criada: ${data.id}`);
        
        res.status(201).json({
            success: true,
            filial: data
        });
        
    } catch (error) {
        console.error('❌ Erro interno:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor' 
        });
    }
});

// PUT /api/client-filiais/:id - Atualiza dados de uma filial
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { filial_nome, endereco, telefone, email, ativo } = req.body;
        
        console.log(`🏢 Atualizando filial: ${id}`);
        
        const { data, error } = await supabase
            .from('client_filiais')
            .update({
                filial_nome,
                endereco,
                telefone,
                email,
                ativo
            })
            .eq('id', id)
            .select()
            .single();
            
        if (error) {
            console.error('❌ Erro ao atualizar filial:', error);
            return res.status(500).json({
                success: false,
                error: 'Erro ao atualizar filial'
            });
        }
        
        if (!data) {
            return res.status(404).json({
                success: false,
                error: 'Filial não encontrada'
            });
        }
        
        console.log(`✅ Filial atualizada: ${id}`);
        
        res.json({
            success: true,
            filial: data
        });
        
    } catch (error) {
        console.error('❌ Erro interno:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor' 
        });
    }
});

// DELETE /api/client-filiais/:id - Remove uma filial
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        console.log(`🏢 Removendo filial: ${id}`);
        
        // Soft delete - apenas marca como inativo
        const { data, error } = await supabase
            .from('client_filiais')
            .update({ ativo: false })
            .eq('id', id)
            .select()
            .single();
            
        if (error) {
            console.error('❌ Erro ao remover filial:', error);
            return res.status(500).json({
                success: false,
                error: 'Erro ao remover filial'
            });
        }
        
        if (!data) {
            return res.status(404).json({
                success: false,
                error: 'Filial não encontrada'
            });
        }
        
        console.log(`✅ Filial removida: ${id}`);
        
        res.json({
            success: true,
            message: 'Filial removida com sucesso'
        });
        
    } catch (error) {
        console.error('❌ Erro interno:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor' 
        });
    }
});

// GET /api/client-filiais/search/:cnpj - Busca se um CNPJ existe como filial
router.get('/search/:cnpj', async (req, res) => {
    try {
        const { cnpj } = req.params;
        
        console.log(`🔍 Buscando CNPJ: ${cnpj}`);
        
        // Busca nas filiais
        const { data: filial } = await supabase
            .from('client_filiais')
            .select('*, users!client_filiais_matriz_cnpj_fkey(nome)')
            .eq('filial_cnpj', cnpj)
            .eq('ativo', true)
            .single();
            
        // Busca na matriz
        const { data: matriz } = await supabase
            .from('users')
            .select('cnpj, nome')
            .eq('cnpj', cnpj)
            .single();
            
        if (matriz) {
            res.json({
                success: true,
                found: true,
                tipo: 'matriz',
                dados: matriz
            });
        } else if (filial) {
            res.json({
                success: true,
                found: true,
                tipo: 'filial',
                dados: {
                    cnpj: filial.filial_cnpj,
                    nome: filial.filial_nome,
                    matriz: filial.users?.nome
                }
            });
        } else {
            res.json({
                success: true,
                found: false
            });
        }
        
    } catch (error) {
        console.error('❌ Erro na busca:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor' 
        });
    }
});

module.exports = router;