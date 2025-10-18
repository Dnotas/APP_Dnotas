const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 1111;

// Configuração do Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// Middlewares
app.use(cors());
app.use(express.json());

// Middleware de log simples
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Rota de teste
app.get('/', (req, res) => {
  res.json({ 
    message: 'API DNOTAS - Vendas do Dia',
    status: 'online',
    timestamp: new Date().toISOString()
  });
});

// API para atualizar vendas do dia
app.post('/vendas_hoje', async (req, res) => {
  try {
    const {
      cnpj,
      credito = 0,
      debito = 0,
      pix = 0,
      vale = 0,
      dinheiro = 0,
      transferencia = 0,
      filial_id = null // opcional, sem valor padrão
    } = req.body;

    // Validação básica
    if (!cnpj) {
      return res.status(400).json({
        success: false,
        error: 'CNPJ é obrigatório'
      });
    }

    // Calcular total automaticamente
    const total_vendas = parseFloat(credito) + parseFloat(debito) + parseFloat(pix) + 
                        parseFloat(vale) + parseFloat(dinheiro) + parseFloat(transferencia);

    const hoje = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    // Primeiro, buscar se já existe um registro para hoje
    const { data: existingRecord, error: searchError } = await supabase
      .from('relatorios_vendas')
      .select('*')
      .eq('cliente_cnpj', cnpj)
      .eq('data_relatorio', hoje)
      .single();

    let result;

    if (existingRecord) {
      // Atualizar registro existente
      const { data, error } = await supabase
        .from('relatorios_vendas')
        .update({
          vendas_credito: credito,
          vendas_debito: debito,
          vendas_pix: pix,
          vendas_vale: vale,
          vendas_dinheiro: dinheiro,
          vendas_transferencia: transferencia,
          total_vendas: total_vendas,
          filial_id: filial_id,
          updated_at: new Date().toISOString()
        })
        .eq('cliente_cnpj', cnpj)
        .eq('data_relatorio', hoje)
        .select();

      if (error) {
        throw error;
      }
      result = data;
      console.log(`Vendas atualizadas para CNPJ: ${cnpj}, Total: R$ ${total_vendas.toFixed(2)}`);
    } else {
      // Criar novo registro
      const { data, error } = await supabase
        .from('relatorios_vendas')
        .insert([{
          cliente_cnpj: cnpj,
          filial_id: filial_id,
          data_relatorio: hoje,
          vendas_credito: credito,
          vendas_debito: debito,
          vendas_pix: pix,
          vendas_vale: vale,
          vendas_dinheiro: dinheiro,
          vendas_transferencia: transferencia,
          total_vendas: total_vendas
        }])
        .select();

      if (error) {
        throw error;
      }
      result = data;
      console.log(`Novas vendas criadas para CNPJ: ${cnpj}, Total: R$ ${total_vendas.toFixed(2)}`);
    }

    res.json({
      success: true,
      message: existingRecord ? 'Vendas atualizadas com sucesso' : 'Vendas registradas com sucesso',
      data: {
        cnpj: cnpj,
        data: hoje,
        vendas: {
          credito: parseFloat(credito),
          debito: parseFloat(debito),
          pix: parseFloat(pix),
          vale: parseFloat(vale),
          dinheiro: parseFloat(dinheiro),
          transferencia: parseFloat(transferencia),
          total: total_vendas
        },
        filial_id: filial_id
      }
    });

  } catch (error) {
    console.error('Erro ao processar vendas:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para buscar vendas do dia (para o APP)
app.get('/api/relatorios/vendas/:cnpj', async (req, res) => {
  try {
    const { cnpj } = req.params;
    const { data: dataParam } = req.query;
    
    const dataConsulta = dataParam || new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from('relatorios_vendas')
      .select('*')
      .eq('cliente_cnpj', cnpj)
      .eq('data_relatorio', dataConsulta)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
      throw error;
    }

    res.json({
      success: true,
      data: data || {
        vendas_credito: 0,
        vendas_debito: 0,
        vendas_pix: 0,
        vendas_vale: 0,
        vendas_dinheiro: 0,
        vendas_transferencia: 0,
        total_vendas: 0
      }
    });

  } catch (error) {
    console.error('Erro ao buscar vendas:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para solicitar relatório customizado
app.post('/api/solicitacoes/relatorio', async (req, res) => {
  try {
    const {
      cliente_cnpj,
      data_inicio,
      data_fim,
      tipo_periodo,
      observacoes = null,
      filial_id = null
    } = req.body;

    // Validação básica
    if (!cliente_cnpj || !data_inicio || !data_fim || !tipo_periodo) {
      return res.status(400).json({
        success: false,
        error: 'Dados obrigatórios não fornecidos'
      });
    }

    const { data, error } = await supabase
      .from('solicitacoes_relatorios')
      .insert([{
        cliente_cnpj,
        filial_id,
        data_inicio,
        data_fim,
        tipo_periodo,
        observacoes,
        status: 'pendente'
      }])
      .select();

    if (error) {
      throw error;
    }

    console.log(`Nova solicitação de relatório - CNPJ: ${cliente_cnpj}, Período: ${data_inicio} a ${data_fim}`);

    res.json({
      success: true,
      message: 'Solicitação de relatório enviada com sucesso',
      data: data[0]
    });

  } catch (error) {
    console.error('Erro ao processar solicitação de relatório:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para buscar solicitações de relatórios do cliente
app.get('/api/solicitacoes/relatorio/:cnpj', async (req, res) => {
  try {
    const { cnpj } = req.params;

    const { data, error } = await supabase
      .from('solicitacoes_relatorios')
      .select('*')
      .eq('cliente_cnpj', cnpj)
      .order('data_solicitacao', { ascending: false });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar solicitações de relatórios:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para buscar todas as solicitações pendentes (para o SITE)
app.get('/api/admin/solicitacoes/pendentes', async (req, res) => {
  try {
    const { filial_id } = req.query;

    let query = supabase
      .from('solicitacoes_relatorios')
      .select('*')
      .in('status', ['pendente', 'processando'])
      .order('data_solicitacao', { ascending: true });

    if (filial_id) {
      query = query.eq('filial_id', filial_id);
    }

    const { data, error } = await query;

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar solicitações pendentes:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para processar/preencher relatório (para o SITE)
app.post('/api/admin/relatorios/processar/:solicitacao_id', async (req, res) => {
  try {
    const { solicitacao_id } = req.params;
    const {
      relatorios_dados, // Array com os dados de cada dia
      processado_por
    } = req.body;

    // Primeiro, buscar a solicitação
    const { data: solicitacao, error: solicitacaoError } = await supabase
      .from('solicitacoes_relatorios')
      .select('*')
      .eq('id', solicitacao_id)
      .single();

    if (solicitacaoError || !solicitacao) {
      return res.status(404).json({
        success: false,
        error: 'Solicitação não encontrada'
      });
    }

    // Atualizar status da solicitação para 'processando'
    await supabase
      .from('solicitacoes_relatorios')
      .update({
        status: 'processando',
        processado_por: processado_por
      })
      .eq('id', solicitacao_id);

    // Inserir os relatórios processados
    const relatoriosParaInserir = relatorios_dados.map(relatorio => ({
      solicitacao_id: solicitacao_id,
      cliente_cnpj: solicitacao.cliente_cnpj,
      filial_id: solicitacao.filial_id,
      data_relatorio: relatorio.data_relatorio,
      vendas_credito: parseFloat(relatorio.vendas_credito || 0),
      vendas_debito: parseFloat(relatorio.vendas_debito || 0),
      vendas_pix: parseFloat(relatorio.vendas_pix || 0),
      vendas_vale: parseFloat(relatorio.vendas_vale || 0),
      vendas_dinheiro: parseFloat(relatorio.vendas_dinheiro || 0),
      vendas_transferencia: parseFloat(relatorio.vendas_transferencia || 0),
      total_vendas: parseFloat(relatorio.vendas_credito || 0) + 
                   parseFloat(relatorio.vendas_debito || 0) +
                   parseFloat(relatorio.vendas_pix || 0) +
                   parseFloat(relatorio.vendas_vale || 0) +
                   parseFloat(relatorio.vendas_dinheiro || 0) +
                   parseFloat(relatorio.vendas_transferencia || 0),
      observacoes: relatorio.observacoes
    }));

    const { error: insertError } = await supabase
      .from('relatorios_processados')
      .insert(relatoriosParaInserir);

    if (insertError) {
      throw insertError;
    }

    // Atualizar status da solicitação para 'concluido'
    await supabase
      .from('solicitacoes_relatorios')
      .update({
        status: 'concluido',
        data_processamento: new Date().toISOString()
      })
      .eq('id', solicitacao_id);

    console.log(`Relatório processado para solicitação ${solicitacao_id} por ${processado_por}`);

    res.json({
      success: true,
      message: 'Relatório processado com sucesso'
    });

  } catch (error) {
    console.error('Erro ao processar relatório:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// API para buscar relatório processado
app.get('/api/relatorios/processado/:solicitacao_id', async (req, res) => {
  try {
    const { solicitacao_id } = req.params;

    const { data, error } = await supabase
      .from('relatorios_processados')
      .select('*')
      .eq('solicitacao_id', solicitacao_id)
      .order('data_relatorio', { ascending: true });

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      data: data || []
    });

  } catch (error) {
    console.error('Erro ao buscar relatório processado:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📊 API de Vendas disponível em: http://localhost:${PORT}/vendas_hoje`);
  console.log(`📱 API para APP disponível em: http://localhost:${PORT}/api/relatorios/vendas/:cnpj`);
  console.log(`📋 API de Solicitações disponível em: http://localhost:${PORT}/api/solicitacoes/relatorio`);
  console.log(`👨‍💼 API Admin disponível em: http://localhost:${PORT}/api/admin/solicitacoes/pendentes`);
});