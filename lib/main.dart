import 'package:flutter/material.dart';
import 'package:clubsync/auth/login_screen.dart';
import 'package:clubsync/auth/signup_screen.dart';
import 'package:clubsync/auth/forgot_password_screen.dart';
import 'package:clubsync/Home/homepage.dart';

void main() {
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
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => const HomePage(),
      },
      initialRoute: '/',
    );
  }
}
