import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'database_utils.dart';
import 'account_utils.dart';
import 'cache_utils.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text(
              'General Settings',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) {
                  // I don't know if we'll actually include language support but it looks
                  // good for the settings page
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                initialValue: notificationsEnabled,
                leading: const Icon(Icons.notifications_active),
                title: const Text('Enable Notifications'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.format_paint),
                title: const Text('Change Theme'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text(
              'Account',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.email),
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
                leading: const Icon(Icons.password),
                title: const Text('Change Password'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePassword()),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.remove_circle),
                title: const Text('Delete Account'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.logout),
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
    try {
      await submitEmailChange(newEmail: newEmail);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully changed email!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change email: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
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

class ChangePassword extends StatefulWidget{
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>{
  final newPasswordControl = TextEditingController();
  final newPasswordConfirmControl = TextEditingController();

  void confirmPassword() async {
    final newPassword = newPasswordControl.text.trim();
    final newPasswordConfirm = newPasswordConfirmControl.text.trim();
    
    if (newPassword.isEmpty || newPasswordConfirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newPassword != newPasswordConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Entered passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final hashedPassword = hashPassword(newPassword);
    try {
      await submitPasswordChange(newPasswordHash: hashedPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully changed password!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change password: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column (
          children: [
            TextField(
              controller: newPasswordControl,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordConfirmControl,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: ElevatedButton(
                onPressed: confirmPassword, 
                child: const Text("Confirm"),
              ),
            ),
          ]
        ),
      )
    );
  }
}

