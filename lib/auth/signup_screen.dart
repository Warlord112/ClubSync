import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedRole; // 'Student' or 'Instructor'
  final _departmentController = TextEditingController();
  String? _selectedField; // Re-added for student role
  String? _selectedSemester; // Re-added for student role
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final SupabaseClient supabase =
      Supabase.instance.client; // Initialize Supabase client

  final List<String> _fieldsOfStudy = [
    'BSC in CSE',
    'MA in CSE',
    'BSC in EEE',
    'BA in English',
    'BSC in Economics',
    'BSC in ETE',
    'BSBA',
  ];

  final List<String> _departments = ['CSE', 'EEE', 'BBA', 'English'];

  final List<String> _semesters = [
    '1st semester',
    '2nd semester',
    '3rd semester',
    '4th semester',
    '5th semester',
    '6th semester',
    '7th semester',
    '8th semester',
    '9th semester',
    '10th semester',
    '11th semester',
    '12th semester',
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to student ID controller for automatic email generation
    _studentIdController.addListener(_updateEmailFromStudentId);
  }

  void _updateEmailFromStudentId() {
    if ((_selectedRole == 'Student' || _selectedRole == null) &&
        _studentIdController.text.isNotEmpty) {
      _emailController.text = '${_studentIdController.text}@eastdelta.edu.bd';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose(); // Dispose new controller
    _selectedField = null; // Clear selected field
    _selectedSemester = null; // Clear selected semester
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6a0e33),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6a0e33),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Selection Dropdown
                  DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration('I am a'),
                    value: _selectedRole,
                    hint: const Text('Select your role'),
                    items: <String>['Student', 'Instructor']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                        // Trigger email update when role changes to Student
                        _updateEmailFromStudentId();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _buildInputDecoration('Full Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Conditional Fields based on Role
                  if (_selectedRole == 'Student' || _selectedRole == null) ...[
                    // Student ID
                    TextFormField(
                      controller: _studentIdController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Student ID'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter student ID' : null,
                    ),
                    const SizedBox(height: 16),

                    // University Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('University Email'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter email';
                        if (!value.endsWith('@eastdelta.edu.bd')) {
                          return 'Use university email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Field of Study Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedField,
                      decoration: _buildInputDecoration('Field of Study'),
                      items: _fieldsOfStudy.map((field) {
                        return DropdownMenuItem(
                          value: field,
                          child: Text(field),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedField = value);
                      },
                      validator: (value) =>
                          value == null ? 'Select field of study' : null,
                    ),
                    const SizedBox(height: 16),

                    // Semester Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSemester,
                      decoration: _buildInputDecoration('Semester'),
                      items: _semesters.map((semester) {
                        return DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSemester = value);
                      },
                      validator: (value) =>
                          value == null ? 'Select semester' : null,
                    ),
                    const SizedBox(height: 16),
                  ] else if (_selectedRole == 'Instructor') ...[
                    // Instructor ID
                    TextFormField(
                      controller:
                          _studentIdController, // Using same controller, just changing label
                      keyboardType: TextInputType.text,
                      decoration: _buildInputDecoration('Instructor ID'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter instructor ID' : null,
                    ),
                    const SizedBox(height: 16),

                    // University Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('University Email'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter email';
                        if (!value.endsWith('@eastdelta.edu.bd')) {
                          return 'Use university email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Department
                    DropdownButtonFormField<String>(
                      value: null, // No pre-selected department
                      decoration: _buildInputDecoration('Department'),
                      hint: const Text('Select Department'),
                      items: _departments.map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _departmentController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration(
                      'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter password';
                      if (value.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _buildInputDecoration(
                      'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6a0e33,
                        ), // Reverted to maroon
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Keep text color white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Color(0xFF6a0e33)),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6a0e33),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6a0e33)),
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _submitForm() async {
    // Make _submitForm async
    if (_formKey.currentState!.validate()) {
      debugPrint('SignupScreen: Form is valid. Attempting signup...');
      try {
        // 1. Sign up the user with email and password in Supabase Auth
        debugPrint(
          'SignupScreen: Calling supabase.auth.signUp for email: ${_emailController.text.trim()}',
        );

        // Build full metadata so we can reconstruct user profile after email verification
        final Map<String, dynamic> metadata = {
          'full_name': _fullNameController.text.trim(),
          'role': _selectedRole,
        };
        if (_selectedRole == 'Student') {
          metadata['student_id'] = _studentIdController.text.trim();
          metadata['field_of_study'] = _selectedField;
          metadata['semester'] = _selectedSemester;
        } else if (_selectedRole == 'Instructor') {
          metadata['instructor_id'] = _studentIdController.text.trim();
          metadata['department'] = _departmentController.text.trim();
        }

        final AuthResponse response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: metadata,
        );
        debugPrint(
          'SignupScreen: Supabase signUp response received. User: ${response.user?.id}, Error: ${response.session?.isExpired == true
              ? 'Session expired or invalid'
              : response.session == null
              ? 'No session'
              : 'Session exists'}',
        );

        if (response.user != null) {
          final String userId = response.user!.id;

          // Build full user profile and write to public.users immediately
          final Map<String, dynamic> userProfileData = {
            'id': userId,
            'full_name': _fullNameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
          };
          if (_selectedRole == 'Student') {
            userProfileData['student_id'] = _studentIdController.text.trim();
            userProfileData['field_of_study'] = _selectedField;
            userProfileData['semester'] = _selectedSemester;
          } else if (_selectedRole == 'Instructor') {
            userProfileData['instructor_id'] = _studentIdController.text.trim();
            userProfileData['department'] = _departmentController.text.trim();
          }

          // Remove nulls to avoid overwriting with nulls
          userProfileData.removeWhere((k, v) => v == null);

          try {
            // Use upsert to avoid duplicate key issues if the user retries
            await supabase.from('users').upsert(userProfileData);
            debugPrint(
              'SignupScreen: User profile written to public.users: ${userProfileData.keys.toList()}',
            );
          } catch (e) {
            debugPrint(
              'SignupScreen: Error writing user profile to public.users: $e',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not save profile to database: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Continue flow; user can still verify and log in.
          }

          debugPrint(
            'SignupScreen: User created in auth.users. Instructing user to check email for verification.',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account created! Please check your email for verification before logging in.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to login page after successful signup, passing user profile data
            Navigator.pushReplacementNamed(
              context,
              '/login',
              arguments: userProfileData,
            );
          }
        } else {
          debugPrint(
            'SignupScreen: Supabase signUp did not return a user. AuthResponse: $response',
          );
          // Handle cases where user is null (e.g., email already registered without confirmation)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account creation failed or email already registered. Please check your email for verification if you have already registered.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        debugPrint('SignupScreen: AuthException caught: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        debugPrint('SignupScreen: Unexpected error caught: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
