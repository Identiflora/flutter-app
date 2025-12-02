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
       alignment: Alignment.bottomRight,
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


/* CODE FOR LEADERBOARD SCREEN/ROUTE*/
class LeaderboardScreen extends StatefulWidget {
 const LeaderboardScreen({super.key});

 @override
 State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
 bool isLoginView = true; // true for Login, false for Sign Up

 @override
 Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ), //END APPBAR
      
      body: FutureBuilder<List<LeaderboardUser>>(
        future: addAllUsers(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator(color: Color.fromRGBO(145, 187, 32, 1)));
          }
          else if(snapshot.hasData && snapshot.data != null) {
            final leaderboard = snapshot.data;

            if (leaderboard!.isEmpty){
              return const Center(child: Text("No current accounts"),);
            }

            return ListView.builder(
              itemCount: leaderboard.length,
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
          else {
            return Text("No current accounts in database");
          }
        }
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

Future<List<LeaderboardUser>> addAllUsers() async {
  final List<LeaderboardUser> users = [];

  String userName = "";
  int userID = 2;
  do {
    userName = await fetchUsername(userID: userID);
    LeaderboardUser tempUser = LeaderboardUser(userName: userName, userId: userID, userScore: 0);
    debugPrint(userName);
    
    if (userName != ""){
      users.insert(userID - 2, tempUser); //ADDS USERS TO LIST
    }

    userID ++;
  } while (userName != "");

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