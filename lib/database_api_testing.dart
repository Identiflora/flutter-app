import 'dart:convert';
import 'dart:io';
import 'database_utils.dart';

//parameters for incorrect_identification
int identificationId = 4;
int correctSpeciesId = 2;
int incorrectSpeciesId = 3;
// String api_url =

Future<void> main(List<String> arguments) async {
  submitIncorrectIdentification(
    identificationId: identificationId,
    correctSpeciesId: correctSpeciesId,
    incorrectSpeciesId: incorrectSpeciesId,
  );
}
