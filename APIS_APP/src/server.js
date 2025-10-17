const express = require('express');
const cors = require('cors');
const https = require('https');
const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 9999;

// Configuração dos certificados SSL
const certPath = 'C:/CERTIFICADOSTONE'; // Pasta onde o win-acme salva os certificados

const sslOptions = {
    key: fs.readFileSync(path.join(certPath, 'api.dnotas.com.br-key.pem')),
    cert: fs.readFileSync(path.join(certPath, 'api.dnotas.com.br-crt.pem')),
    ca: fs.readFileSync(path.join(certPath, 'api.dnotas.com.br-chain.pem'))
};

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
      filial_id = 'matriz' // padrão matriz se não especificado
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

// Iniciar servidor HTTPS
https.createServer(sslOptions, app).listen(PORT, () => {
  console.log(`🚀 Servidor rodando com HTTPS na porta ${PORT}`);
  console.log(`📊 API de Vendas disponível em: https://api.dnotas.com.br/vendas_hoje`);
  console.log(`📱 API para APP disponível em: https://api.dnotas.com.br/api/relatorios/vendas/:cnpj`);
  console.log(`🔒 Certificados SSL carregados de: ${certPath}`);
});