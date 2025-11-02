import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/boleto.dart';
import '../models/customer.dart';
import './boleto_cache_service.dart';

class AsaasService {
  static const String _baseUrl = 'https://api.asaas.com/v3';
  static const String _sandboxUrl = 'https://api-sandbox.asaas.com/v3';
  
  /// Busca as chaves Asaas ativas da organização/filial do usuário logado
  static Future<List<String>> _getActiveAsaasKeys(String cnpj) async {
    try {
      print('🔍 Buscando chaves Asaas para CNPJ: $cnpj');
      
      // Remover formatação do CNPJ
      final cleanCnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      print('🧹 CNPJ limpo: $cleanCnpj');
      
      // Buscar cliente pelo CNPJ para obter filial_id
      final clientResponse = await Supabase.instance.client
          .from('clientes')
          .select('filial_id, nome_empresa')
          .eq('cnpj', cleanCnpj)
          .single();

      final filialId = clientResponse['filial_id'];
      final nomeEmpresa = clientResponse['nome_empresa'];
      
      if (filialId == null) {
        print('❌ Filial não encontrada para o CNPJ: $cleanCnpj');
        
        // Tentar buscar por CNPJ formatado também
        print('🔄 Tentando buscar CNPJ com formatação...');
        final clientResponse2 = await Supabase.instance.client
            .from('clientes')
            .select('filial_id, nome_empresa')
            .eq('cnpj', cnpj)
            .single();
            
        final filialId2 = clientResponse2['filial_id'];
        if (filialId2 == null) {
          print('❌ Cliente não encontrado nem com CNPJ limpo nem formatado');
          return [];
        }
        
        print('✅ Cliente encontrado com CNPJ formatado: ${clientResponse2['nome_empresa']}');
        return _getKeysFromFilial(filialId2);
      }

      print('✅ Cliente encontrado: $nomeEmpresa');
      print('🏢 Filial ID: $filialId');

      return _getKeysFromFilial(filialId);
    } catch (e) {
      print('❌ Erro ao buscar chaves Asaas: $e');
      
      // Fallback: usar chaves da matriz diretamente
      print('🔄 Tentando fallback para matriz...');
      return _getKeysFromFilial('11111111-1111-1111-1111-111111111111');
    }
  }

  /// Busca chaves de uma filial específica
  static Future<List<String>> _getKeysFromFilial(String filialId) async {
    try {
      print('🔑 Buscando chaves da filial: $filialId');
      
      // Buscar chaves ativas da filial
      final response = await Supabase.instance.client
          .from('filiais')
          .select('asaas_keys, nome')
          .eq('id', filialId)
          .single();

      final asaasKeys = response['asaas_keys'] as List?;
      final nomeFilial = response['nome'];
      
      print('🏢 Filial: $nomeFilial');
      
      if (asaasKeys == null || asaasKeys.isEmpty) {
        print('❌ Nenhuma chave Asaas encontrada para a filial: $nomeFilial');
        return [];
      }

      print('📋 Chaves encontradas no banco: ${asaasKeys.length}');

      // Filtrar apenas chaves ativas
      List<String> activeKeys = [];
      for (var keyData in asaasKeys) {
        if (keyData['ativo'] == true && keyData['key'] != null) {
          activeKeys.add(keyData['key']);
          print('✅ Chave ativa: ${keyData['nome']} - ${(keyData['key'] as String).substring(0, 30)}...');
        } else {
          print('⚠️ Chave inativa: ${keyData['nome']}');
        }
      }

      print('🎯 Total de chaves ativas encontradas: ${activeKeys.length}');
      return activeKeys;
    } catch (e) {
      print('❌ Erro ao buscar chaves da filial $filialId: $e');
      return [];
    }
  }

  /// Headers para requisições usando a primeira chave ativa
  static Future<Map<String, String>> _getHeaders(String cnpj) async {
    final keys = await _getActiveAsaasKeys(cnpj);
    if (keys.isEmpty) {
      throw Exception('Nenhuma chave Asaas ativa encontrada para esta organização');
    }
    
    return {
      'accept': 'application/json',
      'access_token': keys.first, // Usa a primeira chave ativa
    };
  }

