import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/neon_theme.dart';
import 'package:identiflora/user_data/cache_utils.dart' as cache;
import 'package:identiflora/user_data/user_data_service.dart';

// friends button
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
            },
            child: const Text(
              "Friends",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late Future<FriendsPageData> _pageFuture;

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadPageData();
  }

  Future<FriendsPageData> _loadPageData() async {
    final rawFriends = await fetchFriendsRaw();
    final rawPending = await fetchPendingFriendsRaw();

    final friends = rawFriends
        .map((e) => FriendUser.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    UserDataService().updateNumFriends(friends.length);
    await cache.saveUserNumFriends(friends.length);

    final pending = rawPending
        .map((e) => FriendUser.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    return FriendsPageData(
      friends: friends,
      pendingRequests: pending,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _pageFuture = _loadPageData();
    });
    await _pageFuture;
  }

Future<void> _addFriendDialog() async {
  FriendUser? selectedUser;

  final result = await showDialog<FriendUser>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add friend"),
        content: SizedBox(
          width: 350,
          child: Autocomplete<FriendUser>(
            displayStringForOption: (option) => option.username,
            optionsBuilder: (TextEditingValue textEditingValue) async {
              final query = textEditingValue.text.trim();

              if (query.isEmpty) {
                return const Iterable<FriendUser>.empty();
              }

              try {
                final raw = await searchUsersRaw(query: query);
                return raw
                    .map((e) => FriendUser.fromJson(e))
                    .toList();
              } catch (_) {
                return const Iterable<FriendUser>.empty();
              }
            },
            onSelected: (FriendUser user) {
              selectedUser = user;
            },
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "Friend username",
                  hintText: "Start typing a username",
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              final optionsList = options.toList();

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 350,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (context, index) {
                          final option = optionsList[index];
                          return ListTile(
                            title: Text(option.username),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedUser),
            child: const Text("Add"),
          ),
        ],
      );
    },
  );

  if (result == null) return;

  try {
    await addFriendRaw(friendUsername: result.username);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request sent to ${result.username}")),
    );
    await _refresh();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add friend: $e")),
    );
  }
}

  Future<void> _confirmDeleteFriend(FriendUser friend) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Remove friend"),
        content: Text(
          "Are you sure you would like to remove ${friend.username} as a friend?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await deleteFriendRaw(friendId: friend.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${friend.username} removed")),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete friend: $e")),
      );
    }
  }

  Future<void> _acceptRequest(FriendUser requester) async {
    try {
      await acceptFriendRequestRaw(requesterId: requester.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Accepted ${requester.username}")),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept request: $e")),
      );
    }
  }

  Future<void> _rejectRequest(FriendUser requester) async {
    try {
      await rejectFriendRequestRaw(requesterId: requester.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rejected ${requester.username}")),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject request: $e")),
      );
    }
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: neonTheme?.containerGlow ?? [],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _friendTile(BuildContext context, FriendUser friend) {
    final primary = Theme.of(context).colorScheme.primary;
    final surfaceBright = Theme.of(context).colorScheme.surfaceBright;
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: surfaceBright,
          child: Text(
            friend.username.isNotEmpty ? friend.username[0].toUpperCase() : "?",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("User ID: ${friend.id}"),
        trailing: IconButton(
          tooltip: "Remove friend",
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
          onPressed: () => _confirmDeleteFriend(friend),
        ),
      ),
    );
  }

  Widget _pendingTile(BuildContext context, FriendUser requester) {
    final primary = Theme.of(context).colorScheme.primary;
    final surfaceBright = Theme.of(context).colorScheme.surfaceBright;
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: surfaceBright,
          child: Text(
            requester.username.isNotEmpty
                ? requester.username[0].toUpperCase()
                : "?",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          requester.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("User ID: ${requester.id}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "Accept",
              icon: Icon(Icons.check_circle, color: primary),
              onPressed: () => _acceptRequest(requester),
            ),
            IconButton(
              tooltip: "Reject",
              icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
              onPressed: () => _rejectRequest(requester),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Friends'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _addFriendDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<FriendsPageData>(
          future: _pageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading friends:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            final friends = snapshot.data?.friends ?? [];
            final pending = snapshot.data?.pendingRequests ?? [];

            return ListView(
              children: [
                _sectionHeader(context, "Friends", Icons.group),
                const SizedBox(height: 12),
                if (friends.isEmpty)
                  _emptyCard(context, "No friends yet.")
                else
                  ...friends.map((f) => _friendTile(context, f)),
                const SizedBox(height: 24),
                _sectionHeader(context, "Pending Friends", Icons.hourglass_top),
                const SizedBox(height: 12),
                if (pending.isEmpty)
                  _emptyCard(context, "No pending friend requests.")
                else
                  ...pending.map((r) => _pendingTile(context, r)),
                const SizedBox(height: 90),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FriendsPageData {
  final List<FriendUser> friends;
  final List<FriendUser> pendingRequests;

  FriendsPageData({
    required this.friends,
    required this.pendingRequests,
  });
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
