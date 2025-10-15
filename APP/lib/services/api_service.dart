import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/message_model.dart';
import '../models/boleto_model.dart';
import 'supabase_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:1111'; // Altere para sua URL de produção
  
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

  // Método para buscar relatórios de vendas do dia - CONSULTA DIRETA SUPABASE
  static Future<Map<String, double>> getDailyReports(String cnpj, [String? token]) async {
    try {
      final supabase = SupabaseService.client;
      final hoje = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      
      // Limpar CNPJ removendo pontos, traços e barras
      final cnpjLimpo = cnpj.replaceAll(RegExp(r'[.\-/]'), '');
      
      print('DEBUG API: CNPJ original: $cnpj');
      print('DEBUG API: CNPJ limpo: $cnpjLimpo');
      print('DEBUG API: Data consulta: $hoje');
      
      // Primeiro, vamos ver todos os registros para esse CNPJ
      try {
        final todosRegistros = await supabase
            .from('relatorios_vendas')
            .select('cliente_cnpj, data_relatorio')
            .eq('cliente_cnpj', cnpjLimpo);
        print('DEBUG API: Todos registros para CNPJ: $todosRegistros');
      } catch (e) {
        print('DEBUG API: Erro ao buscar todos registros: $e');
      }
      
      // Teste sem filtro para ver se consegue acessar a tabela
      try {
        final testeAcesso = await supabase
            .from('relatorios_vendas')
            .select('cliente_cnpj, data_relatorio')
            .limit(1);
        print('DEBUG API: Teste acesso tabela: $testeAcesso');
      } catch (e) {
        print('DEBUG API: Erro no teste de acesso: $e');
      }
      
      // Agora a consulta específica
      final response = await supabase
          .from('relatorios_vendas')
          .select('*')
          .eq('cliente_cnpj', cnpjLimpo)
          .eq('data_relatorio', hoje)
          .maybeSingle();
          
      print('DEBUG API: Resposta Supabase: $response');

      if (response != null) {
        return {
          'credito': (response['vendas_credito'] ?? 0.0).toDouble(),
          'debito': (response['vendas_debito'] ?? 0.0).toDouble(),
          'pix': (response['vendas_pix'] ?? 0.0).toDouble(),
          'vale': (response['vendas_vale'] ?? 0.0).toDouble(),
          'dinheiro': (response['vendas_dinheiro'] ?? 0.0).toDouble(),
          'transferencia': (response['vendas_transferencia'] ?? 0.0).toDouble(),
        };
      }
      
      // Retorna zeros se não encontrar dados
      return {
        'credito': 0.0,
        'debito': 0.0,
        'pix': 0.0,
        'vale': 0.0,
        'dinheiro': 0.0,
        'transferencia': 0.0,
      };
    } catch (e) {
      print('Erro ao carregar relatórios de vendas: $e');
      // Retorna zeros em caso de erro
      return {
        'credito': 0.0,
        'debito': 0.0,
        'pix': 0.0,
        'vale': 0.0,
        'dinheiro': 0.0,
        'transferencia': 0.0,
      };
    }
  }

  // Método para solicitar relatório customizado
  static Future<bool> solicitarRelatorio({
    required String cnpj,
    required String token,
    required DateTime dataInicio,
    required DateTime dataFim,
    required String tipoPeriodo,
    String? observacoes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/solicitacoes/relatorio'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'cliente_cnpj': cnpj,
          'data_inicio': dataInicio.toIso8601String().split('T')[0],
          'data_fim': dataFim.toIso8601String().split('T')[0],
          'tipo_periodo': tipoPeriodo,
          'observacoes': observacoes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      
      return false;
    } catch (e) {
      print('Erro ao solicitar relatório: $e');
      return false;
    }
  }

  // Método para buscar solicitações de relatórios do cliente
  static Future<List<Map<String, dynamic>>> getSolicitacoesRelatorios(String cnpj, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/solicitacoes/relatorio/$cnpj'),
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
      
      return [];
    } catch (e) {
      print('Erro ao buscar solicitações de relatórios: $e');
      return [];
    }
  }

  // Método para buscar relatório processado
  static Future<Map<String, dynamic>?> getRelatorioProcessado(String solicitacaoId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/relatorios/processado/$solicitacaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('Erro ao buscar relatório processado: $e');
      return null;
    }
  }
}