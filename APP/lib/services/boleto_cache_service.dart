import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boleto.dart';

/// Serviço para cache local de boletos
class BoletoCacheService {
  static const String _cachePrefix = 'boletos_cache_';
  static const String _lastUpdatePrefix = 'boletos_last_update_';
  static const Duration _cacheExpiration = Duration(hours: 1);

  /// Salvar boletos no cache
  static Future<void> saveBoletos(String userCnpj, List<Boleto> boletos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$userCnpj';
      final lastUpdateKey = '$_lastUpdatePrefix$userCnpj';
      
      // Converter boletos para JSON
      final boletosJson = boletos.map((b) => b.toJson()).toList();
      final jsonString = json.encode(boletosJson);
      
      // Salvar no cache
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString(lastUpdateKey, DateTime.now().toIso8601String());
      
      print('💾 ${boletos.length} boletos salvos no cache para $userCnpj');
    } catch (e) {
      print('❌ Erro ao salvar boletos no cache: $e');
    }
  }

  /// Buscar boletos do cache
  static Future<List<Boleto>> getBoletos(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$userCnpj';
      final lastUpdateKey = '$_lastUpdatePrefix$userCnpj';
      
      // Verificar se o cache existe e não expirou
      final jsonString = prefs.getString(cacheKey);
      final lastUpdateString = prefs.getString(lastUpdateKey);
      
      if (jsonString == null || lastUpdateString == null) {
        print('📭 Cache vazio para $userCnpj');
        return [];
      }
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      final isExpired = DateTime.now().difference(lastUpdate) > _cacheExpiration;
      
      if (isExpired) {
        print('⏰ Cache expirado para $userCnpj');
        await clearBoletos(userCnpj);
        return [];
      }
      
      // Converter JSON para objetos Boleto
      final List<dynamic> boletosJson = json.decode(jsonString);
      final boletos = boletosJson.map((json) => Boleto.fromJson(json)).toList();
      
      print('📂 ${boletos.length} boletos carregados do cache para $userCnpj');
      return boletos;
      
    } catch (e) {
      print('❌ Erro ao buscar boletos do cache: $e');
      return [];
    }
  }

  /// Verificar se o cache é válido
  static Future<bool> isCacheValid(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateKey = '$_lastUpdatePrefix$userCnpj';
      final lastUpdateString = prefs.getString(lastUpdateKey);
      
      if (lastUpdateString == null) return false;
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      final isValid = DateTime.now().difference(lastUpdate) <= _cacheExpiration;
      
      return isValid;
    } catch (e) {
      return false;
    }
  }

  /// Limpar cache de um usuário específico
  static Future<void> clearBoletos(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$userCnpj';
      final lastUpdateKey = '$_lastUpdatePrefix$userCnpj';
      
      await prefs.remove(cacheKey);
      await prefs.remove(lastUpdateKey);
      
      print('🧹 Cache de boletos limpo para $userCnpj');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  /// Limpar todo o cache de boletos
  static Future<void> clearAllBoletos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Filtrar apenas chaves relacionadas a boletos
      final boletoKeys = keys.where((key) => 
        key.startsWith(_cachePrefix) || key.startsWith(_lastUpdatePrefix)
      ).toList();
      
      for (final key in boletoKeys) {
        await prefs.remove(key);
      }
      
      print('🧹 Todo cache de boletos limpo (${boletoKeys.length} entradas)');
    } catch (e) {
      print('❌ Erro ao limpar todo cache: $e');
    }
  }

  /// Atualizar um boleto específico no cache
  static Future<void> updateBoleto(String userCnpj, Boleto updatedBoleto) async {
    try {
      final cachedBoletos = await getBoletos(userCnpj);
      
      // Encontrar e atualizar o boleto
      final index = cachedBoletos.indexWhere((b) => b.id == updatedBoleto.id);
      
      if (index != -1) {
        cachedBoletos[index] = updatedBoleto;
        await saveBoletos(userCnpj, cachedBoletos);
        print('🔄 Boleto ${updatedBoleto.id} atualizado no cache');
      } else {
        // Adicionar novo boleto se não existir
        cachedBoletos.add(updatedBoleto);
        await saveBoletos(userCnpj, cachedBoletos);
        print('➕ Novo boleto ${updatedBoleto.id} adicionado ao cache');
      }
    } catch (e) {
      print('❌ Erro ao atualizar boleto no cache: $e');
    }
  }

  /// Remover um boleto específico do cache
  static Future<void> removeBoleto(String userCnpj, String boletoId) async {
    try {
      final cachedBoletos = await getBoletos(userCnpj);
      
      // Remover o boleto
      cachedBoletos.removeWhere((b) => b.id == boletoId);
      
      await saveBoletos(userCnpj, cachedBoletos);
      print('🗑️ Boleto $boletoId removido do cache');
    } catch (e) {
      print('❌ Erro ao remover boleto do cache: $e');
    }
  }

  /// Obter estatísticas do cache
  static Future<Map<String, dynamic>> getCacheStats(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateKey = '$_lastUpdatePrefix$userCnpj';
      final lastUpdateString = prefs.getString(lastUpdateKey);
      
      final boletos = await getBoletos(userCnpj);
      final isValid = await isCacheValid(userCnpj);
      
      DateTime? lastUpdate;
      if (lastUpdateString != null) {
        lastUpdate = DateTime.parse(lastUpdateString);
      }
      
      return {
        'total_boletos': boletos.length,
        'cache_valid': isValid,
        'last_update': lastUpdate?.toIso8601String(),
        'pending_boletos': boletos.where((b) => b.status == 'PENDING').length,
        'overdue_boletos': boletos.where((b) => b.isOverdue).length,
        'paid_boletos': boletos.where((b) => 
          b.status == 'RECEIVED' || 
          b.status == 'CONFIRMED' || 
          b.status == 'RECEIVED_IN_CASH'
        ).length,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas do cache: $e');
      return {};
    }
  }

  /// Buscar boletos com fallback para cache
  static Future<List<Boleto>> getBoletosWithFallback(
    String userCnpj, 
    Future<List<Boleto>> Function() fetchFromApi
  ) async {
    try {
      // Tentar carregar do cache primeiro
      if (await isCacheValid(userCnpj)) {
        final cachedBoletos = await getBoletos(userCnpj);
        if (cachedBoletos.isNotEmpty) {
          print('📂 Usando boletos do cache');
          
          // Buscar da API em background para atualizar cache
          fetchFromApi().then((apiBoletos) {
            saveBoletos(userCnpj, apiBoletos);
          }).catchError((e) {
            print('⚠️ Erro ao atualizar cache em background: $e');
          });
          
          return cachedBoletos;
        }
      }
      
      // Cache inválido ou vazio, buscar da API
      print('🌐 Buscando boletos da API');
      final apiBoletos = await fetchFromApi();
      
      // Salvar no cache para próximas consultas
      await saveBoletos(userCnpj, apiBoletos);
      
      return apiBoletos;
      
    } catch (e) {
      print('❌ Erro na busca com fallback: $e');
      
      // Em caso de erro, tentar retornar cache mesmo que expirado
      final cachedBoletos = await getBoletos(userCnpj);
      if (cachedBoletos.isNotEmpty) {
        print('🆘 Usando cache expirado como fallback');
        return cachedBoletos;
      }
      
      return [];
    }
  }

  /// Força atualização do cache
  static Future<List<Boleto>> forceRefresh(
    String userCnpj,
    Future<List<Boleto>> Function() fetchFromApi
  ) async {
    try {
      print('🔄 Forçando atualização do cache');
      
      // Limpar cache atual
      await clearBoletos(userCnpj);
      
      // Buscar dados frescos da API
      final apiBoletos = await fetchFromApi();
      
      // Salvar no cache
      await saveBoletos(userCnpj, apiBoletos);
      
      return apiBoletos;
    } catch (e) {
      print('❌ Erro ao forçar atualização: $e');
      rethrow;
    }
  }
}