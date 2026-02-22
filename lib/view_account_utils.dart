import 'package:flutter/material.dart';

class ViewAccountScreen extends StatefulWidget {
  const ViewAccountScreen({super.key});

  @override
  State<ViewAccountScreen> createState() => _ViewAccountScreenState();
}

class _ViewAccountScreenState extends State<ViewAccountScreen> {
  int playerLevel = 1; //placeholder
  int playerPoints = 5; //placeholder obviously
  double normalizedPlayerPoints = 0.0;

  String username =
      "John Smith"; // need to implement retrieving username in initState

  int numFriends = 15;//need to calculate number of friends in initState

  double normalize(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    normalizedPlayerPoints = normalize(
      playerPoints.toDouble(),
      0,
      10,
    ); //need to change the 10.0 to whatever max points will be
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 45.0,
            onPressed: () {
              //take you to marks settings page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  //begin avatar
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary, //eventually make this a profile picture or let them choose color
                    foregroundImage: const AssetImage('assets/brand/Identiflora_logo.png'),
                    radius: 50.0, // changes the size of profile picture display
                  ),
                  //begin progress indicator
                  SizedBox(
                    width: 140.0,
                    height: 140.0,
                    // Tween animates progress bar filling up
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: normalizedPlayerPoints,
                      ),
                      duration: const Duration(seconds: 3), //speed of animation
                      builder: (context, animatedValue, child) {
                        //This is the actual progress bar
                        return Transform.flip(
                          flipX: true,
                          child: CircularProgressIndicator(
                            value: animatedValue,
                            semanticsLabel: 'Linear progress indicator',
                            strokeWidth: 18.0,
                            backgroundColor: const Color.fromARGB(
                              121,
                              27,
                              77,
                              29,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),//end of avatar/progress indicator
            Text(username, style: TextStyle(fontSize: 30.0)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 350,
                height: 7,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        playerLevel.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      Text("Level", style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        playerPoints.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      Text("Points", style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Text(
                        numFriends.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      Text("Friends", style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
