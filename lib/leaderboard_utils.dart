import 'package:flutter/material.dart';
import 'dart:math';

import 'package:identiflora/database_utils.dart';

//CODE FOR HOMEPAGE BUTTON
class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  State<LeaderboardWidget> createState() => _Leaderboard();
}

class _Leaderboard extends State<LeaderboardWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
            child: Image.asset(
              'assets/homepage/leaderboard_icon.png',
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}

/* CODE FOR LEADERBOARD SCREEN/ROUTE*/
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String? leaderboardType = "Global";

  /// Gets popup options based on current leaderboard type to insure a dynamic popup view when switching types.
  List<PopupMenuEntry<String>> getPopupOptions(String? leaderboardType) {
    switch (leaderboardType) {
      case "Global":
        return <PopupMenuEntry<String>>[
          const PopupMenuItem(value: "Friends", child: Text("Friends")),
          const PopupMenuItem(value: "Regional", child: Text("Regional")),
        ];
      case "Friends":
        return <PopupMenuEntry<String>>[
          const PopupMenuItem(value: "Global", child: Text("Global")),
          const PopupMenuItem(value: "Regional", child: Text("Regional")),
        ];
      default:
        return <PopupMenuEntry<String>>[
          const PopupMenuItem(value: "Global", child: Text("Global")),
          const PopupMenuItem(value: "Friends", child: Text("Friends")),
        ];
    }
  }

  /// Add all users of the current leaderboard type to allow for dynamic database submissions
  Future<List<LeaderboardUser>> addUsers(
    String? leaderboardType,
    int maxUsers,
  ) async {
    final List<LeaderboardUser> users;

    // LOAD ALL USERS WITH SCORES
    if (leaderboardType == "Global") {
      users = await submitGlobalLeaderboardRequest(leaderboardSize: maxUsers);
    } else {
      users = List.empty();
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$leaderboardType Leaderboard"),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) =>
                getPopupOptions(leaderboardType),
            onSelected: (String value) {
              setState(() {
                leaderboardType = value;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  content: Text(
                    "Now Displaying $value Leaderboard",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ],
      ), //END APPBAR

      body: FutureBuilder<List<LeaderboardUser>>(
        future: addUsers(leaderboardType, 100),
        builder: (context, snapshot) {
          String? lowercaseLeaderboardType = leaderboardType?.toLowerCase();
      
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final leaderboard = snapshot.data;
      
            if (leaderboard!.isEmpty) {
              return Center(
                child: Text(
                  "No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.",
                  textAlign: TextAlign.center,
                ),
              );
            }

            double screenWidth = MediaQuery.of(context).size.width;
      
            return SafeArea(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: leaderboard.length + 1,
                  itemBuilder: (context, index) {
                    // Return header if index is 0
                    if(index == 0) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Rank", style: TextStyle(fontSize: 20.0)),
                                    const SizedBox(width: 16.0),
                                    Text("User", style: TextStyle(fontSize: 20.0)),
                                    const SizedBox(width: 16.0),
                                    Text("Points", style: TextStyle(fontSize: 20.0)),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Divider(
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    
                    final user = leaderboard[index - 1];
                
                    Color? rankColor = Theme.of(context).colorScheme.surface;
                                
                    switch(index) {
                      case 1:
                        rankColor = Color.fromARGB(255, 255, 217, 0);
                        break;
                      case 2:
                        rankColor = Color.fromARGB(255, 192, 192, 192);
                        break;
                      case 3:
                        rankColor = Color.fromARGB(255, 205, 127, 50);
                        break;
                      default:
                        rankColor = Theme.of(context).colorScheme.surface;
                        break;
                    }
                
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.outer,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.2
                                    ),
                                    child: Row(
                                      children: [
                                        index <= 3 ?
                                          Icon(Icons.emoji_events, color: rankColor, size: 30, shadows: [Shadow(blurRadius: 1.0)]) 
                                          : Icon(null, size: 30,),
                                        index < 10 ? const SizedBox(width: 16.0) : const SizedBox(width: 6.0),
                                        Text(
                                          "#$index", 
                                          style: TextStyle(fontSize: 14.0),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  SizedBox(
                                    width: screenWidth * 0.45,
                                    child: Row(
                                      children: [
                                        // THIS NEEDS CHANGED FOR DYNAMICALLY CHANGING BADGE/PFP
                                        CircleAvatar(
                                          foregroundImage: const AssetImage('assets/brand/Identiflora_logo.png'), 
                                          backgroundColor: Theme.of(context).colorScheme.surface, 
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 14.0),
                                        Flexible(
                                          child: Text(
                                            user.userName,
                                            style: TextStyle(fontSize: 14.0),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.3
                                ),
                                decoration: BoxDecoration(
                                  color: index <= 3 ? rankColor.withAlpha(125) : Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.all(Radius.elliptical(15, 15))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${user.userScore} pts.", 
                                    style: TextStyle(fontSize: 12.0), 
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Error while loading leaaderboard: ${snapshot.error}",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            });
            return Center(
              child: Text(
                "No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.",
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return Center(
              child: Text(
                "No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.",
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );

    //END SCAFFOLD
  }
} //END LEADERBOARDSCREEN STATE CLASS

class LeaderboardUser {
  final String userName;
  final int userId;
  int userScore;

  //CONSTRUCTOR
  LeaderboardUser({
    required this.userName,
    this.userScore = 0,
    this.userId = 0,
  });
} //END LEADERBOARDUSER CLASS

// CLASS THAT CREATES USERS RANDOM INDEX, AND ADDS THEM TO LEADERBOARD LIST
class LeaderBoardControl {
  static final Random _rng =
      Random(); //CREATES RANDOM LEADERBOARD INDEX FOR USER ACCOUNT
  static final List<LeaderboardUser> users = [];
  int databaseLastIndex = 0;

  static void addUser(LeaderboardUser user) {
    final index = _rng.nextInt(users.length + 1); //RANGE IS USERS +1
    users.insert(index, user); //ADDS USERS TO LIST
  }
}  //END LEADERBOARDUSER CLASS