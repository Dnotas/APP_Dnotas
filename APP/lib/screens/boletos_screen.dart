import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/boleto.dart';
import '../services/asaas_service.dart';
import '../services/boleto_cache_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BoletosScreen extends StatefulWidget {
  const BoletosScreen({super.key});

  @override
  State<BoletosScreen> createState() => _BoletosScreenState();
}

class _BoletosScreenState extends State<BoletosScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Boleto> _allBoletos = [];
  List<Boleto> _pendingBoletos = [];
  List<Boleto> _overdueBoletos = [];
  List<Boleto> _paidBoletos = [];
  bool _isLoading = true;
  String? _currentCnpj;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBoletos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBoletos() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final document = authProvider.currentCnpj ?? '';
      
      // Atualizar CNPJ atual para detectar mudanças
      _currentCnpj = document;
      
      if (document.isNotEmpty) {
        final boletos = await AsaasService.getBoletosByDocument(document);
        
        setState(() {
          _allBoletos = boletos;
          _pendingBoletos = boletos.where((b) => b.status == 'PENDING').toList();
          _overdueBoletos = boletos.where((b) => b.isOverdue).toList();
          _paidBoletos = boletos.where((b) => 
            b.status == 'RECEIVED' || 
            b.status == 'CONFIRMED' || 
            b.status == 'RECEIVED_IN_CASH'
          ).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar boletos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _forceRefresh() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final document = authProvider.currentCnpj ?? '';
      
      if (document.isNotEmpty) {
        // Força busca da API ignorando cache
        final boletos = await AsaasService.refreshBoletosByDocument(document);
        
        setState(() {
          _allBoletos = boletos;
          _pendingBoletos = boletos.where((b) => b.status == 'PENDING').toList();
          _overdueBoletos = boletos.where((b) => b.isOverdue).toList();
          _paidBoletos = boletos.where((b) => 
            b.status == 'RECEIVED' || 
            b.status == 'CONFIRMED' || 
            b.status == 'RECEIVED_IN_CASH'
          ).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boletos atualizados com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar boletos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testApiWithYourKey() async {
    try {
      print('🧪 INICIANDO TESTE COM SUA CHAVE...');
      
      // Primeiro, lista todos os clientes da sua conta
      print('🧪 Testando busca com chaves do banco de dados...');
      
      // Depois tenta buscar boletos para um documento específico
      // CNPJ da AM CONTABILIDADE LTDA que existe na sua conta Asaas
      final testDocument = '24831337000109';
      final boletos = await AsaasService.getBoletosByDocument(testDocument);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teste concluído! ${boletos.length} boletos encontrados. Veja o console.'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print('🧪 ERRO NO TESTE: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no teste: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Verificar se o CNPJ mudou e recarregar se necessário
        final currentDocument = authProvider.currentCnpj ?? '';
        if (_currentCnpj != currentDocument && currentDocument.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadBoletos());
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Boletos',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _forceRefresh,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF8B5CF6),
              tabs: [
                Tab(
                  text: 'Pendentes',
                  icon: Badge(
                    label: Text('${_pendingBoletos.length}'),
                    child: const Icon(Icons.schedule),
                  ),
                ),
                Tab(
                  text: 'Vencidos',
                  icon: Badge(
                    label: Text('${_overdueBoletos.length}'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.warning),
                  ),
                ),
                Tab(
                  text: 'Pagos',
                  icon: Badge(
                    label: Text('${_paidBoletos.length}'),
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check_circle),
                  ),
                ),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBoletosList(_pendingBoletos, 'Nenhum boleto pendente'),
                    _buildBoletosList(_overdueBoletos, 'Nenhum boleto vencido'),
                    _buildBoletosList(_paidBoletos, 'Nenhum boleto pago'),
                  ],
                ),
        );
      },
    );
  }


  Widget _buildBoletosList(List<Boleto> boletos, String emptyMessage) {
    if (boletos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBoletos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boletos.length,
        itemBuilder: (context, index) {
          final boleto = boletos[index];
          return _buildBoletoCard(boleto);
        },
      ),
    );
  }

  Widget _buildBoletoCard(Boleto boleto) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(boleto.statusColor.replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      boleto.statusPortugues,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    boleto.valueFormatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (boleto.description != null) ...[
                Text(
                  boleto.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Vence em: ${boleto.dueDateFormatted}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (boleto.status == 'PENDING') ...[
                      const SizedBox(width: 8),
                      if (boleto.isOverdue)
                        const Text(
                          'VENCIDO',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else if (boleto.isNearDue)
                        Text(
                          '${boleto.daysToDue} dias',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (boleto.bankSlipUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(boleto.bankSlipUrl!),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Baixar Boleto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (boleto.bankSlipUrl != null && boleto.invoiceUrl != null)
                    const SizedBox(width: 8),
                  if (boleto.invoiceUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(boleto.invoiceUrl!),
                        icon: const Icon(Icons.receipt, size: 16),
                        label: const Text('Ver Fatura'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
              if (boleto.customerName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        boleto.customerName!,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
    );
  }

  void _showBoletoDetails(Boleto boleto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBoletoDetailsModal(boleto),
    );
  }

  Widget _buildBoletoDetailsModal(Boleto boleto) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Detalhes do Boleto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Valor', boleto.valueFormatted),
          _buildDetailRow('Status', boleto.statusPortugues),
          _buildDetailRow('Vencimento', boleto.dueDateFormatted),
          _buildDetailRow('Criado em', boleto.dateCreatedFormatted),
          if (boleto.description != null)
            _buildDetailRow('Descrição', boleto.description!),
          if (boleto.nossoNumero != null)
            _buildDetailRow('Nosso Número', boleto.nossoNumero!),
          const SizedBox(height: 24),
          if (boleto.bankSlipUrl != null || boleto.invoiceUrl != null) ...[
            Row(
              children: [
                if (boleto.bankSlipUrl != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(boleto.bankSlipUrl!),
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar Boleto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (boleto.bankSlipUrl != null && boleto.invoiceUrl != null)
                  const SizedBox(width: 12),
                if (boleto.invoiceUrl != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(boleto.invoiceUrl!),
                      icon: const Icon(Icons.receipt),
                      label: const Text('Ver Fatura'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}