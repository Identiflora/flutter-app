import 'package:flutter/material.dart';
import 'dart:convert';

/* 
PUT THIS INFO INTO ISSUE:
-------------------------------------------------------------------
LEADERBOARD WIDGET IS SOLELY FOR THE BUTTON ON THE "HOME" SCREEN
https://docs.flutter.dev/get-started/fundamentals/widgets

LEADERBOARDSCREEN IS RESP FOR THE THE SCREEN USER CLICKS INTO
https://docs.flutter.dev/ui/navigation
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
       alignment: Alignment.topCenter,
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal:16),
         child: ElevatedButton(onPressed: () {
           Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => const LeaderboardScreen(),
               ),
           );
         },
         child: Text('Leaderboard'))
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
   return Scaffold();
}

} //END LEADERBOARDSCREEN STATE CLASS