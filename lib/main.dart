import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/chat.dart';
import 'repositories/chat_repository.dart';
import 'screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatAdapter());
  await Hive.openBox<Chat>(ChatRepository.boxName);
  final box = Hive.box<Chat>(ChatRepository.boxName);
  if (box.isEmpty) {
    // Seed a few chats so the list isn't empty on first run
    await ChatRepository().seedMockChats(count: 10);
  }
  runApp(const ProviderScope(child: JweroChatsApp()));
}

class JweroChatsApp extends StatelessWidget {
  const JweroChatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jwero Chats',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatListScreen(),
    );
  }
}
