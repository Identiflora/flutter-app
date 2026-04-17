import 'dart:io';

import 'package:flutter/material.dart';

String localPlantAssetPath(String scientificName) {
  final parts = scientificName.trim().split(' ');
  final fileName = '${parts[0]}_${parts[1]}';
  return 'assets/plant_images/identiflora_one_image_per_plant/$fileName.webp';
}

/// Returns an error popup based on error string and optional duration
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(
///     content: Text(
///       errorString,
///     ),
///     backgroundColor: Colors.red,
///   ),
/// );
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorPopupMessage(BuildContext context, String errorString, Duration? duration) {
  if(duration == null) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorString,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
  else {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorString,
        ),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }
}

/// Get the blacklisted chars for inputted strings
List<String> getCharBlacklist() {
  // Note: Some chars require '\' before due to being part of variable insertions or string literal manipulation
  // Ex: '\$' and '\\' due to '$variableName' and things like '\n'
  return [
    '#', "\$", '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', 
    ';', ':', '\\', '/', '\'', '"', '?', '|', '=', '+', '~', ','
  ];
}

/// Get a printable list of the char blacklist for input strings
String printBlacklistedChars() {
  List<String> blacklist = getCharBlacklist();
  String blacklistString = blacklist.join(', ');
  blacklistString = "${blacklistString.substring(0, blacklistString.length - 2)} or \",\" itself";
  return blacklistString;
}

/// Returns if a string has any blacklisted characters based a predefined list and whether it is an email or not.<br>
/// This is to prevent possible harmful characters from entering the backend.
/// ```dart
/// List<String> blacklist = [
///   '#', "\$", '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', 
///   ';', ':', '\\', '/', '\'', '"', '?', '|', '=', '+', '~'
/// ];
/// ```
/// If ```emailString == false``` or ```emailString == null```, blacklist also contains ```'@'```
bool hasBlacklistedChar(String stringToCheck, bool? emailString) {
  List<String> blacklist = getCharBlacklist();

  if(emailString != true) {
    blacklist.add('@');
  }

  return blacklist.any((char) => stringToCheck.contains(char));
}

/// Returns if an email string is valid.<br>
/// Defined conditions for email string to be valid:
/// * Does not contain any blacklisted characters
/// * Contains '@' and '.'
/// * Greater than or equal to 5 characters
bool validEmail(String emailString) {
  List<String> emailCharReq = ['@', '.'];
  return !hasBlacklistedChar(emailString, true) 
          && emailCharReq.every((char) => emailString.contains(char)) 
          && emailString.length >= 5;
}

/// Returns max length of usernames as an int<br><br>
/// **This should be the ONLY place max username length is changed** 
int getMaxUsernameLength() {
  return 16;
}

/// Returns if username string is valid.<br>
/// Defined conditions for username string to be valid:
/// * Does not contain any blacklisted characters
/// * String is not empty
/// * Less than or equal to 20 characters
bool validUsername(String usernameString) {
  return !hasBlacklistedChar(usernameString, null) 
          && usernameString.isNotEmpty 
          && usernameString.length <= getMaxUsernameLength();
}

/// Returns if password is valid.<br>
/// Defined conditions for password string to be valid:
/// * Does not contain any blacklisted characters
/// * Greater than or equal to 4 characters
bool validPassword(String unhashedPasswordString) {
  return !hasBlacklistedChar(unhashedPasswordString, null) 
          && unhashedPasswordString.length >= 4;
}

/// General use loading screen for easy implementation that requires end action among other required fields.
/// * Navigation to a new window using postLoadingBuilder.
/// * Pop from window to a specific route using postLoadingPop and popErrorScreenButton.
///
///
/// <br>Example pop use case:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => LoadingScreen<bool>.withPop(
///       loadingMsg: "Please wait while we update your points...", 
///       foundMsg: "Points updated! One moment...", 
///       errorMsg: "We could not find your account to update points for.", 
///       futureFunction: submitUserGlobalPoints(addPoints: addPoints), 
///       postLoadingPop: ModalRoute.withName("/"),
///       popErrorScreenButton: "Return to Homepage",
///       valueEqualCheck: true,
///     )
///   ),
/// );
/// ```
class LoadingScreen<T> extends StatelessWidget {
  final String loadingMsg, foundMsg, errorMsg;
  final Future<T>? futureFunction;
  final RoutePredicate? postLoadingPop;
  final String? popErrorScreenButton, successMsg;
  final Widget Function(BuildContext, T?)? postLoadingBuilder;
  final bool? navigateOnError, popOnError, errorPopup;
  final Duration? successMsgDuration;
  final T? valueEqualCheck;

