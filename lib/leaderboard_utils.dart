import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_data/user_data_service.dart';
import 'package:identiflora/view_account/view_alternate_account_screen.dart';
import 'package:identiflora/widgets/leaderboard_widgets.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/theme/neon_theme.dart';

class LeaderboardUser {
  final String userName;
  String? displayedBadgeFilePath;
  final int userId;
  int userScore;
  final int numFriends;

  LeaderboardUser({
    required this.userName,
    this.userScore = 0,
    this.displayedBadgeFilePath,
    this.userId = 0,
    this.numFriends = 0,
  });

  set setDisplayedBadgeFilePath(String badgeFilePath) {
    displayedBadgeFilePath = badgeFilePath;
  }

  String? get getUnlockAtLevel {
    return displayedBadgeFilePath;
  }
}

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
            child: Icon(
              Icons.leaderboard_outlined,
              size: 80.0,
              color: Theme.of(context).colorScheme.surface,
              shadows: Theme.of(context).extension<NeonTheme>()?.homeIconShadow,
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
  String region = "";
  late Future<List<LeaderboardUser>> _futureUsers;
  final int maxUsers = 99;

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

    if (leaderboardType == "Global") {
      users = await submitGlobalLeaderboardRequest(leaderboardSize: maxUsers);
    } else if (leaderboardType == "Friends") {
      // Grab current user's friends in a sorted list
      users = await submitFriendsLeaderboardRequest(leaderboardSize: maxUsers);

      // Construct current user
      final userData = UserDataService();
      final LeaderboardUser currentUser = LeaderboardUser(
        userName: userData.username, 
        userScore: userData.points, 
        displayedBadgeFilePath: userData.badgePath
      );

      // Add current user to friends list
      users.add(currentUser);
      users.sort((a, b) => -a.userScore.compareTo(b.userScore));
    } else if (leaderboardType == "Regional") {
      users = await submitRegionalLeaderboardRequest(leaderboardSize: maxUsers);
    } else {
      users = List.empty();
    }

    return users;
  }

  /// Get color for rank of user on leaderboard
  Color getRankColor(int userIndex) {
    Color rankColor;

    switch (userIndex) {
      case 1:
        rankColor = Color.fromARGB(255, 255, 215, 0);
        break;
      case 2:
        rankColor = Color.fromARGB(255, 192, 192, 192);
        break;
      case 3:
        rankColor = Color.fromARGB(255, 205, 127, 50);
        break;
      default:
        rankColor = Theme.of(context).colorScheme.primaryContainer;
        break;
    }

    return rankColor;
  }

  /// Gets user's region or throws error
  Future<String> _getUserRegion() async {
    try {
      return await getUserRegion();
    } on SocketException {
      errorPopupMessage(
        context, 
        "Error connecting to the internet. Please check your network connection.",
        Duration(seconds: 5)
      );
      return "";
    } on HttpException {
      errorPopupMessage(
        context,
        "Error in API communication. Please wait a moment and try again. API may take a moment to wake up.",
        Duration(seconds: 5),
      );
      return "";
    } catch (error) {
      errorPopupMessage(
        context, 
        "Error while loading leaderboard region: $error",
        Duration(seconds: 8)
      );
      return "";
    }
  }

  Widget getLeaderboardErrorMessage(String? lowercaseLeaderboardType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No $lowercaseLeaderboardType accounts found.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const Text(
          "Please check that you are logged in and connected to the internet.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() {
            _futureUsers = addUsers(leaderboardType, maxUsers);
            if (leaderboardType == "Regional") {
              _getUserRegion().then((response) {
                setState(() {
                  region = response;
                });
              });
            }
          }),
          child: Text(
            "RETRY",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _futureUsers = addUsers(leaderboardType, maxUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$leaderboardType Leaderboard"),
        actions: [
          PopupMenuButton<String>(
            iconColor: Theme.of(context).colorScheme.secondary,
            itemBuilder: (BuildContext context) =>
                getPopupOptions(leaderboardType),
            onSelected: (String value) {
              setState(() {
                leaderboardType = value;
                _futureUsers = addUsers(leaderboardType, maxUsers);
              });

              if (leaderboardType == "Regional") {
                _getUserRegion().then((response) {
                  setState(() {
                    region = response;
                  });
                });
              }
            },
          ),
        ],
      ),

      // Main leaderboard functionality
      body: FutureBuilder<List<LeaderboardUser>>(
        future: _futureUsers,
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
              return getLeaderboardErrorMessage(lowercaseLeaderboardType);
            }

            double screenWidth = MediaQuery.of(context).size.width;

            return SafeArea(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: leaderboard.length + 1,
                  itemBuilder: (context, index) {
                    // Return header if index is 0
                    if (index == 0) {
                      return LeaderboardHeaderDisplay(
                        leaderboardType: leaderboardType,
                        userRegion: region,
                      );
                    }

                    // Gain user information and dynamic color
                    final LeaderboardUser user = leaderboard[index - 1];
                    final Color rankColor = getRankColor(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      child: NeonContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  LeaderboardUserRankDisplay(
                                    screenWidth: screenWidth,
                                    userIndex: index,
                                    rankColor: rankColor,
                                  ),
                                  const SizedBox(width: 8.0),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewAlternateAccountScreen(
                                                username: user.userName,
                                                points: user.userScore,
                                                numFriends: user.numFriends,
                                                displayedBadgeFilePath:
                                                    user.displayedBadgeFilePath ??
                                                    'assets/brand/Identiflora_logo.png',
                                              ),
                                        ),
                                      );
                                    },
                                    child: LeaderboardUserDisplay(
                                      screenWidth: screenWidth,
                                      badgeFilePath:
                                          user.displayedBadgeFilePath,
                                      username: user.userName,
                                    ),
                                  ),
                                ],
                              ),
                              LeaderboardUserPointDisplay(
                                screenWidth: screenWidth,
                                userIndex: index,
                                userPoints: user.userScore,
                                rankColor: rankColor,
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
              if (snapshot.error.toString().contains("Network error") && leaderboardType != "Regional") {
                errorPopupMessage(
                  context,
                  "Error connecting to the internet. Please check your network connection.",
                  Duration(seconds: 5),
                );
              }
              else if (snapshot.error is HttpException) {
                errorPopupMessage(
                  context,
                  "Error in API communication. Please wait a moment and try again. API may take a moment to wake up.",
                  Duration(seconds: 5),
                );
              }
              else if (leaderboardType != "Regional") {
                errorPopupMessage(
                  context,
                  "Error while loading leaderboard: ${snapshot.error}, ${snapshot.error.runtimeType}",
                  Duration(seconds: 8),
                );
              }
            });
            return getLeaderboardErrorMessage(lowercaseLeaderboardType);
          } else {
            return getLeaderboardErrorMessage(lowercaseLeaderboardType);
          }
        },
      ),
    );

    //END SCAFFOLD
  }
} //END LEADERBOARDSCREEN STATE CLASS

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