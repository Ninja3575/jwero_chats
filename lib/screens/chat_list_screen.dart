import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import '../models/chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatRepository _repo = ChatRepository();
  List<Chat> chats = [];
  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final data = await _repo.getChats();
      setState(() {
        chats = data;
        isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load chats: $e');
      setState(() {
        loadError = '$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jwero Chats'),
        actions: [
          IconButton(
            tooltip: 'Seed',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _repo.seedMockChats(count: 5);
              _loadChats();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(child: Text('Error: $loadError'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'state: loading=$isLoading, error=${loadError ?? "none"}, count=${chats.length}',
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: chats.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('No chats yet'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _repo.seedMockChats(count: 15);
                                      _loadChats();
                                    },
                                    child: const Text('Generate sample chats'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                final chat = chats[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.image_outlined),
                                  ),
                                  title: Text(chat.name),
                                  subtitle: Text(chat.message),
                                  trailing: Text(chat.timestamp.toIso8601String()),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: () async {
            await _repo.seedMockChats(count: 15);
            _loadChats();
          },
          icon: const Icon(Icons.bolt),
          label: const Text('Seed chats'),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _repo.addQuickChat();
          _loadChats();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
