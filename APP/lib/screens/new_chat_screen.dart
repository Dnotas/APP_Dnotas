import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'normal';
  String _selectedCategory = 'geral';
  bool _isCreating = false;

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'baixa', 'label': 'Baixa', 'color': Colors.grey},
    {'value': 'normal', 'label': 'Normal', 'color': Colors.blue},
    {'value': 'alta', 'label': 'Alta', 'color': Colors.orange},
    {'value': 'urgente', 'label': 'Urgente', 'color': Colors.red},
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'geral', 'label': 'Dúvida Geral'},
    {'value': 'nfe', 'label': 'Nota Fiscal (NF-e)'},
    {'value': 'nfce', 'label': 'Cupom Fiscal (NFC-e)'},
    {'value': 'boletos', 'label': 'Boletos e Pagamentos'},
    {'value': 'relatorios', 'label': 'Relatórios'},
    {'value': 'tecnico', 'label': 'Problema Técnico'},
    {'value': 'financeiro', 'label': 'Questão Financeira'},
    {'value': 'documentos', 'label': 'Envio de Documentos'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      
      if (cnpj == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await ApiService.createConversation(
        cnpj: cnpj,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversa iniciada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['error'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conversa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _updateTitleFromCategory() {
    final category = _categories.firstWhere((cat) => cat['value'] == _selectedCategory);
    if (_titleController.text.isEmpty) {
      _titleController.text = category['label']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Conversa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createConversation,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'CRIAR',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Categoria
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Categoria do Atendimento',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                      ),
                      dropdownColor: Colors.grey.shade800,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category['value'],
                          child: Text(
                            category['label']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          _updateTitleFromCategory();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.title, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Título da Conversa',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Dúvida sobre emissão de NF-e',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um título';
                        }
                        if (value.trim().length < 5) {
                          return 'Título deve ter pelo menos 5 caracteres';
                        }
                        return null;
                      },
                      maxLength: 100,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Descrição
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Descrição do Problema',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Descreva detalhadamente sua dúvida ou problema...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                      ),
                      maxLines: 4,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, descreva seu problema';
                        }
                        if (value.trim().length < 10) {
                          return 'Descrição deve ter pelo menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prioridade
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.priority_high, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Prioridade',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _priorities.map((priority) {
                        return RadioListTile<String>(
                          value: priority['value'],
                          groupValue: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                          title: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: priority['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                priority['label'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          activeColor: priority['color'],
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Informações adicionais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade300),
                      const SizedBox(width: 8),
                      Text(
                        'Dicas para um atendimento mais rápido',
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Seja específico na descrição do problema\n'
                    '• Mencione números de documentos se aplicável\n'
                    '• Inclua códigos de erro quando houver\n'
                    '• Use prioridade "Urgente" apenas em casos críticos',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}