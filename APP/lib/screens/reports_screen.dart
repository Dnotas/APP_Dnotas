import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  double _totalVendas = 0.0;
  double _vendasCredito = 0.0;
  double _vendasDebito = 0.0;
  double _vendasPix = 0.0;
  double _vendasValeAlimentacao = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      if (cnpj != null && token != null) {
        // TODO: Implementar API para buscar dados de vendas reais
        // final data = await ApiService.getClientSales(cnpj, token);
        setState(() {
          _vendasCredito = 15250.30;
          _vendasDebito = 8975.45;
          _vendasPix = 12380.90;
          _vendasValeAlimentacao = 3420.75;
          _totalVendas = _vendasCredito + _vendasDebito + _vendasPix + _vendasValeAlimentacao;
          _isLoading = false;
        });
      } else {
        // Dados de exemplo para apresentação
        setState(() {
          _vendasCredito = 15250.30;
          _vendasDebito = 8975.45;
          _vendasPix = 12380.90;
          _vendasValeAlimentacao = 3420.75;
          _totalVendas = _vendasCredito + _vendasDebito + _vendasPix + _vendasValeAlimentacao;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback com dados de exemplo
      setState(() {
        _vendasCredito = 15250.30;
        _vendasDebito = 8975.45;
        _vendasPix = 12380.90;
        _vendasValeAlimentacao = 3420.75;
        _totalVendas = _vendasCredito + _vendasDebito + _vendasPix + _vendasValeAlimentacao;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/images/logo_dnotas.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business, color: Colors.black, size: 16);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              user?.nomeEmpresa ?? 'DNOTAS',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Relatórios',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card principal com design de cartão real
                    Center(
                      child: Container(
                        width: 340,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1E1E1E),
                              Color(0xFF2A2A2A),
                              Color(0xFF1A1A1A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Linhas cyberpunk decorativas
                            Positioned(
                              top: 20,
                              left: 20,
                              right: 80,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 80,
                              right: 20,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Padrão decorativo no fundo
                            Positioned(
                              right: -30,
                              top: -30,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.03),
                                ),
                              ),
                            ),
                            // Conteúdo do cartão
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo DNOTAS no topo
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'DNOTAS',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.contactless,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Nome da empresa
                                  Text(
                                    user?.nomeEmpresa ?? 'Empresa',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Total de Vendas
                                  const Text(
                                    'TOTAL DE VENDAS',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'R\$ ${_totalVendas.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'BRL',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Número do cartão estilizado
                                  Text(
                                    '•••• •••• •••• ${user?.cnpj?.substring(10) ?? '0000'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Cards de vendas por método de pagamento
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.credit_card, color: Colors.blue, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'Crédito',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasCredito.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.payment, color: Colors.green, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'Débito',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasDebito.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.qr_code, color: Colors.purple, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'PIX',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasPix.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.restaurant, color: Colors.orange, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'Vale Alim.',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasValeAlimentacao.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Resumo mensal
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumo do mês',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Veja o desempenho completo das suas vendas',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

}