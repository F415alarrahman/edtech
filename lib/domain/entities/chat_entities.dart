class RoomEntity {
  final String id;
  final String type;
  final List<String> members;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final String? lastMessageText;

  RoomEntity({
    required this.id,
    required this.type,
    required this.members,
    this.lastMessageAt,
    this.lastMessageBy,
    this.lastMessageText,
  });
}

class MessageEntity {
  final String id;
  final String roomId;
  final String authorId;
  final String text;
  final DateTime createdAt;
  final String type;
  final Map<String, DateTime> deliveredTo;
  final Map<String, DateTime> readBy;

  MessageEntity({
    required this.id,
    required this.roomId,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.type,
    this.deliveredTo = const {},
    this.readBy = const {},
  });
}
