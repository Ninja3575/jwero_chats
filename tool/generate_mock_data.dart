import 'dart:math';
import 'package:hive/hive.dart';
import '../lib/models/chat.dart';

Future<void> main() async {
  Hive.init('hive_data');
  Hive.registerAdapter(ChatAdapter());
  final box = await Hive.openBox<Chat>('chats');

  final rand = Random();
  for (int i = 0; i < 1000000; i++) {
    final chat = Chat(
      id: i.toString(),
      name: 'User $i',
      message: 'Message number $i',
      timestamp: DateTime.now().subtract(Duration(minutes: rand.nextInt(100000))),
    );
    await box.put(chat.id, chat);
  }
  print("1,000,000 mock chats generated!");
}
