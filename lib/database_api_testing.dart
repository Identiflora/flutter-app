import 'dart:convert';
import 'dart:io';
import 'database_utils.dart';

//parameters for incorrect_identification
int identificationId = 1;
int correctSpeciesId = 2;
int incorrectSpeciesId = 3;
const apiBaseUrl = 'https://identiflora-api.onrender.com';
const sampleScientificName = 'test_sci_name';

Future<void> main(List<String> arguments) async {
  await _testSubmitIncorrectIdentification();
  await _testGetPlantSpeciesUrl();
}

Future<void> _testSubmitIncorrectIdentification() async {
  try {
    final ok = await submitIncorrectIdentification(
      identificationId: identificationId,
      correctSpeciesId: correctSpeciesId,
      incorrectSpeciesId: incorrectSpeciesId,
      apiBaseUrl: apiBaseUrl,
    );
    stdout.writeln('submitIncorrectIdentification success: $ok');
  } catch (err) {
    stderr.writeln('submitIncorrectIdentification failed: $err');
  }
}

Future<void> _testGetPlantSpeciesUrl() async {
  try {
    final url = await getPlantSpeciesUrl(
      scientificName: sampleScientificName,
      apiBaseUrl: apiBaseUrl,
    );
    stdout.writeln('getPlantSpeciesUrl returned: $url');
  } catch (err) {
    stderr.writeln('getPlantSpeciesUrl failed: $err');
  }
}