  /// Headers com chave específica
  static Map<String, String> _getHeadersWithKey(String apiKey) {
    return {
      'accept': 'application/json',
      'access_token': apiKey,
    };
  }

  /// Busca cliente na API Asaas pelo CPF/CNPJ
  static Future<String?> findCustomerByDocument(String document) async {
    try {
      // Remove formatação do documento
      final cleanDocument = document.replaceAll(RegExp(r'[^0-9]'), '');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/customers?cpfCnpj=$cleanDocument'),
        headers: await _getHeaders(cleanDocument),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customers = data['data'] as List;
        
        if (customers.isNotEmpty) {
          return customers.first['id'];
        }
      }
      
      print('Cliente não encontrado no Asaas para documento: $cleanDocument');
      return null;
    } catch (e) {
      print('Erro ao buscar cliente no Asaas: $e');
      return null;
    }
  }

  /// Busca todos os boletos de um cliente (com cache)
  static Future<List<Boleto>> getBoletosByDocument(String document) async {
    return await BoletoCacheService.getBoletosWithFallback(
      document,
      () => _fetchBoletosByDocumentFromApi(document),
    );
  }

  /// Busca boletos direto da API (sem cache) - tenta todas as chaves ativas
  static Future<List<Boleto>> _fetchBoletosByDocumentFromApi(String document) async {
    try {
      print('🚀 Iniciando busca de boletos para documento: $document');
      
      // Remove formatação do documento
      final cleanDocument = document.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Buscar todas as chaves ativas da organização
      final activeKeys = await _getActiveAsaasKeys(cleanDocument);
      if (activeKeys.isEmpty) {
        print('❌ Nenhuma chave Asaas ativa encontrada');
        return [];
      }

      print('🔑 Testando ${activeKeys.length} chaves...');
      
      // Tenta com cada chave até encontrar o cliente
      String? customerId;
      String? workingKey;
      
      for (int i = 0; i < activeKeys.length; i++) {
        String apiKey = activeKeys[i];
        try {
          print('🧪 Testando chave ${i + 1}/${activeKeys.length}: ${apiKey.substring(0, 30)}...');
          
          final response = await http.get(
            Uri.parse('$_baseUrl/customers?cpfCnpj=$cleanDocument'),
            headers: _getHeadersWithKey(apiKey),
          );

          print('📡 Status da requisição: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final customers = data['data'] as List;
            
            print('👥 Clientes encontrados: ${customers.length}');
            
            if (customers.isNotEmpty) {
              customerId = customers.first['id'];
              workingKey = apiKey;
              print('✅ Cliente encontrado! ID: $customerId');
              break;
            }
          } else {
            print('⚠️ Erro na API: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('❌ Erro ao testar chave ${i + 1}: $e');
          continue;
        }
      }

      if (customerId == null || workingKey == null) {
        print('❌ Cliente não encontrado em nenhuma conta Asaas para documento: $cleanDocument');
        return [];
      }

      print('💰 Buscando boletos do cliente...');
      
      // Busca os pagamentos do cliente com a chave que funcionou
      final response = await http.get(
        Uri.parse('$_baseUrl/payments?customer=$customerId&limit=100'),
        headers: _getHeadersWithKey(workingKey),
      );

      print('📡 Status busca pagamentos: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['data'] as List;
        
        print('📋 Total de pagamentos: ${payments.length}');
        
        List<Boleto> boletos = [];
        for (var payment in payments) {
          // Só adiciona se for boleto
          if (payment['billingType'] == 'BOLETO') {
            boletos.add(Boleto.fromAsaasJson(payment));
          }
        }
        
        // Ordena por data de vencimento (mais próximos primeiro)
        boletos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        
        print('🎯 ${boletos.length} boletos encontrados e processados!');
        return boletos;
      } else {
        print('❌ Erro ao buscar boletos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Erro geral ao buscar boletos: $e');
      return [];
    }
  }

  /// Força atualização dos boletos (ignora cache)
  static Future<List<Boleto>> refreshBoletosByDocument(String document) async {
    return await BoletoCacheService.forceRefresh(
      document,
      () => _fetchBoletosByDocumentFromApi(document),
    );
  }

  /// Busca boletos vencendo nos próximos dias
  static Future<List<Boleto>> getBoletosDueInDays(String document, int days) async {
    final allBoletos = await getBoletosByDocument(document);
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: days));
    
    return allBoletos.where((boleto) {
      return boleto.status == 'PENDING' && 
             boleto.dueDate.isAfter(now) && 
             boleto.dueDate.isBefore(targetDate);
    }).toList();
  }

  /// Busca boletos vencidos
  static Future<List<Boleto>> getBoletosOverdue(String document) async {
    final allBoletos = await getBoletosByDocument(document);
    final now = DateTime.now();
    
    return allBoletos.where((boleto) {
      return boleto.status == 'OVERDUE' || 
             (boleto.status == 'PENDING' && boleto.dueDate.isBefore(now));
    }).toList();
  }

  /// Busca detalhes de um boleto específico
  static Future<Boleto?> getBoletoDetails(String boletoId, String cnpj) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$boletoId'),
        headers: await _getHeaders(cnpj),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Boleto.fromAsaasJson(data);
      }
      
      return null;
    } catch (e) {
      print('Erro ao buscar detalhes do boleto: $e');
      return null;
    }
  }

  /// Verifica se há novos boletos (para notificações)
  static Future<List<Boleto>> checkNewBoletos(String document, DateTime lastCheck) async {
    final allBoletos = await getBoletosByDocument(document);
    
    return allBoletos.where((boleto) {
      return boleto.dateCreated.isAfter(lastCheck);
    }).toList();
  }

  /// Formatar valor monetário
  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formatar data
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Calcular dias até vencimento
  static int daysToDue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Verificar se boleto está próximo do vencimento
  static bool isNearDue(DateTime dueDate, {int days = 10}) {
    final daysTo = daysToDue(dueDate);
    return daysTo >= 0 && daysTo <= days;
  }


  // ====================================
  // MÉTODOS PARA GERENCIAR CHAVES ASAAS
  // ====================================

  /// Adiciona nova chave Asaas para a organização atual
  static Future<bool> addAsaasKey({
    required String nome,
    required String apiKey,
    bool ativo = true,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final userResponse = await Supabase.instance.client
          .from('users')
          .select('filial_id')
          .eq('id', user.id)
          .single();

      final organizacaoId = userResponse['filial_id'];
      
      // Chamar função SQL para adicionar chave
      await Supabase.instance.client.rpc('add_asaas_key', params: {
        'p_organizacao_id': organizacaoId,
        'p_nome_conta': nome,
        'p_api_key': apiKey,
        'p_ativo': ativo,
      });

      print('Chave Asaas adicionada com sucesso: $nome');
      return true;
    } catch (e) {
      print('Erro ao adicionar chave Asaas: $e');
      return false;
    }
  }

  /// Lista todas as chaves Asaas da organização
  static Future<List<Map<String, dynamic>>> listAsaasKeys() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final userResponse = await Supabase.instance.client
          .from('users')
          .select('filial_id')
          .eq('id', user.id)
          .single();

      final organizacaoId = userResponse['filial_id'];
      
      // Chamar função SQL para listar chaves
      final response = await Supabase.instance.client.rpc('get_active_asaas_keys', params: {
        'p_organizacao_id': organizacaoId,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao listar chaves Asaas: $e');
      return [];
    }
  }

  /// Desativa uma chave Asaas específica
  static Future<bool> deactivateAsaasKey(String keyId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final userResponse = await Supabase.instance.client
          .from('users')
          .select('filial_id')
          .eq('id', user.id)
          .single();

      final organizacaoId = userResponse['filial_id'];
      
      // Chamar função SQL para desativar chave
      await Supabase.instance.client.rpc('deactivate_asaas_key', params: {
        'p_organizacao_id': organizacaoId,
        'p_key_id': keyId,
      });

      print('Chave Asaas desativada com sucesso');
      return true;
    } catch (e) {
      print('Erro ao desativar chave Asaas: $e');
      return false;
    }
  }

  /// Testa uma chave Asaas (verifica se funciona)
  static Future<bool> testAsaasKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers?limit=1'),
        headers: _getHeadersWithKey(apiKey),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao testar chave Asaas: $e');
      return false;
    }
  }
}