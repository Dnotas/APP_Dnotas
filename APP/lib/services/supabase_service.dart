import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }
  
  static String? _currentUserId;
  
  static bool get isAuthenticated => _currentUserId != null;
  
  // Autenticação simples na tabela
  static Future<Map<String, dynamic>?> signInWithCnpjAndPassword({
    required String cnpj,
    required String password,
  }) async {
    try {
      // Remover formatação do CNPJ (manter apenas números)
      final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      
      print('CNPJ original: $cnpj');
      print('CNPJ limpo para busca: $cnpjLimpo');
      
      // Buscar cliente na tabela com CNPJ e senha
      final response = await client
          .from('clientes')
          .select('*')
          .eq('cnpj', cnpjLimpo) // Usar CNPJ sem formatação
          .eq('senha', password)
          .eq('is_active', true)
          .maybeSingle();
      
      print('Resposta da busca: $response');
      
      if (response != null) {
        _currentUserId = response['id'];
        
        // Buscar filiais do cliente
        final filiaisResponse = await client
            .from('client_filiais')
            .select('filial_cnpj, filial_nome')
            .eq('matriz_cnpj', cnpjLimpo)
            .eq('is_active', true);
        
        // Adicionar filiais ao response
        final filiais = filiaisResponse.map((filial) => {
          'cnpj': filial['filial_cnpj'],
          'nome': filial['filial_nome'],
        }).toList();
        
        response['filiais'] = filiais;
        
        print('✅ Login com ${filiais.length} filiais: $filiais');
        
        // Atualizar último login (removido por enquanto para evitar erro RLS)
        // await client
        //     .from('clientes')
        //     .update({'last_login': DateTime.now().toIso8601String()})
        //     .eq('id', _currentUserId!);
            
        return response;
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>?> signUpWithCnpj({
    required String cnpj,
    required String nomeEmpresa,
    required String email,
    required String password,
    required String filialId,
    String? telefone,
  }) async {
    try {
      // Verificar se CNPJ já existe
      final existingClient = await client
          .from('clientes')
          .select('id')
          .eq('cnpj', cnpj)
          .maybeSingle();
      
      if (existingClient != null) {
        throw Exception('CNPJ já cadastrado');
      }
      
      // Criar novo cliente
      final newClient = {
        'cnpj': cnpj,
        'nome_empresa': nomeEmpresa,
        'email': email,
        'senha': password,
        'filial_id': filialId,
        'telefone': telefone,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client
          .from('clientes')
          .insert(newClient)
          .select()
          .single();
      
      if (response != null) {
        _currentUserId = response['id'];
        return response;
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    _currentUserId = null;
  }
  
  // Dados do usuário
  static Future<UserModel?> getCurrentUserData() async {
    if (!isAuthenticated) return null;
    
    try {
      final response = await client
          .from('clientes')
          .select()
          .eq('id', _currentUserId!)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}