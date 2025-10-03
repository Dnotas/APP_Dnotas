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
      // Buscar cliente na tabela com CNPJ e senha
      final response = await client
          .from('clientes')
          .select('*')
          .eq('cnpj', cnpj)
          .eq('senha', password)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response != null) {
        _currentUserId = response['id'];
        
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