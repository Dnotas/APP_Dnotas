const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');
const router = express.Router();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// ====================================
// AUTENTICAÇÃO DE FUNCIONÁRIOS
// ====================================

// 1. LOGIN DE FUNCIONÁRIO
router.post('/login', async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({
        success: false,
        error: 'Email e senha são obrigatórios'
      });
    }

    // Buscar funcionário por email
    const { data: funcionario, error } = await supabase
      .from('funcionarios')
      .select(`
        id,
        nome,
        email,
        senha,
        filial_id,
        ativo,
        atendimento_ativo,
        max_conversas_simultaneas,
        conversas_ativas,
        filiais!inner(id, nome, codigo)
      `)
      .eq('email', email)
      .eq('ativo', true)
      .single();

    if (error || !funcionario) {
      return res.status(401).json({
        success: false,
        error: 'Credenciais inválidas'
      });
    }

    // Verificar senha (assumindo bcrypt)
    const senhaValida = await bcrypt.compare(senha, funcionario.senha);
    
    if (!senhaValida) {
      return res.status(401).json({
        success: false,
        error: 'Credenciais inválidas'
      });
    }

    // Atualizar último acesso
    await supabase
      .from('funcionarios')
      .update({ ultimo_acesso: new Date().toISOString() })
      .eq('id', funcionario.id);

    console.log(`👤 Login funcionário: ${funcionario.nome} (${funcionario.email})`);

    // Retornar dados do funcionário (sem a senha)
    const { senha: _, ...funcionarioSemSenha } = funcionario;
    
    res.json({
      success: true,
      message: 'Login realizado com sucesso',
      data: funcionarioSemSenha
    });

  } catch (error) {
    console.error('Erro no login do funcionário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 2. ALTERAR STATUS DE ATENDIMENTO (ONLINE/OFFLINE)
router.post('/:funcionario_id/toggle-status', async (req, res) => {
  try {
    const { funcionario_id } = req.params;
    const { atendimento_ativo } = req.body;

    const { data, error } = await supabase
      .from('funcionarios')
      .update({ atendimento_ativo: atendimento_ativo })
      .eq('id', funcionario_id)
      .eq('ativo', true)
      .select('nome, atendimento_ativo')
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: 'Funcionário não encontrado'
      });
    }

    console.log(`🔄 ${data.nome} ${atendimento_ativo ? 'ONLINE' : 'OFFLINE'} para atendimento`);

    res.json({
      success: true,
      message: `Status alterado para ${atendimento_ativo ? 'ONLINE' : 'OFFLINE'}`,
      data: {
        atendimento_ativo: data.atendimento_ativo
      }
    });

  } catch (error) {
    console.error('Erro ao alterar status de atendimento:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// GESTÃO DE FUNCIONÁRIOS
// ====================================

// 3. LISTAR FUNCIONÁRIOS DA FILIAL
router.get('/filial/:filial_id', async (req, res) => {
  try {
    const { filial_id } = req.params;

    const { data, error } = await supabase
      .from('funcionarios')
      .select(`
        id,
        nome,
        email,
        ativo,
        atendimento_ativo,
        max_conversas_simultaneas,
        conversas_ativas,
        total_conversas_atendidas,
        nota_avaliacao,
        ultimo_acesso,
        created_at
      `)
      .eq('filial_id', filial_id)
      .order('nome', { ascending: true });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao listar funcionários:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 4. CRIAR NOVO FUNCIONÁRIO
router.post('/', async (req, res) => {
  try {
    const {
      nome,
      email,
      senha,
      filial_id,
      max_conversas_simultaneas = 5,
      notificacoes_email = true,
      notificacoes_push = true
    } = req.body;

    if (!nome || !email || !senha || !filial_id) {
      return res.status(400).json({
        success: false,
        error: 'Todos os campos obrigatórios devem ser preenchidos'
      });
    }

    // Verificar se email já existe
    const { data: emailExiste } = await supabase
      .from('funcionarios')
      .select('id')
      .eq('email', email)
      .single();

    if (emailExiste) {
      return res.status(409).json({
        success: false,
        error: 'Email já cadastrado'
      });
    }

    // Hash da senha
    const senhaHash = await bcrypt.hash(senha, 12);

    // Criar funcionário
    const { data, error } = await supabase
      .from('funcionarios')
      .insert([{
        nome,
        email,
        senha: senhaHash,
        filial_id,
        max_conversas_simultaneas,
        notificacoes_email,
        notificacoes_push,
        ativo: true,
        atendimento_ativo: false
      }])
      .select('id, nome, email, filial_id, created_at')
      .single();

    if (error) {
      throw error;
    }

    console.log(`👤 Novo funcionário criado: ${nome} (${email})`);

    res.json({
      success: true,
      message: 'Funcionário criado com sucesso',
      data: data
    });

  } catch (error) {
    console.error('Erro ao criar funcionário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 5. ATUALIZAR FUNCIONÁRIO
router.put('/:funcionario_id', async (req, res) => {
  try {
    const { funcionario_id } = req.params;
    const {
      nome,
      email,
      max_conversas_simultaneas,
      notificacoes_email,
      notificacoes_push,
      ativo
    } = req.body;

    const updateData = {};
    if (nome !== undefined) updateData.nome = nome;
    if (email !== undefined) updateData.email = email;
    if (max_conversas_simultaneas !== undefined) updateData.max_conversas_simultaneas = max_conversas_simultaneas;
    if (notificacoes_email !== undefined) updateData.notificacoes_email = notificacoes_email;
    if (notificacoes_push !== undefined) updateData.notificacoes_push = notificacoes_push;
    if (ativo !== undefined) updateData.ativo = ativo;

    const { data, error } = await supabase
      .from('funcionarios')
      .update(updateData)
      .eq('id', funcionario_id)
      .select('id, nome, email, ativo')
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: 'Funcionário não encontrado'
      });
    }

    console.log(`✏️ Funcionário atualizado: ${data.nome}`);

    res.json({
      success: true,
      message: 'Funcionário atualizado com sucesso',
      data: data
    });

  } catch (error) {
    console.error('Erro ao atualizar funcionário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 6. ALTERAR SENHA
router.post('/:funcionario_id/change-password', async (req, res) => {
  try {
    const { funcionario_id } = req.params;
    const { senha_atual, nova_senha } = req.body;

    if (!senha_atual || !nova_senha) {
      return res.status(400).json({
        success: false,
        error: 'Senha atual e nova senha são obrigatórias'
      });
    }

    // Buscar funcionário
    const { data: funcionario, error: funcionarioError } = await supabase
      .from('funcionarios')
      .select('senha, nome')
      .eq('id', funcionario_id)
      .eq('ativo', true)
      .single();

    if (funcionarioError || !funcionario) {
      return res.status(404).json({
        success: false,
        error: 'Funcionário não encontrado'
      });
    }

    // Verificar senha atual
    const senhaAtualValida = await bcrypt.compare(senha_atual, funcionario.senha);
    
    if (!senhaAtualValida) {
      return res.status(401).json({
        success: false,
        error: 'Senha atual incorreta'
      });
    }

    // Hash da nova senha
    const novaSenhaHash = await bcrypt.hash(nova_senha, 12);

    // Atualizar senha
    const { error: updateError } = await supabase
      .from('funcionarios')
      .update({ senha: novaSenhaHash })
      .eq('id', funcionario_id);

    if (updateError) {
      throw updateError;
    }

    console.log(`🔒 Senha alterada para funcionário: ${funcionario.nome}`);

    res.json({
      success: true,
      message: 'Senha alterada com sucesso'
    });

  } catch (error) {
    console.error('Erro ao alterar senha:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// GESTÃO DE TEMPLATES
// ====================================

// 7. CRIAR TEMPLATE DE MENSAGEM
router.post('/templates', async (req, res) => {
  try {
    const {
      filial_id,
      funcionario_id = null, // null = template global da filial
      titulo,
      conteudo,
      categoria
    } = req.body;

    if (!filial_id || !titulo || !conteudo) {
      return res.status(400).json({
        success: false,
        error: 'Filial ID, título e conteúdo são obrigatórios'
      });
    }

    const { data, error } = await supabase
      .from('chat_templates')
      .insert([{
        filial_id,
        funcionario_id,
        titulo,
        conteudo,
        categoria,
        ativo: true
      }])
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    console.log(`📝 Template criado: ${titulo} (${categoria || 'sem categoria'})`);

    res.json({
      success: true,
      message: 'Template criado com sucesso',
      data: data
    });

  } catch (error) {
    console.error('Erro ao criar template:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 8. ATUALIZAR TEMPLATE
router.put('/templates/:template_id', async (req, res) => {
  try {
    const { template_id } = req.params;
    const { titulo, conteudo, categoria, ativo } = req.body;

    const updateData = {};
    if (titulo !== undefined) updateData.titulo = titulo;
    if (conteudo !== undefined) updateData.conteudo = conteudo;
    if (categoria !== undefined) updateData.categoria = categoria;
    if (ativo !== undefined) updateData.ativo = ativo;

    const { data, error } = await supabase
      .from('chat_templates')
      .update(updateData)
      .eq('id', template_id)
      .select('*')
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: 'Template não encontrado'
      });
    }

    res.json({
      success: true,
      message: 'Template atualizado com sucesso',
      data: data
    });

  } catch (error) {
    console.error('Erro ao atualizar template:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 9. DELETAR TEMPLATE
router.delete('/templates/:template_id', async (req, res) => {
  try {
    const { template_id } = req.params;

    const { error } = await supabase
      .from('chat_templates')
      .delete()
      .eq('id', template_id);

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      message: 'Template deletado com sucesso'
    });

  } catch (error) {
    console.error('Erro ao deletar template:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// ESTATÍSTICAS E RELATÓRIOS
// ====================================

// 10. DASHBOARD DE ESTATÍSTICAS DA FILIAL
router.get('/stats/filial/:filial_id', async (req, res) => {
  try {
    const { filial_id } = req.params;

    // Estatísticas gerais da filial
    const { data: statsGerais, error: statsError } = await supabase
      .from('v_chat_stats')
      .select('*')
      .eq('filial_id', filial_id)
      .single();

    // Funcionários online
    const { data: funcionariosOnline, error: onlineError } = await supabase
      .from('funcionarios')
      .select('id, nome, conversas_ativas')
      .eq('filial_id', filial_id)
      .eq('ativo', true)
      .eq('atendimento_ativo', true);

    // Conversas em aberto por prioridade
    const { data: conversasPorPrioridade, error: prioridadeError } = await supabase
      .from('chat_conversations')
      .select('prioridade')
      .eq('filial_id', filial_id)
      .in('status', ['aberto', 'em_atendimento']);

    if (statsError || onlineError || prioridadeError) {
      throw statsError || onlineError || prioridadeError;
    }

    // Agrupar conversas por prioridade
    const prioridadeCount = {
      urgente: 0,
      alta: 0,
      normal: 0,
      baixa: 0
    };

    conversasPorPrioridade?.forEach(conv => {
      prioridadeCount[conv.prioridade] = (prioridadeCount[conv.prioridade] || 0) + 1;
    });

    res.json({
      success: true,
      data: {
        estatisticas_gerais: statsGerais || {},
        funcionarios_online: funcionariosOnline || [],
        conversas_por_prioridade: prioridadeCount,
        total_funcionarios_online: funcionariosOnline?.length || 0
      }
    });

  } catch (error) {
    console.error('Erro ao buscar estatísticas da filial:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

module.exports = router;