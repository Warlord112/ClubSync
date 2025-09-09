import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'Home/homepage.dart'; // Keep capitalization consistent with directory structure
import 'clubs/club_profile_page.dart';
import 'events/events_page.dart';
import 'profile/profile_page.dart';
import 'data/club_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wddjfzeuirfhrtxemlha.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndkZGpmemV1aXJmaHJ0eGVtbGhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxNzg2MTEsImV4cCI6MjA3Mjc1NDYxMX0.6fdXIO623vVpWFWdh7XUYlaF6-4uAcifhl13BhUmL3A',
  );
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
        '/': (context) => const LoginScreen(),
        '/login': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return LoginScreen(userProfileData: args);
        },
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