  /// General use loading screen for easy implementation that requires end action among other required fields.
  /// 
  /// 
  /// <br>Example pop use case:
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (context) => LoadingScreen<bool>.withPop(
  ///       loadingMsg: "Please wait while we update your points...", 
  ///       foundMsg: "Points updated! One moment...", 
  ///       errorMsg: "We could not find your account to update points for.", 
  ///       futureFunction: submitUserGlobalPoints(addPoints: addPoints), 
  ///       postLoadingPop: ModalRoute.withName("/"),
  ///       popErrorScreenButton: "Return to Homepage",
  ///       valueEqualCheck: true,
  ///     )
  ///   ),
  /// );
  /// ```
  const LoadingScreen.withPop({
    super.key,
    required this.loadingMsg,
    required this.foundMsg,
    required this.errorMsg,
    required this.futureFunction,
    required this.postLoadingPop,
    required this.popErrorScreenButton,
    required this.popOnError,
    this.valueEqualCheck,
    this.successMsg,
    this.successMsgDuration,
    this.postLoadingBuilder,
    this.navigateOnError,
    this.errorPopup = true
  });

  const LoadingScreen.withNav({
    super.key,
    required this.loadingMsg,
    required this.foundMsg,
    required this.errorMsg,
    required this.futureFunction,
    required this.postLoadingBuilder,
    this.navigateOnError,
    this.valueEqualCheck,
    this.successMsg,
    this.successMsgDuration,
    this.postLoadingPop,
    this.popOnError,
    this.popErrorScreenButton,
    this.errorPopup = true
  });

  final String exceptionMsg = "Loading screen must have loading builder or pop route and pop error screen message! Please declare these.";

  bool checkValueEqual(T value) {
    if(valueEqualCheck != null) {
      return value == valueEqualCheck;
    }
    return true;
  }

  Widget getMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget getCircleIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading...'), centerTitle: true),
      body: SafeArea(
        child: FutureBuilder<T>(
          future: futureFunction,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMessage(context, loadingMsg),
                    getCircleIndicator(context)
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null && checkValueEqual(snapshot.data as T)) {
              // Run after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if(successMsg != null && successMsgDuration == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMsg!),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                else if(successMsg != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMsg!),
                      backgroundColor: Colors.green,
                      duration: successMsgDuration!,
                    ),
                  );
                }

                if(postLoadingBuilder != null) {
                  // Remove loading screen from stack
                  Navigator.pop(context);

                  // Navigate to new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => postLoadingBuilder!(context, snapshot.data)
                    ),
                  );
                }
                else if(postLoadingPop != null) {
                  Navigator.popUntil(context, postLoadingPop!);
                }
                else {
                  throw FormatException(exceptionMsg);
                }
              });

              // Return a found message for current frame
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMessage(context, foundMsg),
                    getCircleIndicator(context)
                  ],
                ),
              );
            } 
            else {
              if(popErrorScreenButton == null && postLoadingPop == null) {
                // Run after next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(postLoadingBuilder != null) {
                    // Remove loading screen from stack
                    Navigator.pop(context);

                    if(snapshot.hasError) {
                      if(snapshot.error is SocketException) {
                        errorPopupMessage(
                          context,
                          "Error connecting to the internet. Please check your network connection.",
                          Duration(seconds: 5),
                        );
                      }
                      else {
                        errorPopupMessage(
                          context, 
                          "Error: ${snapshot.error}", 
                          null
                        );
                      }
                    }

                    if(navigateOnError != null && navigateOnError!) {
                      // Navigate to new screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => postLoadingBuilder!(context, snapshot.data),
                        ),
                      );
                    }
                  }
                  else {
                    throw FormatException(exceptionMsg);
                  }
                });

                // Return an error message for current frame
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getMessage(context, errorMsg),
                      getCircleIndicator(context)
                    ],
                  ),
                );
              }
              else if(popErrorScreenButton != null && postLoadingPop != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(errorMsg,
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 20)
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, postLoadingPop!);
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(popErrorScreenButton!)
                    )
                  ],
                );
              }
              else if(postLoadingPop != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(popOnError != null && popOnError!) {
                    Navigator.popUntil(context, postLoadingPop!);
                  }
                  else {
                    // Just pop loading screen off
                    Navigator.pop(context);
                  }

                  if(errorPopup != null && errorPopup! && errorMsg.isNotEmpty && !snapshot.hasError) {
                    errorPopupMessage(
                      context, 
                      errorMsg, 
                      Duration(seconds: 7)
                    );
                  }
                  else if(snapshot.hasError) {
                    if(snapshot.error is SocketException) {
                      errorPopupMessage(
                        context,
                        "Error connecting to the internet. Please check your network connection.",
                        Duration(seconds: 5),
                      );
                    }
                    else {
                      errorPopupMessage(
                        context, 
                        "Error: ${snapshot.error}", 
                        null
                      );
                    }
                  }
                });

                // Return a error message for current frame
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getMessage(context, errorMsg),
                      getCircleIndicator(context)
                    ],
                  ),
                );
              }
              else {
                throw FormatException(exceptionMsg);
              }
            }
          },
        ),
      ),
    );
  }
}

