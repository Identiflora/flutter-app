import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'cache_utils.dart';
import 'package:provider/provider.dart';
import 'package:identiflora/theme/theme_provider.dart';
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
    List<Shadow> iconShadows = [
      BoxShadow(
        color: Theme.of(context).colorScheme.secondary,
        blurRadius: 4.0,
        spreadRadius: 1.0,
      ),
      BoxShadow(
        color: Theme.of(context).colorScheme.primary,
        blurRadius: 10.0,
        spreadRadius: 1.0,
      ),
    ];

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
      body: SettingsList(
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
                leading: Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) {
                  // I don't know if we'll actually include language support but it looks
                  // good for the settings page
                },
              ),

              //notifications switch
              SettingsTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: Text('Enable Notifications'),

                onPressed: (context) {
                  setState(() {
                    notificationsEnabled = !notificationsEnabled;
                  });
                },

                trailing: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 6.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Switch(
                    value: notificationsEnabled,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ),

              SettingsTile(
                leading: Icon(
                  Icons.format_paint,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: const Text('Theme'),

                trailing: DropdownButton<String>(
                  value: currentTheme,
                  underline: const SizedBox.shrink(),
                  icon: Icon(
                    Icons.unfold_more,
                    color: Theme.of(context).colorScheme.secondary,
                    shadows: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),

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
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: const Text('Profile'),
              ),

              SettingsTile.navigation(
                leading: Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
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
                leading: Icon(
                  Icons.password,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: const Text('Change Password'),
              ),

              SettingsTile.navigation(
                leading: Icon(
                  Icons.remove_circle,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
                title: const Text('Delete Account'),
              ),

              SettingsTile.navigation(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: iconShadows,
                ),
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
        ],
      ),
    );
  }
}

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete email field"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email entered"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Submit new email logic

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully changed password!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: newEmailControl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "New Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: ElevatedButton(
                onPressed: confirmPressed,
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
