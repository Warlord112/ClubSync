import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfileData;
  const LoginScreen({super.key, this.userProfileData});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedRole; // 'student' or 'instructor'
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your role.')),
        );
      }
      return;
    }

    try {
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user != null) {
        print(
          'LoginScreen: Auth successful for user ID: ${authResponse.user!.id}',
        );

        // Build user profile data from signup arguments or auth user metadata
        final user = authResponse.user!;
        final Map<String, dynamic>? meta = user.userMetadata;
        final Map<String, dynamic> profileData = {
          'id': user.id,
          'email': user.email ?? _emailController.text.trim(),
          'full_name':
              (widget.userProfileData?['full_name']) ??
              (meta != null ? meta['full_name'] : null),
          'role':
              (widget.userProfileData?['role']) ??
              (meta != null ? meta['role'] : null) ??
              _selectedRole,
        };
        final String? roleForProfile = profileData['role'] as String?;
        if (roleForProfile == 'Student') {
          profileData['student_id'] =
              (widget.userProfileData?['student_id']) ??
              (meta != null ? meta['student_id'] : null);
          profileData['field_of_study'] =
              (widget.userProfileData?['field_of_study']) ??
              (meta != null ? meta['field_of_study'] : null);
          profileData['semester'] =
              (widget.userProfileData?['semester']) ??
              (meta != null ? meta['semester'] : null);
        } else if (roleForProfile == 'Instructor') {
          profileData['instructor_id'] =
              (widget.userProfileData?['instructor_id']) ??
              (meta != null ? meta['instructor_id'] : null);
          profileData['department'] =
              (widget.userProfileData?['department']) ??
              (meta != null ? meta['department'] : null);
        }

        // Remove nulls so we never overwrite existing values with null
        final Map<String, dynamic> insertData = Map<String, dynamic>.from(
          profileData,
        )..removeWhere((key, value) => value == null);
        final Map<String, dynamic> updateData = Map<String, dynamic>.from(
          insertData,
        )..remove('id');

        // Check if user profile exists in public.users
        final existingProfile = await supabase
            .from('users')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existingProfile == null) {
          print('LoginScreen: User profile not found, attempting to insert.');
          try {
            await supabase.from('users').insert(insertData);
            print(
              'LoginScreen: User profile inserted successfully with fields: ${insertData.keys.toList()}',
            );
          } catch (e) {
            final msg = e.toString();
            // If duplicate key due to race, ignore and continue
            if (msg.contains('duplicate key') ||
                msg.contains('already exists')) {
              print(
                'LoginScreen: Profile insert encountered duplicate; proceeding to update.',
              );
              if (updateData.isNotEmpty) {
                await supabase
                    .from('users')
                    .update(updateData)
                    .eq('id', user.id);
                print(
                  'LoginScreen: Profile updated after duplicate insert race.',
                );
              }
            } else {
              print('LoginScreen: Error inserting user profile: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving profile data: $e')),
                );
              }
              // Do not block login if auth succeeded
            }
          }
        } else {
          print(
            'LoginScreen: User profile already exists. Ensuring fields are up-to-date...',
          );
          if (updateData.isNotEmpty) {
            try {
              await supabase.from('users').update(updateData).eq('id', user.id);
              print(
                'LoginScreen: User profile updated with fields: ${updateData.keys.toList()}',
              );
            } catch (e) {
              print('LoginScreen: Error updating user profile: $e');
              // Continue login flow even if update fails
            }
          } else {
            print('LoginScreen: No additional non-null fields to update.');
          }
        }

        // Fetch role from users table; if not available, fall back to metadata
        final response = await supabase
            .from('users')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        print('LoginScreen: User role query response: $response');
        String? userRole = (response != null && response.isNotEmpty)
            ? response['role'] as String?
            : (meta != null ? meta['role'] as String? : null);

        // For backward compatibility, allow 'moderator' role to log in as 'Instructor'
        if (userRole == 'moderator') {
          userRole = 'Instructor';
        }

        if (userRole == null) {
          await supabase.auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed: User role not found in database.'),
              ),
            );
          }
          return;
        }

        if (userRole != _selectedRole) {
          await supabase.auth.signOut(); // Log out the user if role mismatch
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Login failed: You are registered as $userRole, please select $userRole to login.',
                ),
              ),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login failed: Authentication response user is null.',
              ),
            ),
          );
        }
        return;
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  void _signInWithGoogle() {
    // TODO: Implement Google sign-in
    debugPrint('Google sign-in pressed');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password').catchError((e) {
      debugPrint('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open password reset')),
      );
      return null; // Added to satisfy lint
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6a0e33),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo + Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6a0e33),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'GatherIn',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF6a0e33)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF6a0e33)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Selection
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF6a0e33)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    items: <String>['Student', 'Instructor']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF6a0e33)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🚀 Sign In Button → goes straight to Dashboard
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6a0e33),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _signIn,
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Create Account Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: 'Create account',
                            style: TextStyle(
                              color: Color(0xFF6a0e33),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
