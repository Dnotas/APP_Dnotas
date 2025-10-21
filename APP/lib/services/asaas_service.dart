import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boleto.dart';
import '../models/customer.dart';
import './boleto_cache_service.dart';

class AsaasService {
  static const String _baseUrl = 'https://api.asaas.com/v3';
  
  // Chaves da API fornecidas
  static const String _cpfApiKey = '\$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmRlOTdhM2E5LTVmYjQtNDA4MS04OWMwLTdhZDZmYTE4MzQxNjo6\$aach_aa21017d-ea4b-4ab6-8f1b-a8b17ba8d0b8';
  static const String _cnpjApiKey = '\$aact_prod_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OmIzNGI0YWNjLWZkZmYtNDM2Yy04NWJiLWJiYTk0YzAyYjljODo6\$aach_eb32abfc-7479-47fe-b441-bc0f8f4d8ae6';

  /// Retorna a chave da API baseada no tipo de documento
  static String _getApiKey(String documentType) {
    return documentType.toLowerCase() == 'cpf' ? _cpfApiKey : _cnpjApiKey;
  }

  /// Headers padrão para requisições
  static Map<String, String> _getHeaders(String documentType) {
    return {
      'Content-Type': 'application/json',
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
}