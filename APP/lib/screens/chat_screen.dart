import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      if (cnpj != null && token != null) {
        final messages = await ApiService.getChatMessages(cnpj, token);
        setState(() {
          _messages = messages.map((m) => MessageModel.fromJson(m)).toList();
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        // Fallback com mensagens de exemplo para apresentação
        setState(() {
          _messages = [
            MessageModel.fromJson({
              'id': '1',
              'content': 'Olá! Como podemos ajudá-lo hoje?',
              'sender_id': 'support',
              'sender_name': 'Suporte DNOTAS',
              'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
              'is_from_client': false,
            }),
          ];
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Fallback com mensagens de exemplo para apresentação
      setState(() {
        _messages = [
          MessageModel.fromJson({
            'id': '1',
            'content': 'Olá! Como podemos ajudá-lo hoje?',
            'sender_id': 'support',
            'sender_name': 'Suporte DNOTAS',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'is_from_client': false,
          }),
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
      // Adicionar mensagem localmente
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageText,
        senderId: 'client',
        senderName: 'Você',
        timestamp: DateTime.now(),
        isFromClient: true,
      ));
    });

    _scrollToBottom();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;
      
      if (cnpj != null && token != null) {
        await ApiService.sendChatMessage(cnpj, messageText, token);
        
        // Simular resposta automática após 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _simulateIncomingMessage();
          }
        });
      }
    } catch (e) {
      // Em caso de erro, mostrar erro mas manter mensagem
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _simulateIncomingMessage() {
    final responses = [
      'Obrigado pela sua mensagem! Vou verificar isso para você.',
      'Entendi. Vou enviar as informações em alguns minutos.',
      'Perfeito! Já estou preparando os documentos solicitados.',
      'Recebido! Nossa equipe está analisando seu pedido.',
    ];
    
    final randomResponse = responses[DateTime.now().millisecond % responses.length];
    
    setState(() {
      _messages.add(MessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: randomResponse,
        senderId: 'support',
        senderName: 'Suporte DNOTAS',
        timestamp: DateTime.now(),
        isFromClient: false,
      ));
    });
    
    _scrollToBottom();
    
    // Enviar notificação (só se o app estiver em background)
    NotificationService.showNewMessageNotification(
      senderName: 'Suporte DNOTAS',
      message: randomResponse,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade700,
              child: const Icon(Icons.business, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suporte DNOTAS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Contabilidade • Online',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: Implementar ligação
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implementar videochamada
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implementar ações do menu
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Text('Informações do chat'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Limpar conversa'),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Área de mensagens
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
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
                              'Comece uma conversa',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envie uma mensagem para nossa equipe',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          
          // Campo de input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(color: Colors.grey.shade800),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // TODO: Implementar anexo
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isFromClient = message.isFromClient;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromClient 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromClient) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade700,
              child: const Icon(Icons.business, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromClient 
                    ? Colors.blue 
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isFromClient 
                      ? const Radius.circular(20) 
                      : const Radius.circular(4),
                  bottomRight: isFromClient 
                      ? const Radius.circular(4) 
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromClient)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isFromClient 
                          ? Colors.blue.shade100 
                          : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromClient) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}