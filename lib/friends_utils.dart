import 'package:flutter/material.dart';
import 'dart:math';
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
                  MaterialPageRoute(builder: (context) => const FriendsHomescreenButton()),
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

//screen you navigate to. Returns scaffold ()
//class FriendsScreen extends StatelessWidget {
//  const FriendsScreen({super.key});
  //return 
//}

//HOMESCREEN BUTTON