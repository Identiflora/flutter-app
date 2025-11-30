import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

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
      
      body: Builder(
        builder: (context){
          final leaderboard =LeaderBoardControl.users;
          if (leaderboard.isEmpty){
            return const Center( child: Text("No current accounts"),)
            ;
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
class LeaderBoardControl{
  static final Random _rng = Random(); //CREATES RANDOM LEADERBOARD INDEX FOR USER ACCOUNT
  static final List<LeaderboardUser> users = [];

  static void addUser(LeaderboardUser user){
    final index = _rng.nextInt(users.length +1); //RANGE IS USERS +1
    users.insert(index, user); //ADDS USERS TO LIST
  }

}  //END LEADERBOARDUSER CLASS