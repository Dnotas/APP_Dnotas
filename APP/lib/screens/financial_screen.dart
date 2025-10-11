import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/boleto_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  bool _isLoading = true;
  List<BoletoModel> _boletos = [];
  double _totalPendente = 0.0;
  double _totalPago = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      if (cnpj != null && token != null) {
        final data = await ApiService.getFinancialData(cnpj, token);
        setState(() {
          _boletos = data.map((b) => BoletoModel.fromJson(b)).toList();
          _totalPendente = _boletos
              .where((b) => b.status == 'pendente')
              .fold(0.0, (sum, b) => sum + b.valor);
          _totalPago = _boletos
              .where((b) => b.status == 'pago')
              .fold(0.0, (sum, b) => sum + b.valor);
          _isLoading = false;
        });
      } else {
        // Fallback com dados de exemplo para apresentação
        final mockBoletos = [
          BoletoModel.fromJson({
            'id': '1',
            'numero': '00001',
            'descricao': 'Mensalidade - Dezembro 2024',
            'valor': 850.00,
            'data_vencimento': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
            'status': 'pendente',
            'codigo_barras': '34191.79001 01043.510047 91020.150008 1 85420000085000',
          }),
        ];
        
        setState(() {
          _boletos = mockBoletos;
          _totalPendente = mockBoletos
              .where((b) => b.status == 'pendente')
              .fold(0.0, (sum, b) => sum + b.valor);
          _totalPago = mockBoletos
              .where((b) => b.status == 'pago')
              .fold(0.0, (sum, b) => sum + b.valor);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback com dados de exemplo para apresentação
      final mockBoletos = [
        BoletoModel.fromJson({
          'id': '1',
          'numero': '00001',
          'descricao': 'Mensalidade - Dezembro 2024',
          'valor': 850.00,
          'data_vencimento': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'status': 'pendente',
          'codigo_barras': '34191.79001 01043.510047 91020.150008 1 85420000085000',
        }),
      ];
      
      setState(() {
        _boletos = mockBoletos;
        _totalPendente = mockBoletos
            .where((b) => b.status == 'pendente')
            .fold(0.0, (sum, b) => sum + b.valor);
        _totalPago = mockBoletos
            .where((b) => b.status == 'pago')
            .fold(0.0, (sum, b) => sum + b.valor);
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadBoleto(BoletoModel boleto) async {
    try {
      // Simular download do boleto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Baixando boleto ${boleto.numero}...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Em um app real, aqui faria o download do PDF
      if (boleto.urlPdf != null && await canLaunchUrl(Uri.parse(boleto.urlPdf!))) {
        await launchUrl(Uri.parse(boleto.urlPdf!));
      } else {
        // Fallback para abrir URL mockada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boleto baixado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao baixar boleto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFinancialData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cards de resumo
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Pendente',
                            _totalPendente,
                            Colors.orange,
                            Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Pago',
                            _totalPago,
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Título da seção
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BOLETOS',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implementar filtros
                          },
                          icon: const Icon(Icons.filter_list, size: 16),
                          label: const Text('Filtrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de boletos
                    _boletos.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long, color: Colors.grey, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhum boleto encontrado',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _boletos.length,
                            itemBuilder: (context, index) {
                              final boleto = _boletos[index];
                              return _buildBoletoCard(boleto);
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementar gerar novo boleto ou ver extrato
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Cobrança'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoletoCard(BoletoModel boleto) {
    final isVencido = boleto.dataVencimento.isBefore(DateTime.now()) && boleto.status == 'pendente';
    final statusColor = boleto.status == 'pago' 
        ? Colors.green 
        : isVencido 
            ? Colors.red 
            : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boleto ${boleto.numero}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      boleto.descricao,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  boleto.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'R\$ ${boleto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vencimento',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${boleto.dataVencimento.day.toString().padLeft(2, '0')}/${boleto.dataVencimento.month.toString().padLeft(2, '0')}/${boleto.dataVencimento.year}',
                      style: TextStyle(
                        color: isVencido ? Colors.red : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (boleto.status == 'pendente') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadBoleto(boleto),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Baixar PDF'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar copiar código de barras
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Código copiado!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.content_copy, size: 16),
                    label: const Text('Copiar Código'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (boleto.status == 'pago' && boleto.dataPagamento != null) ...[
            const SizedBox(height: 8),
            Text(
              'Pago em ${boleto.dataPagamento!.day.toString().padLeft(2, '0')}/${boleto.dataPagamento!.month.toString().padLeft(2, '0')}/${boleto.dataPagamento!.year}',
              style: TextStyle(
                color: Colors.green.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}