List<String> getLicenses() {
  final String mobilenetLicense = r'''
BSD 3-Clause License

Copyright (c) Soumith Chintala 2016, All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.''',

    litertLicense = r'''
Apache License Version 2.0, January 2004 http://www.apache.org/licenses/

TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

Definitions.

"License" shall mean the terms and conditions for use, reproduction, and distribution as defined by Sections 1 through 9 of this document.

"Licensor" shall mean the copyright owner or entity authorized by the copyright owner that is granting the License.

"Legal Entity" shall mean the union of the acting entity and all other entities that control, are controlled by, or are under common control with that entity. For the purposes of this definition, "control" means (i) the power, direct or indirect, to cause the direction or management of such entity, whether by contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the outstanding shares, or (iii) beneficial ownership of such entity.

"You" (or "Your") shall mean an individual or Legal Entity exercising permissions granted by this License.

"Source" form shall mean the preferred form for making modifications, including but not limited to software source code, documentation source, and configuration files.

"Object" form shall mean any form resulting from mechanical transformation or translation of a Source form, including but not limited to compiled object code, generated documentation, and conversions to other media types.

"Work" shall mean the work of authorship, whether in Source or Object form, made available under the License, as indicated by a copyright notice that is included in or attached to the work (an example is provided in the Appendix below).

"Derivative Works" shall mean any work, whether in Source or Object form, that is based on (or derived from) the Work and for which the editorial revisions, annotations, elaborations, or other modifications represent, as a whole, an original work of authorship. For the purposes of this License, Derivative Works shall not include works that remain separable from, or merely link (or bind by name) to the interfaces of, the Work and Derivative Works thereof.

"Contribution" shall mean any work of authorship, including the original version of the Work and any modifications or additions to that Work or Derivative Works thereof, that is intentionally submitted to Licensor for inclusion in the Work by the copyright owner or by an individual or Legal Entity authorized to submit on behalf of the copyright owner. For the purposes of this definition, "submitted" means any form of electronic, verbal, or written communication sent to the Licensor or its representatives, including but not limited to communication on electronic mailing lists, source code control systems, and issue tracking systems that are managed by, or on behalf of, the Licensor for the purpose of discussing and improving the Work, but excluding communication that is conspicuously marked or otherwise designated in writing by the copyright owner as "Not a Contribution."

"Contributor" shall mean Licensor and any individual or Legal Entity on behalf of whom a Contribution has been received by Licensor and subsequently incorporated within the Work.

Grant of Copyright License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable copyright license to reproduce, prepare Derivative Works of, publicly display, publicly perform, sublicense, and distribute the Work and such Derivative Works in Source or Object form.

Grant of Patent License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable (except as stated in this section) patent license to make, have made, use, offer to sell, sell, import, and otherwise transfer the Work, where such license applies only to those patent claims licensable by such Contributor that are necessarily infringed by their Contribution(s) alone or by combination of their Contribution(s) with the Work to which such Contribution(s) was submitted. If You institute patent litigation against any entity (including a cross-claim or counterclaim in a lawsuit) alleging that the Work or a Contribution incorporated within the Work constitutes direct or contributory patent infringement, then any patent licenses granted to You under this License for that Work shall terminate as of the date such litigation is filed.

Redistribution. You may reproduce and distribute copies of the Work or Derivative Works thereof in any medium, with or without modifications, and in Source or Object form, provided that You meet the following conditions:

(a) You must give any other recipients of the Work or Derivative Works a copy of this License; and

(b) You must cause any modified files to carry prominent notices stating that You changed the files; and

(c) You must retain, in the Source form of any Derivative Works that You distribute, all copyright, patent, trademark, and attribution notices from the Source form of the Work, excluding those notices that do not pertain to any part of the Derivative Works; and

(d) If the Work includes a "NOTICE" text file as part of its distribution, then any Derivative Works that You distribute must include a readable copy of the attribution notices contained within such NOTICE file, excluding those notices that do not pertain to any part of the Derivative Works, in at least one of the following places: within a NOTICE text file distributed as part of the Derivative Works; within the Source form or documentation, if provided along with the Derivative Works; or, within a display generated by the Derivative Works, if and wherever such third-party notices normally appear. The contents of the NOTICE file are for informational purposes only and do not modify the License. You may add Your own attribution notices within Derivative Works that You distribute, alongside or as an addendum to the NOTICE text from the Work, provided that such additional attribution notices cannot be construed as modifying the License.

You may add Your own copyright statement to Your modifications and may provide additional or different license terms and conditions for use, reproduction, or distribution of Your modifications, or for any such Derivative Works as a whole, provided Your use, reproduction, and distribution of the Work otherwise complies with the conditions stated in this License.

Submission of Contributions. Unless You explicitly state otherwise, any Contribution intentionally submitted for inclusion in the Work by You to the Licensor shall be under the terms and conditions of this License, without any additional terms or conditions. Notwithstanding the above, nothing herein shall supersede or modify the terms of any separate license agreement you may have executed with Licensor regarding such Contributions.

Trademarks. This License does not grant permission to use the trade names, trademarks, service marks, or product names of the Licensor, except as required for reasonable and customary use in describing the origin of the Work and reproducing the content of the NOTICE file.

Disclaimer of Warranty. Unless required by applicable law or agreed to in writing, Licensor provides the Work (and each Contributor provides its Contributions) on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are solely responsible for determining the appropriateness of using or redistributing the Work and assume any risks associated with Your exercise of permissions under this License.

Limitation of Liability. In no event and under no legal theory, whether in tort (including negligence), contract, or otherwise, unless required by applicable law (such as deliberate and grossly negligent acts) or agreed to in writing, shall any Contributor be liable to You for damages, including any direct, indirect, special, incidental, or consequential damages of any character arising as a result of this License or out of the use or inability to use the Work (including but not limited to damages for loss of goodwill, work stoppage, computer failure or malfunction, or any and all other commercial damages or losses), even if such Contributor has been advised of the possibility of such damages.

Accepting Warranty or Additional Liability. While redistributing the Work or Derivative Works thereof, You may choose to offer, and charge a fee for, acceptance of support, warranty, indemnity, or other liability obligations and/or rights consistent with this License. However, in accepting such obligations, You may act only on Your own behalf and on Your sole responsibility, not on behalf of any other Contributor, and only if You agree to indemnify, defend, and hold each Contributor harmless for any liability incurred by, or claims asserted against, such Contributor by reason of your accepting any such warranty or additional liability.

END OF TERMS AND CONDITIONS

APPENDIX: How to apply the Apache License to your work.

To apply the Apache License to your work, attach the following boilerplate notice, with the fields enclosed by brackets "[]" replaced with your own identifying information. (Don't include the brackets!) The text should be enclosed in the appropriate comment syntax for the file format. We also recommend that a file or class name and description of purpose be included on the same "printed page" as the copyright notice for easier identification within third-party archives.

Copyright [yyyy] [name of copyright owner]

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.''';

  return List.of([mobilenetLicense, litertLicense]);
}