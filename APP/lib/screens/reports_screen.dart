import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'calendar_report_screen.dart';

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
  double _vendasDinheiro = 0.0;
  double _vendasTransferencia = 0.0;
  
  List<Map<String, dynamic>> _solicitacoesRelatorios = [];
  bool _isLoadingSolicitacoes = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSolicitacoes();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      print('DEBUG: CNPJ: $cnpj');
      print('DEBUG: Token: ${token != null ? 'EXISTS' : 'NULL'}');
      
      if (cnpj != null) {
        print('DEBUG: Chamando getDailyReports...');
        final data = await ApiService.getDailyReports(cnpj);
        print('DEBUG: Dados recebidos: $data');
        setState(() {
          _vendasCredito = data['credito'] ?? 0.0;
          _vendasDebito = data['debito'] ?? 0.0;
          _vendasPix = data['pix'] ?? 0.0;
          _vendasValeAlimentacao = data['vale'] ?? 0.0;
          _vendasDinheiro = data['dinheiro'] ?? 0.0;
          _vendasTransferencia = data['transferencia'] ?? 0.0;
          _totalVendas = _vendasCredito + _vendasDebito + _vendasPix + _vendasValeAlimentacao + _vendasDinheiro + _vendasTransferencia;
          _isLoading = false;
        });
      } else {
        print('DEBUG: CNPJ é null - sem dados para exibir');
        setState(() {
          _vendasCredito = 0.0;
          _vendasDebito = 0.0;
          _vendasPix = 0.0;
          _vendasValeAlimentacao = 0.0;
          _vendasDinheiro = 0.0;
          _vendasTransferencia = 0.0;
          _totalVendas = 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Erro ao carregar dados: $e');
      // Retorna zeros em caso de erro
      setState(() {
        _vendasCredito = 0.0;
        _vendasDebito = 0.0;
        _vendasPix = 0.0;
        _vendasValeAlimentacao = 0.0;
        _vendasDinheiro = 0.0;
        _vendasTransferencia = 0.0;
        _totalVendas = 0.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSolicitacoes() async {
    setState(() {
      _isLoadingSolicitacoes = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      if (cnpj != null && token != null) {
        final solicitacoes = await ApiService.getSolicitacoesRelatorios(cnpj, token);
        setState(() {
          _solicitacoesRelatorios = solicitacoes;
        });
      }
    } catch (e) {
      print('Erro ao carregar solicitações: $e');
    } finally {
      setState(() {
        _isLoadingSolicitacoes = false;
      });
    }
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarReportScreen(),
      ),
    );
    
    // Se retornou true, significa que foi feita uma solicitação
    if (result == true) {
      _loadSolicitacoes(); // Recarrega as solicitações
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
                    const SizedBox(height: 8),
                    // Row adicional para Dinheiro e Transferência
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
                                const Icon(Icons.money, color: Colors.yellow, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'Dinheiro',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasDinheiro.toStringAsFixed(2).replaceAll('.', ',')}',
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
                                const Icon(Icons.swap_horiz, color: Colors.cyan, size: 20),
                                const SizedBox(height: 4),
                                const Text(
                                  'Transfer.',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R\$ ${_vendasTransferencia.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Botão para solicitar relatório customizado
                    GestureDetector(
                      onTap: _openCalendar,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.blue, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Solicitar Relatório',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Escolha a data ou período para relatório personalizado',
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
                    ),

                    const SizedBox(height: 16),

                    // Lista de relatórios solicitados
                    if (_solicitacoesRelatorios.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Relatórios Solicitados',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_solicitacoesRelatorios.length}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...(_solicitacoesRelatorios.take(3).map((solicitacao) {
                              final status = solicitacao['status'] as String;
                              final dataInicio = DateTime.parse(solicitacao['data_inicio']);
                              final dataFim = DateTime.parse(solicitacao['data_fim']);
                              final tipoPeriodo = solicitacao['tipo_periodo'] as String;
                              
                              Color statusColor;
                              IconData statusIcon;
                              
                              switch (status) {
                                case 'pendente':
                                  statusColor = Colors.orange;
                                  statusIcon = Icons.schedule;
                                  break;
                                case 'processando':
                                  statusColor = Colors.blue;
                                  statusIcon = Icons.refresh;
                                  break;
                                case 'concluido':
                                  statusColor = Colors.green;
                                  statusIcon = Icons.check_circle;
                                  break;
                                default:
                                  statusColor = Colors.red;
                                  statusIcon = Icons.error;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(statusIcon, color: statusColor, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tipoPeriodo == 'dia_unico' 
                                                ? '${dataInicio.day}/${dataInicio.month}/${dataInicio.year}'
                                                : '${dataInicio.day}/${dataInicio.month} até ${dataFim.day}/${dataFim.month}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (status == 'concluido')
                                      const Icon(Icons.visibility, color: Colors.grey, size: 16),
                                  ],
                                ),
                              );
                            }).toList()),
                            if (_solicitacoesRelatorios.length > 3)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'e mais ${_solicitacoesRelatorios.length - 3} solicitações...',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

}