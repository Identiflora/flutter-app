import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';

//friends button
class FriendsHomescreenButton extends StatelessWidget {
  const FriendsHomescreenButton({super.key});

  @override
 Widget build(BuildContext context) {

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
    
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendsScreen()),
                );
              }, //end child text button
              child: const Text ("Friends",
              style: TextStyle(fontSize: 18),
              ), //end child text button
            ),
        ),
      ),
    );
  } //end build widget
} // end FriendsHomescreenButton

//screen you navigate to
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}


class _FriendsScreenState extends State<FriendsScreen> {
  late Future<List<FriendUser>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _loadFriends();
  }

  Future<List<FriendUser>> _loadFriends() async {
    final raw = await fetchFriendsRaw(); 
    return raw
        .map((e) => FriendUser.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _friendsFuture = _loadFriends();
    });
    await _friendsFuture;
  }

  Future<void> _addFriendDialog() async {
    final controller = TextEditingController();

    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add friend"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Friend username"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (username == null || username.isEmpty) return;

    try {
      await addFriendRaw(friendUsername: username); // from database_utils.dart
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added $username")),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add friend: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriendDialog,
        child: const Icon(Icons.person_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<FriendUser>>(
          future: _friendsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              final friends = snapshot.data!;
              if (friends.isEmpty) {
                return const Center(
                  child: Text(
                    "No friends yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                itemCount: friends.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final f = friends[index];
                  return ListTile(
                    title: Text(f.username),
                    subtitle: Text("id: ${f.id}"),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading friends:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return const Center(
                child: Text("No friends found."),
              );
            }
          },
        ),
      ),
    );
  }
}



class FriendUser {
  final int id;
  final String username;

  FriendUser({required this.id, required this.username});

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
    );
  }
}
