import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:identiflora/user_credentials/login.dart';
import 'package:identiflora/view_account/view_account_utils.dart';
import 'package:identiflora/user_data/cache_utils.dart' as cache;
import 'package:identiflora/theme/neon_theme.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _Account();
}

//HASH ACCOUNT PASSWORDS FUNCT
String hashPassword(String password) {
  final bytes = utf8.encode(password); //TURN PASS INTO BYTES
  final digest = sha256.convert(bytes); //APPLY HASHING
  return digest.toString(); //RETURN HASHED STRING
}

String getLoginSuccessMsg() {
  return "Successfully logged in";
}

class _Account extends State<AccountWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () async {
              final token = await cache.getAuthToken();
              if (!context.mounted) return;
              if (token == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAccountScreen()));
              }
            },
            child: Icon(
              Icons.account_circle_outlined,
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