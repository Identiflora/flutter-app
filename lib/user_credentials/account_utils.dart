import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_credentials/login.dart';
import 'package:identiflora/user_data/offline_utils.dart';
import 'package:identiflora/view_account/view_account_utils.dart';
import 'auth_objects.dart';
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
  Future<bool> authenticate() async {
    bool success = false;
    try {
      success = await ConnService().getIsOffline;
      if(success) {
        return success;
      }

      success = await authenticateToken();
      return success;
    }
    catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () async {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingScreen<bool>.withNav(
                      loadingMsg: "Loading account information...",
                      foundMsg: "Account found! One moment...",
                      errorMsg: "Unable to find account information. Returning...",
                      futureFunction: authenticate(),
                      postLoadingBuilder: (context, success) {
                        if (success == null || !success) {
                          return const LoginScreen();
                        }
                        return ViewAccountScreen();
                      },
                      navigateOnError: true,
                    ),
                  ),
                );
              } on RateLimitException catch (e) {
                if (context.mounted) {
                  errorPopupMessage(context, e.message, null);
                }
              } catch (error) {
                errorPopupMessage(context, "$error", null);
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