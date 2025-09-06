import 'package:clubsync/redirect_page.dart';
import 'package:flutter/material.dart';
import 'package:clubsync/auth/login_screen.dart';
import 'package:clubsync/auth/signup_screen.dart';
import 'package:clubsync/auth/forgot_password_screen.dart';
import 'package:clubsync/Home/homepage.dart';
import 'package:clubsync/clubs/club_profile_page.dart';
import 'package:clubsync/events/events_page.dart';
import 'package:clubsync/profile/profile_page.dart';
import 'package:clubsync/data/club_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import the new redirect page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hplrrhjfixehckloofdn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwbHJyaGpmaXhlaGNrbG9vZmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMDUwNDMsImV4cCI6MjA3MjU4MTA0M30.d_U1zQlto4Cktje0JFTAz3kkC5ArqV1LrYz7FcVDCh4',
  );

  // Remove this print statement after verifying connection
  // print('Supabase client initialized: ${Supabase.instance.client}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GatherIn',
      theme: ThemeData(
        primaryColor: const Color(0xFF6a0e33),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) =>
            const RedirectPage(), // Use RedirectPage as the initial route
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => const HomePage(),
      },
      // use onGenerateRoute for dynamic pages
      onGenerateRoute: (settings) {
        if (settings.name == '/club_profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ClubProfilePage(
              club: args['club'] as Club,
              currentStudentId: args['studentId'] as String,
            ),
          );
        } else if (settings.name == '/events') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                EventsPage(clubs: args['clubs'], studentId: args['studentId']),
          );
        } else if (settings.name == '/profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                ProfilePage(studentId: args['studentId'], clubs: args['clubs']),
          );
        }
        return null;
      },
      initialRoute: '/',
    );
  }
}
