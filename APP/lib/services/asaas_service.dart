import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boleto.dart';
import '../models/customer.dart';
import './boleto_cache_service.dart';

class AsaasService {
  static const String _baseUrl = 'https://api.asaas.com/v3';
  static const String _sandboxUrl = 'https://api-sandbox.asaas.com/v3';
  
  // Chaves da API fornecidas
  static const String _cpfApiKey = '\$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmRlOTdhM2E5LTVmYjQtNDA4MS04OWMwLTdhZDZmYTE4MzQxNjo6\$aach_aa21017d-ea4b-4ab6-8f1b-a8b17ba8d0b8';
  static const String _cnpjApiKey = r'$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmIzNGI0YWNjLWZkZmYtNDM2Yy04NWJiLWJiYTk0YzAyYjljODo6JGFhY2hfZWIzMmFiZmMtNzQ3OS00N2ZlLWI0NDEtYmMwZjhmNGQ4YWU2';
  
  // Chave oficial da empresa (CNPJ)  
  static const String _testApiKey = r'$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmIzNGI0YWNjLWZkZmYtNDM2Yy04NWJiLWJiYTk0YzAyYjljODo6JGFhY2hfZWIzMmFiZmMtNzQ3OS00N2ZlLWI0NDEtYmMwZjhmNGQ4YWU2';

  /// Retorna a chave da API baseada no tipo de documento
  static String _getApiKey(String documentType) {
    return documentType.toLowerCase() == 'cpf' ? _cpfApiKey : _cnpjApiKey;
  }

  /// Retorna a chave de teste
  static String _getTestApiKey() {
    return _testApiKey;
  }

  /// Headers para teste
  static Map<String, String> _getTestHeaders() {
    return {
      'accept': 'application/json',
      'access_token': _getTestApiKey(),
    };
  }

  /// Headers padrão para requisições
  static Map<String, String> _getHeaders(String documentType) {
    return {
      'accept': 'application/json',
      'access_token': _getApiKey(documentType),
    };
  }

  /// Busca cliente na API Asaas pelo CPF/CNPJ
  static Future<String?> findCustomerByDocument(String document) async {
    try {
      // Remove formatação do documento
      final cleanDocument = document.replaceAll(RegExp(r'[^0-9]'), '');
      final documentType = cleanDocument.length == 11 ? 'cpf' : 'cnpj';
      
      final response = await http.get(
        Uri.parse('$_baseUrl/customers?cpfCnpj=$cleanDocument'),
        headers: _getHeaders(documentType),
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

  /// Busca boletos direto da API (sem cache)
  static Future<List<Boleto>> _fetchBoletosByDocumentFromApi(String document) async {
    try {
      // Primeiro, encontra o ID do cliente
      final customerId = await findCustomerByDocument(document);
      if (customerId == null) {
        print('Cliente não encontrado para documento: $document');
        return [];
      }

      // Remove formatação do documento para determinar tipo
      final cleanDocument = document.replaceAll(RegExp(r'[^0-9]'), '');
      final documentType = cleanDocument.length == 11 ? 'cpf' : 'cnpj';

      // Busca os pagamentos do cliente
      final response = await http.get(
        Uri.parse('$_baseUrl/payments?customer=$customerId&limit=100'),
        headers: _getHeaders(documentType),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['data'] as List;
        
        List<Boleto> boletos = [];
        for (var payment in payments) {
          // Só adiciona se for boleto
          if (payment['billingType'] == 'BOLETO') {
            boletos.add(Boleto.fromAsaasJson(payment));
          }
        }
        
        // Ordena por data de vencimento (mais próximos primeiro)
        boletos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        
        return boletos;
      } else {
        print('Erro ao buscar boletos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar boletos: $e');
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
  static Future<Boleto?> getBoletoDetails(String boletoId, String documentType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$boletoId'),
        headers: _getHeaders(documentType),
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

  /// TESTE: Lista todos os clientes da sua conta para debug
  static Future<void> testListCustomers() async {
    try {
      print('🧪 TESTE: Listando clientes da conta de teste...');
      print('🧪 DEBUG: Chave sendo enviada: ${_getTestApiKey()}');
      print('🧪 DEBUG: Headers: ${_getTestHeaders()}');
      
      // Testa PRODUÇÃO com headers corretos
      print('🧪 TESTE: Tentando PRODUÇÃO: $_baseUrl');
      var response = await http.get(
        Uri.parse('$_baseUrl/customers?limit=50'),
        headers: _getTestHeaders(),
      );
      print('🧪 TESTE: Status PRODUÇÃO: ${response.statusCode}');
      print('🧪 TESTE: Response body: ${response.body}');

      print('🧪 TESTE: Status da resposta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customers = data['data'] as List;
        
        print('🧪 TESTE: ${customers.length} clientes encontrados:');
        for (var customer in customers) {
          print('   • ID: ${customer['id']}');
          print('   • Nome: ${customer['name']}');
          print('   • CPF/CNPJ: ${customer['cpfCnpj']}');
          print('   • Email: ${customer['email']}');
          print('   ---');
        }
      } else {
        print('🧪 TESTE: Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🧪 TESTE: Erro na requisição: $e');
    }
  }

  /// TESTE: Busca boletos usando sua chave de teste
  static Future<List<Boleto>> testGetBoletosByDocument(String document) async {
    try {
      print('🧪 TESTE: Buscando boletos para documento: $document');
      
      // Primeiro, encontra o ID do cliente
      final cleanDocument = document.replaceAll(RegExp(r'[^0-9]'), '');
      
      final customerResponse = await http.get(
        Uri.parse('$_baseUrl/customers?cpfCnpj=$cleanDocument'),
        headers: _getTestHeaders(),
      );

      print('🧪 TESTE: Busca cliente - Status: ${customerResponse.statusCode}');

      if (customerResponse.statusCode != 200) {
        print('🧪 TESTE: Erro ao buscar cliente: ${customerResponse.body}');
        return [];
      }

      final customerData = json.decode(customerResponse.body);
      final customers = customerData['data'] as List;
      
      if (customers.isEmpty) {
        print('🧪 TESTE: Cliente não encontrado');
        return [];
      }

      final customerId = customers.first['id'];
      print('🧪 TESTE: Cliente encontrado - ID: $customerId');

      // Busca os pagamentos do cliente
      final paymentsResponse = await http.get(
        Uri.parse('$_baseUrl/payments?customer=$customerId&limit=100'),
        headers: _getTestHeaders(),
      );

      print('🧪 TESTE: Busca pagamentos - Status: ${paymentsResponse.statusCode}');

      if (paymentsResponse.statusCode == 200) {
        final paymentsData = json.decode(paymentsResponse.body);
        final payments = paymentsData['data'] as List;
        
        print('🧪 TESTE: ${payments.length} pagamentos encontrados');
        
        List<Boleto> boletos = [];
        for (var payment in payments) {
          print('🧪 TESTE: Payment - Type: ${payment['billingType']}, Status: ${payment['status']}, Value: ${payment['value']}');
          
          if (payment['billingType'] == 'BOLETO') {
            boletos.add(Boleto.fromAsaasJson(payment));
          }
        }
        
        print('🧪 TESTE: ${boletos.length} boletos filtrados');
        return boletos;
      } else {
        print('🧪 TESTE: Erro ao buscar pagamentos: ${paymentsResponse.body}');
        return [];
      }
    } catch (e) {
      print('🧪 TESTE: Erro: $e');
      return [];
    }
  }
}