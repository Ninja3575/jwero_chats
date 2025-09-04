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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final value = _searchController.text.trim();
      if (value != _searchQuery) {
        setState(() => _searchQuery = value);
      }
    });
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jwero Chats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Open'),
              Tab(text: 'Unread'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
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
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildChatList(chats),
                            _buildChatList(chats),
                            _buildChatList(chats),
                          ],
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Activities'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (_) {},
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _repo.addQuickChat();
            _loadChats();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildChatList(List<Chat> data) {
    final List<Chat> filtered = _searchQuery.isEmpty
        ? data
        : data
            .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.message.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
    if (filtered.isEmpty) {
      return Center(
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
      );
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = filtered[index];
        final time = _formatTime(chat.timestamp);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?'),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chat.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(time, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  chat.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.green),
            ],
          ),
          onTap: () {},
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $ampm';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
