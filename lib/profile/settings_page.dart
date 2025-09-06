import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>)? onProfileUpdated;

  const SettingsPage({super.key, this.userData, this.onProfileUpdated});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          if (widget.userData != null)
            _buildSettingItem(
              context,
              Icons.edit_outlined,
              'Edit Profile',
              'Update your profile information',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      userData: widget.userData!,
                      onProfileUpdated: (updatedData) {
                        if (widget.onProfileUpdated != null) {
                          widget.onProfileUpdated!(updatedData);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          if (widget.userData != null) const Divider(),
          _buildSettingItem(
            context,
            Icons.logout,
            'Log Out',
            'Sign out from your account',
            () => _showLogoutConfirmationDialog(context),
          ),
          const Divider(),
          _buildSettingItem(
            context,
            Icons.description_outlined,
            'Terms and Conditions',
            'Read our terms and conditions',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsAndConditionsPage(),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6a0e33)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen and clear navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6a0e33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Terms and Conditions for ClubSync',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last Updated: June 1, 2023',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 24),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By accessing or using the ClubSync application, you agree to be bound by these Terms and Conditions. If you do not agree to all the terms and conditions, you may not access or use the app.',
            ),
            SizedBox(height: 16),
            Text(
              '2. User Accounts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Users are responsible for maintaining the confidentiality of their account information and password. Users are responsible for all activities that occur under their account.',
            ),
            SizedBox(height: 16),
            Text(
              '3. Club Content',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Users are responsible for the content they post through the app. Inappropriate, offensive, or illegal content is prohibited.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Privacy Policy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Our Privacy Policy describes how we handle the information you provide to us when you use our app.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Modifications to Terms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We reserve the right to modify these terms at any time. Your continued use of the app after such modifications will constitute your acknowledgment of the modified terms.',
            ),
          ],
        ),
      ),
    );
  }
}
