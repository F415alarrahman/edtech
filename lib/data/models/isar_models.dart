import 'package:isar/isar.dart';
part 'isar_models.g.dart';

@collection
class CachedUser {
  Id id = Isar.autoIncrement;
  late String uid;
  String? name;
  String? avatarUrl;
  String? role;
}

@collection
class CachedMessage {
  Id id = Isar.autoIncrement;
  late String msgId;
  late String roomId;
  late String authorId;
  late String text;
  late DateTime createdAt;
  late String type; // "text" | "action"
}
