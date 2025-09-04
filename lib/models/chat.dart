import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 0)
class Chat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final DateTime timestamp;

  Chat({required this.id, required this.name, required this.message, required this.timestamp});
}
