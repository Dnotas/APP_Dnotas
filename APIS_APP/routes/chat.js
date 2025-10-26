const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// Configuração do multer para upload de arquivos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/chat';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  },
  fileFilter: function (req, file, cb) {
    // Permitir apenas certos tipos de arquivo
    const allowedTypes = /jpeg|jpg|png|gif|pdf|doc|docx|xls|xlsx|txt/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Tipo de arquivo não permitido'));
    }
  }
});

// ====================================
// ENDPOINTS PARA CLIENTES (APP)
// ====================================

// 1. INICIAR NOVA CONVERSA
router.post('/conversations/start', async (req, res) => {
  try {
    const { cliente_cnpj, titulo, descricao, prioridade = 'normal' } = req.body;

    if (!cliente_cnpj || !titulo) {
      return res.status(400).json({
        success: false,
        error: 'CNPJ do cliente e título são obrigatórios'
      });
    }

    // Verificar se cliente existe e está ativo
    const { data: cliente, error: clienteError } = await supabase
      .from('clientes')
      .select('cnpj, nome_empresa, filial_id')
      .eq('cnpj', cliente_cnpj)
      .eq('is_active', true)
      .single();

    if (clienteError || !cliente) {
      return res.status(404).json({
        success: false,
        error: 'Cliente não encontrado ou inativo'
      });
    }

    // Criar nova conversa usando a função SQL
    const { data, error } = await supabase.rpc('iniciar_conversa_suporte', {
      p_cliente_cnpj: cliente_cnpj,
      p_titulo: titulo,
      p_descricao: descricao,
      p_prioridade: prioridade
    });

    if (error) {
      throw error;
    }

    console.log(`💬 Nova conversa iniciada - Cliente: ${cliente.nome} (${cliente_cnpj}), Título: ${titulo}`);

    res.json({
      success: true,
      message: 'Conversa iniciada com sucesso',
      data: {
        conversa_id: data,
        cliente_cnpj,
        titulo,
        status: 'aberto'
      }
    });

  } catch (error) {
    console.error('Erro ao iniciar conversa:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 2. LISTAR CONVERSAS DO CLIENTE
router.get('/conversations/client/:cnpj', async (req, res) => {
  try {
    const { cnpj } = req.params;
    const { limite = 20, offset = 0 } = req.query;

    const { data, error } = await supabase.rpc('buscar_conversas_cliente', {
      p_cliente_cnpj: cnpj,
      p_limite: parseInt(limite),
      p_offset: parseInt(offset)
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar conversas do cliente:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 3. ENVIAR MENSAGEM (CLIENTE)
router.post('/messages/send', upload.single('arquivo'), async (req, res) => {
  try {
    const { conversa_id, cliente_cnpj, conteudo, tipo_conteudo = 'texto' } = req.body;

    if (!conversa_id || !cliente_cnpj || !conteudo) {
      return res.status(400).json({
        success: false,
        error: 'Conversa ID, CNPJ e conteúdo são obrigatórios'
      });
    }

    // Buscar nome do cliente
    const { data: cliente, error: clienteError } = await supabase
      .from('clientes')
      .select('nome_empresa')
      .eq('cnpj', cliente_cnpj)
      .single();

    if (clienteError || !cliente) {
      return res.status(404).json({
        success: false,
        error: 'Cliente não encontrado'
      });
    }

    let arquivo_nome = null;
    let arquivo_url = null;
    let arquivo_tamanho = null;
    let arquivo_tipo = null;

    // Se há arquivo anexado
    if (req.file) {
      arquivo_nome = req.file.originalname;
      arquivo_url = `/uploads/chat/${req.file.filename}`;
      arquivo_tamanho = req.file.size;
      arquivo_tipo = req.file.mimetype;
    }

    // Enviar mensagem usando função SQL
    const { data, error } = await supabase.rpc('enviar_mensagem_chat', {
      p_conversa_id: conversa_id,
      p_remetente_tipo: 'cliente',
      p_remetente_id: cliente_cnpj,
      p_remetente_nome: cliente.nome_empresa,
      p_conteudo: conteudo,
      p_tipo_conteudo: tipo_conteudo,
      p_arquivo_nome: arquivo_nome,
      p_arquivo_url: arquivo_url,
      p_arquivo_tamanho: arquivo_tamanho,
      p_arquivo_tipo: arquivo_tipo
    });

    if (error) {
      throw error;
    }

    console.log(`📨 Mensagem enviada - Cliente: ${cliente.nome_empresa}, Conversa: ${conversa_id}`);

    // TODO: Enviar notificação em tempo real para funcionários

    res.json({
      success: true,
      message: 'Mensagem enviada com sucesso',
      data: {
        mensagem_id: data,
        arquivo_anexado: !!req.file
      }
    });

  } catch (error) {
    console.error('Erro ao enviar mensagem:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 4. MARCAR MENSAGENS COMO LIDAS (CLIENTE)
router.post('/messages/read/:conversa_id', async (req, res) => {
  try {
    const { conversa_id } = req.params;

    const { data, error } = await supabase.rpc('marcar_mensagens_lidas', {
      p_conversa_id: conversa_id,
      p_tipo_usuario: 'cliente'
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      message: 'Mensagens marcadas como lidas',
      mensagens_marcadas: data
    });

  } catch (error) {
    console.error('Erro ao marcar mensagens como lidas:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// ENDPOINTS PARA FUNCIONÁRIOS (SITE)
// ====================================

// 5. LISTAR CONVERSAS PARA ATENDIMENTO
router.get('/conversations/attendance/:organizacao_id', async (req, res) => {
  try {
    const { organizacao_id } = req.params;
    const { funcionario_id, status, limite = 50, offset = 0 } = req.query;

    const { data, error } = await supabase.rpc('buscar_conversas_atendimento', {
      p_filial_id: organizacao_id,
      p_funcionario_id: funcionario_id || null,
      p_status: status || null,
      p_limite: parseInt(limite),
      p_offset: parseInt(offset)
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar conversas para atendimento:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 6. ASSUMIR ATENDIMENTO
router.post('/conversations/:conversa_id/assume', async (req, res) => {
  try {
    const { conversa_id } = req.params;
    const { funcionario_id, funcionario_nome } = req.body;

    if (!funcionario_id || !funcionario_nome) {
      return res.status(400).json({
        success: false,
        error: 'ID e nome do funcionário são obrigatórios'
      });
    }

    const { data, error } = await supabase.rpc('assumir_atendimento', {
      p_conversa_id: conversa_id,
      p_funcionario_id: funcionario_id,
      p_funcionario_nome: funcionario_nome
    });

    if (error) {
      throw error;
    }

    if (data) {
      console.log(`👤 ${funcionario_nome} assumiu atendimento da conversa ${conversa_id}`);
      
      res.json({
        success: true,
        message: 'Atendimento assumido com sucesso'
      });
    } else {
      res.status(409).json({
        success: false,
        error: 'Conversa não disponível para assumir'
      });
    }

  } catch (error) {
    console.error('Erro ao assumir atendimento:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 7. ENVIAR MENSAGEM (FUNCIONÁRIO)
router.post('/messages/send-staff', upload.single('arquivo'), async (req, res) => {
  try {
    const { conversa_id, funcionario_id, funcionario_nome, conteudo, tipo_conteudo = 'texto' } = req.body;

    if (!conversa_id || !funcionario_id || !funcionario_nome || !conteudo) {
      return res.status(400).json({
        success: false,
        error: 'Todos os campos são obrigatórios'
      });
    }

    let arquivo_nome = null;
    let arquivo_url = null;
    let arquivo_tamanho = null;
    let arquivo_tipo = null;

    // Se há arquivo anexado
    if (req.file) {
      arquivo_nome = req.file.originalname;
      arquivo_url = `/uploads/chat/${req.file.filename}`;
      arquivo_tamanho = req.file.size;
      arquivo_tipo = req.file.mimetype;
    }

    // Enviar mensagem usando função SQL
    const { data, error } = await supabase.rpc('enviar_mensagem_chat', {
      p_conversa_id: conversa_id,
      p_remetente_tipo: 'funcionario',
      p_remetente_id: funcionario_id,
      p_remetente_nome: funcionario_nome,
      p_conteudo: conteudo,
      p_tipo_conteudo: tipo_conteudo,
      p_arquivo_nome: arquivo_nome,
      p_arquivo_url: arquivo_url,
      p_arquivo_tamanho: arquivo_tamanho,
      p_arquivo_tipo: arquivo_tipo
    });

    if (error) {
      throw error;
    }

    console.log(`📨 Mensagem enviada - Funcionário: ${funcionario_nome}, Conversa: ${conversa_id}`);

    // TODO: Enviar notificação push para cliente

    res.json({
      success: true,
      message: 'Mensagem enviada com sucesso',
      data: {
        mensagem_id: data,
        arquivo_anexado: !!req.file
      }
    });

  } catch (error) {
    console.error('Erro ao enviar mensagem do funcionário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 8. MARCAR MENSAGENS COMO LIDAS (FUNCIONÁRIO)
router.post('/messages/read-staff/:conversa_id', async (req, res) => {
  try {
    const { conversa_id } = req.params;

    const { data, error } = await supabase.rpc('marcar_mensagens_lidas', {
      p_conversa_id: conversa_id,
      p_tipo_usuario: 'funcionario'
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      message: 'Mensagens marcadas como lidas',
      mensagens_marcadas: data
    });

  } catch (error) {
    console.error('Erro ao marcar mensagens como lidas:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 9. FINALIZAR CONVERSA
router.post('/conversations/:conversa_id/finalize', async (req, res) => {
  try {
    const { conversa_id } = req.params;
    const { funcionario_id, mensagem_final } = req.body;

    if (!funcionario_id) {
      return res.status(400).json({
        success: false,
        error: 'ID do funcionário é obrigatório'
      });
    }

    const { data, error } = await supabase.rpc('finalizar_conversa', {
      p_conversa_id: conversa_id,
      p_funcionario_id: funcionario_id,
      p_mensagem_final: mensagem_final || null
    });

    if (error) {
      throw error;
    }

    if (data) {
      console.log(`✅ Conversa ${conversa_id} finalizada pelo funcionário ${funcionario_id}`);
      
      res.json({
        success: true,
        message: 'Conversa finalizada com sucesso'
      });
    } else {
      res.status(403).json({
        success: false,
        error: 'Funcionário não autorizado a finalizar esta conversa'
      });
    }

  } catch (error) {
    console.error('Erro ao finalizar conversa:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// ENDPOINTS COMUNS
// ====================================

// 10. BUSCAR MENSAGENS DE UMA CONVERSA
router.get('/messages/:conversa_id', async (req, res) => {
  try {
    const { conversa_id } = req.params;
    const { limite = 100, offset = 0 } = req.query;

    const { data, error } = await supabase.rpc('buscar_mensagens_conversa', {
      p_conversa_id: conversa_id,
      p_limite: parseInt(limite),
      p_offset: parseInt(offset)
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar mensagens:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 11. BUSCAR DETALHES DE UMA CONVERSA
router.get('/conversations/:conversa_id/details', async (req, res) => {
  try {
    const { conversa_id } = req.params;

    const { data, error } = await supabase
      .from('v_chat_conversations_full')
      .select('*')
      .eq('id', conversa_id)
      .single();

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data
    });

  } catch (error) {
    console.error('Erro ao buscar detalhes da conversa:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// ENDPOINTS DE GESTÃO (FUNCIONÁRIOS)
// ====================================

// 12. LISTAR TEMPLATES DE MENSAGENS
router.get('/templates/:organizacao_id', async (req, res) => {
  try {
    const { organizacao_id } = req.params;
    const { funcionario_id, categoria } = req.query;

    let query = supabase
      .from('chat_templates')
      .select('*')
      .eq('filial_id', organizacao_id)
      .eq('ativo', true);

    if (funcionario_id) {
      query = query.or(`funcionario_id.is.null,funcionario_id.eq.${funcionario_id}`);
    } else {
      query = query.is('funcionario_id', null);
    }

    if (categoria) {
      query = query.eq('categoria', categoria);
    }

    const { data, error } = await query.order('categoria', { ascending: true });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar templates:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 13. ESTATÍSTICAS DO FUNCIONÁRIO
router.get('/stats/employee/:funcionario_id', async (req, res) => {
  try {
    const { funcionario_id } = req.params;
    const { data_inicio, data_fim } = req.query;

    const { data, error } = await supabase.rpc('obter_stats_funcionario', {
      p_funcionario_id: funcionario_id,
      p_data_inicio: data_inicio || null,
      p_data_fim: data_fim || null
    });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data[0] || {}
    });

  } catch (error) {
    console.error('Erro ao buscar estatísticas do funcionário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// 14. DOWNLOAD DE ARQUIVO
router.get('/files/:filename', (req, res) => {
  try {
    const { filename } = req.params;
    const filePath = path.join(__dirname, '../uploads/chat', filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        error: 'Arquivo não encontrado'
      });
    }

    res.download(filePath);

  } catch (error) {
    console.error('Erro ao fazer download do arquivo:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// ====================================
// MIDDLEWARE DE TRATAMENTO DE ERROS
// ====================================

router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({
        success: false,
        error: 'Arquivo muito grande. Tamanho máximo: 10MB'
      });
    }
  }
  
  console.error('Erro no middleware de chat:', error);
  res.status(500).json({
    success: false,
    error: 'Erro interno do servidor',
    details: error.message
  });
});

module.exports = router;