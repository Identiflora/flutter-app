import 'package:flutter/material.dart';
import 'package:identiflora/user_credentials/account_utils.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:settings_ui/settings_ui.dart';
import '../user_data/cache_utils.dart';
import 'package:provider/provider.dart';
import 'package:identiflora/theme/theme_provider.dart';
import 'package:identiflora/widgets/neon_widgets.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsButton();
}

class _SettingsButton extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Image.asset(
              'assets/homepage/settings_icon.png',
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;

    // Map the enum back to your dropdown strings
    String currentTheme;
    if (themeMode == ThemeMode.light) {
      currentTheme = 'Light Theme';
    } else if (themeMode == ThemeMode.dark) {
      currentTheme = 'Dark Theme';
    } else {
      currentTheme = 'Device Theme';
    }
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SafeArea(
        child: SettingsList(
          sections: [
            SettingsSection(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General Settings',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ],
              ),

              tiles: <AbstractSettingsTile>[
                SettingsTile.navigation(
                  leading: NeonIcon(Icons.language),
                  title: const Text('Language'),
                  value: const Text('English'),
                  onPressed: (context) {
                    // I don't know if we'll actually include language support but it looks
                    // good for the settings page
                  },
                ),

                //notifications switch
                SettingsTile(
                  leading: NeonIcon(Icons.notifications_active),
                  title: Text('Enable Notifications'),

                  onPressed: (context) {
                    setState(() {
                      notificationsEnabled = !notificationsEnabled;
                    });
                  },

                  trailing: NeonSwitch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                ),

                SettingsTile(
                  leading: NeonIcon(Icons.format_paint),
                  title: const Text('Theme'),

                  trailing: DropdownButton<String>(
                    value: currentTheme,
                    underline: const SizedBox.shrink(),
                    icon: NeonIcon(Icons.unfold_more),

                    // Dropdown options
                    items: const [
                      DropdownMenuItem(
                        value: 'Device Theme',
                        child: Text('Device Theme'),
                      ),
                      DropdownMenuItem(
                        value: 'Light Theme',
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: 'Dark Theme',
                        child: Text('Dark Theme'),
                      ),
                    ],

                    // Handle the user selecting a new option
                    onChanged: (String? selection) {
                      if (selection == null) return;

                      final provider = Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      );

                      switch (selection) {
                        case 'Light Theme':
                          provider.setThemeMode(ThemeMode.light);
                          break;
                        case 'Dark Theme':
                          provider.setThemeMode(ThemeMode.dark);
                          break;
                        case 'Device Theme':
                        default:
                          provider.setThemeMode(ThemeMode.system);
                          break;
                      }
                    },
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ],
              ),

              tiles: <SettingsTile>[
                  SettingsTile.navigation(
                  leading: NeonIcon(Icons.email),
                  title: const Text('Change Email'),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangeEmail(),
                      ),
                    );
                  },
                ),

                SettingsTile.navigation(
                  leading: NeonIcon(Icons.password),
                  title: const Text('Change Password'),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePassword()),
                    );
                  },
                ),

                SettingsTile.navigation(
                  leading: const NeonIcon(Icons.remove_circle),
                  title: const Text('Delete Account'),
                  onPressed: (context) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete Account?'),
                        content: const Text(
                          'This action is permanent. All your plant submissions, points, and badges will be lost forever.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                final success = await submitDeleteAccount();
                                if (success) {
                                  await deleteAuthToken();
                                  if (!context.mounted) return;
                                  Navigator.popUntil(context, ModalRoute.withName('/'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Account deleted successfully"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  errorPopupMessage(
                                    context, 
                                    "Error: $e", 
                                    null
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SettingsTile.navigation(
                  leading: NeonIcon(Icons.logout),
                  title: const Text('Sign Out'),
                  onPressed: (context) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Sign out logic
                              deleteAuthToken();
                              Navigator.popUntil(
                                context,
                                ModalRoute.withName('/'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Successfully signed out"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ],
              ),

              tiles: <SettingsTile>[
                  SettingsTile.navigation(
                  leading: NeonIcon(Icons.info_outline),
                  title: const Text('Licenses'),
                  onPressed: (context) {
                    showLicensePage(
                      context: context,
                      applicationName: 'Identiflora'
                    );
                  } 
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

// Change email page and submissions logic
// Should be moved to its own file

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final newEmailControl = TextEditingController();

  void confirmPressed() async {
    final newEmail = newEmailControl.text.trim();

    if (newEmail.isEmpty) {
      errorPopupMessage(
        context, 
        "Please complete all fields!", 
        null
      );

      return;
    }
    else if (!validEmail(newEmail)) {
      errorPopupMessage(
        context, 
        "Emails cannot be less than 5 characters and must contain '@' and '.'\n\nAdditionally, emails cannot contain any of the following:\n${printBlacklistedChars()}", 
        Duration(seconds: 8)
      );

      return;
    }

    try {
      bool success = await submitEmailChange(newEmail: newEmail);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully updated email!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (err) {
      if (mounted) {
        errorPopupMessage(
          context, 
          "Failed to update email: $err", 
          null
        );
      }
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Change Email")
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeonInputField(controller: newEmailControl, labelText: "New Email"),
            const SizedBox(height: 16),
            SizedBox(
              child: NeonOutlinedButton(
                onPressed: confirmPressed,
                labelText: "Confirm",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Change Password page and submission logic
// Should also be moved to its own file

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final newPasswordControl = TextEditingController();
  final confirmPasswordControl = TextEditingController();
  bool passIsObscured = true;

  void confirmPressed() async {
    final password = newPasswordControl.text.trim();
    final confirm = confirmPasswordControl.text.trim();

    if(password.isEmpty) {
      errorPopupMessage(
        context, 
        "Please complete all fields!", 
        null
      );

      return;
    }
    else if (password != confirm) {
      errorPopupMessage(
        context, 
        "Password confirm does not match!", 
        null
      );
      
      return;
    }
    else if(!validPassword(password)) {
      errorPopupMessage(
        context, 
        "Passwords cannot be less than 4 characters or contain any of the following:\n${printBlacklistedChars()}", 
        Duration(seconds: 8)
      );

      return;
    }

    try {
      final hashedPassword = hashPassword(password);
      
      bool success = await submitPasswordChange(newPasswordHash: hashedPassword);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully updated password!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (err) {
      if (mounted) {
        errorPopupMessage(
          context, 
          "Error: $err", 
          null
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Change Password")
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeonInputField(
              controller: newPasswordControl, 
              labelText: "New Password",
              obscureText: passIsObscured,
              suffixIcon: IconButton(
                onPressed: () => setState(() => passIsObscured = !passIsObscured), 
                icon: Icon(passIsObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined)
              ),
            ),
            const SizedBox(height: 12),
            
            NeonInputField(
              controller: confirmPasswordControl, 
              labelText: "Confirm New Password",
              obscureText: passIsObscured,
              suffixIcon: IconButton(
                onPressed: () => setState(() => passIsObscured = !passIsObscured), 
                icon: Icon(passIsObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined)
              ),
            ),
            const SizedBox(height: 16),
            
            NeonOutlinedButton(
              onPressed: confirmPressed, 
              labelText: "Confirm"
            ),
          ],
        ),
      ),
    );
  }
}

class LicenseModalBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 600),
      ),
      builder: (context) => const LicenseSheetContent(),
    );
  }
}

class LicenseSheetContent extends StatelessWidget {
  const LicenseSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 300),
      snapSizes: [.7, .91],
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            //anything to add to the sheet goes in this child
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text("Licenses"),
              ],
            ),
          ),
        );
      },
    );
  }
}