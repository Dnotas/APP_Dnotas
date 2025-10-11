import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/message_model.dart';
import '../models/boleto_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Altere para sua URL de produção
  
  static Future<Map<String, dynamic>> getClientReports(String cnpj, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reports/cliente/$cnpj'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final reportData = data['data'];
          final transactions = (reportData as List)
              .map((t) => TransactionModel.fromJson(t))
              .toList();
          
          // Calcular totais dos relatórios reais
          double totalVendas = 0;
          double vendasDoDia = 0;
          final hoje = DateTime.now();
          
          for (var transaction in transactions) {
            totalVendas += transaction.amount;
            if (transaction.date.day == hoje.day && 
                transaction.date.month == hoje.month &&
                transaction.date.year == hoje.year) {
              vendasDoDia += transaction.amount;
            }
          }
          
          return {
            'transactions': transactions,
            'balance': totalVendas,
            'daily_sales': vendasDoDia,
          };
        }
      }
      
      throw Exception('Falha ao carregar relatórios: ${response.statusCode}');
    } catch (e) {
      print('Erro ao carregar relatórios: $e');
      rethrow;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getChatMessages(String cnpj, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mensagens/cliente/$cnpj'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      throw Exception('Falha ao carregar mensagens: ${response.statusCode}');
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      rethrow;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getFinancialData(String cnpj, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/financial/boletos/cliente/$cnpj'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      throw Exception('Falha ao carregar dados financeiros: ${response.statusCode}');
    } catch (e) {
      print('Erro ao carregar dados financeiros: $e');
      rethrow;
    }
  }
  
  static Future<bool> sendChatMessage(String cnpj, String message, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mensagens/enviar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'cliente_cnpj': cnpj,
          'conteudo': message,
          'tipo': 'texto',
          'remetente': 'cliente',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      
      return false;
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return false;
    }
  }

  // Método para login de clientes
  static Future<Map<String, dynamic>?> login(String cnpj, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cnpj': cnpj,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  // Método para registro de clientes
  static Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      print('Erro ao registrar: $e');
      return null;
    }
  }
}