class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isFromClient;
  final String? attachmentUrl;
  final String? attachmentType;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isFromClient,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isFromClient: json['is_from_client'] ?? false,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'timestamp': timestamp.toIso8601String(),
      'is_from_client': isFromClient,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }
}