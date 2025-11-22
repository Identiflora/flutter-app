import 'package:flutter/material.dart';

class ResultsWidget extends StatefulWidget {
  final String modelChoice;
  final String userChoice;
  const ResultsWidget({super.key, 
    required this.modelChoice, 
    required this.userChoice});

  @override
  State<ResultsWidget> createState() =>_Results();
}

class _Results extends State<ResultsWidget>{
  bool get choicesMatch => widget.modelChoice == widget.userChoice;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Results are in...'),
      ),
    );
  }
}