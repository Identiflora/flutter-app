import 'package:flutter/material.dart';
import 'dart:math';

import 'package:identiflora/database_utils.dart';

/* 
PUT THIS INFO INTO ISSUE:
-------------------------------------------------------------------
LEADERBOARD WIDGET IS SOLELY FOR THE BUTTON ON THE "HOME" SCREEN
https://docs.flutter.dev/get-started/fundamentals/widgets

LEADERBOARDSCREEN IS RESP FOR THE THE SCREEN USER CLICKS INTO
https://docs.flutter.dev/ui/navigation

https://api.flutter.dev/flutter/dart-math/Random-class.html
*/

//CODE FOR HOMEPAGE BUTTON
class LeaderboardWidget extends StatefulWidget {
 const LeaderboardWidget({super.key});

 @override
 State<LeaderboardWidget> createState() =>_Leaderboard();
}

class _Leaderboard extends State<LeaderboardWidget>{
 @override
Widget build(BuildContext context) {
   return SafeArea(
     child: Align(
       alignment: Alignment.topLeft,
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal:16),
         child: GestureDetector(onTap: () {
           Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => const LeaderboardScreen(),
               ),
           );
         },
         child: Image.asset('assets/homepage/leaderboard_icon.png', width: 80, height: 80))
       )
     ),
   );
 }
}

List<PopupMenuEntry<String>> getPopupOptions(String? leaderboardType) {
  switch(leaderboardType) {
    case "Global": return <PopupMenuEntry<String>> [
            const PopupMenuItem(value: "Friends", child: Text("Friends")),
            const PopupMenuItem(value: "Regional", child: Text("Regional"))
          ];
    case "Friends": return <PopupMenuEntry<String>> [
            const PopupMenuItem(value: "Friends", child: Text("Friends")),
            const PopupMenuItem(value: "Regional", child: Text("Regional"))
          ];
    default: return <PopupMenuEntry<String>> [
            const PopupMenuItem(value: "Global", child: Text("Global")),
            const PopupMenuItem(value: "Friends", child: Text("Friends"))
          ];
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

 @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("$leaderboardType Leaderboard"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      elevation: 5.0,
      shadowColor: Theme.of(context).colorScheme.shadow,
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => getPopupOptions(leaderboardType),
          onSelected: (String value) {
            setState(() {
              leaderboardType = value;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                content: Text("Now Displaying $value Leaderboard", style: const TextStyle(color: Colors.black))
              )
            );
          },
        )
      ],
    ), //END APPBAR
    
    body: Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
      child: FutureBuilder<List<LeaderboardUser>> (
        future: addUsers(leaderboardType, 100),
        builder: (context, snapshot){
          String? lowercaseLeaderboardType = leaderboardType?.toLowerCase();
      
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          else if(snapshot.hasData && snapshot.data != null) {
            final leaderboard = snapshot.data;
      
            if (leaderboard!.isEmpty){
              return Center(child: Text("No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.", textAlign: TextAlign.center));
            }
      
            return ListView.separated(
              itemCount: leaderboard.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (context, index){
                final user = leaderboard[index];
      
                return ListTile(
                  leading: Text("#${index +1}"),
                  title: Text(user.userName),
                  trailing: Text("${user.userScore} pts"),
                );
              },
            );
          }
          else if(snapshot.hasError){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error while loading leaaderboard: ${snapshot.error}"),
                  backgroundColor: Colors.red,
                ),
              );
            });
            return Center(child: Text("No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.", textAlign: TextAlign.center));
          }
          else {
            return Center(child: Text("No $lowercaseLeaderboardType accounts found in database.\nPlease check that you are logged in and connected to the internet.", textAlign: TextAlign.center));
          }
        }
      ),
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

Future<List<LeaderboardUser>> addUsers(String? leaderboardType, int maxUsers) async {
  final List<LeaderboardUser> users;

  // LOAD ALL USERS WITH SCORES
  if(leaderboardType == "Global") {
    users = await submitGlobalLeaderboardRequest(leaderboardSize: maxUsers);
  }
  else {
    users = List.empty();
  }

  return users;
}

// CLASS THAT CREATES USERS RANDOM INDEX, AND ADDS THEM TO LEADERBOARD LIST
class LeaderBoardControl{
  static final Random _rng = Random(); //CREATES RANDOM LEADERBOARD INDEX FOR USER ACCOUNT
  static final List<LeaderboardUser> users = [];
  int databaseLastIndex = 0;

 static void addUser(LeaderboardUser user){
    final index = _rng.nextInt(users.length +1); //RANGE IS USERS +1
    users.insert(index, user); //ADDS USERS TO LIST
  }

}  //END LEADERBOARDUSER CLASS