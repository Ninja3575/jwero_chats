import 'package:hive/hive.dart';
import 'package:faker/faker.dart';
import '../models/chat.dart';

class ChatRepository {
  static const String boxName = 'chats';

  Future<void> addChat(Chat chat) async {
    final box = await Hive.openBox<Chat>(boxName);
    await box.put(chat.id, chat);
  }

  Future<List<Chat>> getChats() async {
    final box = await Hive.openBox<Chat>(boxName);
    return box.values.toList();
  }

  Future<Chat> addQuickChat() async {
    final faker = Faker();
    final chat = Chat(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: faker.person.name(),
      message: faker.lorem.sentence(),
      timestamp: DateTime.now(),
    );
    await addChat(chat);
    return chat;
  }

  Future<void> seedMockChats({int count = 25}) async {
    final faker = Faker();
    final box = await Hive.openBox<Chat>(boxName);
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final chat = Chat(
        id: '${now.microsecondsSinceEpoch}-$i',
        name: faker.person.name(),
        message: faker.lorem.sentence(),
        timestamp: now.subtract(Duration(minutes: i * 3)),
      );
      await box.put(chat.id, chat);
    }
  }
}
