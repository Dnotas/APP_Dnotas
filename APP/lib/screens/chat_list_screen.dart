import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'chat_conversation_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      
      if (cnpj != null) {
        final response = await ApiService.getClientConversations(cnpj);
        setState(() {
          _conversations = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar conversas: $e');
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  List<dynamic> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    
    return _conversations.where((conv) {
      return conv['titulo'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             conv['ultima_mensagem'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'aberto':
        return 'Aberto';
      case 'em_atendimento':
        return 'Em atendimento';
      case 'aguardando_cliente':
        return 'Aguardando';
      case 'finalizado':
        return 'Finalizado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aberto':
        return Colors.green;
      case 'em_atendimento':
        return Colors.blue;
      case 'aguardando_cliente':
        return Colors.orange;
      case 'finalizado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgente':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'baixa':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suporte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshConversations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar conversas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de conversas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refreshConversations,
                        child: ListView.builder(
                          itemCount: _filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _filteredConversations[index];
                            return _buildConversationTile(conversation);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewChatScreen(),
            ),
          );
          
          if (result == true) {
            _refreshConversations();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma conversa ainda',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para iniciar uma conversa',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final hasUnread = (conversation['mensagens_nao_lidas'] ?? 0) > 0;
    final priority = conversation['prioridade'] ?? 'normal';
    final status = conversation['status'] ?? 'aberto';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey.shade900,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getPriorityColor(priority),
              child: Text(
                (conversation['titulo'] ?? 'C').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      conversation['mensagens_nao_lidas'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation['titulo'] ?? 'Conversa',
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (conversation['atendente_nome'] != null)
              Text(
                'Atendente: ${conversation['atendente_nome']}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              conversation['ultima_mensagem'] ?? 'Nenhuma mensagem',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(conversation['ultima_mensagem_em'] ?? conversation['created_at']),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            if (priority != 'normal') ...[
              const SizedBox(height: 4),
              Icon(
                priority == 'urgente' ? Icons.warning : Icons.priority_high,
                color: _getPriorityColor(priority),
                size: 16,
              ),
            ],
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(
                conversationId: conversation['id'],
                title: conversation['titulo'],
                status: status,
              ),
            ),
          );
          
          if (result == true) {
            _refreshConversations();
          }
        },
      ),
    );
  }
}