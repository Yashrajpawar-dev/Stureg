import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'spiderman_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final prnController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedCourse;
  String? selectedSemester;

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  final List<String> courses = [
    'Computer Engineering',
    'Information Technology',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electronics Engineering',
  ];

  final List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  @override
  void dispose() {
    nameController.dispose();
    prnController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: SpiderColors.textSecondary),
      prefixIcon: Icon(icon, color: SpiderColors.spiderRed),
      filled: true,
      fillColor: SpiderColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E3B5E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E3B5E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: SpiderColors.spiderRed,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 2),
      ),
    );
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String getAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Please choose a stronger password (minimum 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password registration is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Registration failed. Please try again.';
    }
  }

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCourse == null || selectedSemester == null) {
      showMessage('Please select your course and semester.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    UserCredential? credential;
    bool accountCreated = false;

    try {
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text;

      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase did not return a user account.');
      }

      accountCreated = true;

      await user.updateDisplayName(nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'prn': prnController.text.trim(),
        'email': email,
        'course': selectedCourse,
        'semester': selectedSemester,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: SpiderColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: SpiderColors.spiderRed, width: 1.5),
            ),
            icon: const SpidermanAppLogo(size: 64, showGlow: false),
            title: const Text(
              'Hero Registered!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Your student account has been created successfully in the Spider Portal. You can now log in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SpiderColors.textSecondary),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpiderColors.spiderRed,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        showMessage(getAuthErrorMessage(error));
      }
    } catch (error) {
      if (mounted) {
        if (accountCreated) {
          showMessage(
            'Authentication succeeded, but saving profile failed. Check Firestore rules and try again.',
          );
        } else {
          showMessage('Registration failed. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpiderColors.darkRed,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpiderColors.darkBlue,
      appBar: AppBar(
        title: const Text('Register Student'),
        backgroundColor: SpiderColors.cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background subtle web
          Positioned.fill(
            child: CustomPaint(
              painter: SpiderWebPainter(
                webColor: SpiderColors.spiderRed.withValues(alpha: 0.06),
                showCornerWeb: true,
                showCenterWeb: false,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Badge with App Logo
                      Row(
                        children: [
                          const SpidermanAppLogo(size: 60, showGlow: true),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'CREATE HERO PROFILE',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Join the Stureg Spider Portal',
                                  style: TextStyle(
                                    color: SpiderColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Full Name
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Full Name',
                          Icons.person_outline_rounded,
                        ),
                        validator: requiredValidator,
                      ),
                      const SizedBox(height: 16),

                      // PRN Number
                      TextFormField(
                        controller: prnController,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'PRN Number',
                          Icons.badge_outlined,
                        ),
                        validator: requiredValidator,
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Email Address',
                          Icons.alternate_email_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email address';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Course Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: SpiderColors.cardDarkElevated,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Course / Branch',
                          Icons.school_outlined,
                        ),
                        items: courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course,
                            child: Text(
                              course,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  selectedCourse = value;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Select your course';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Semester Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: SpiderColors.cardDarkElevated,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Semester',
                          Icons.calendar_month_outlined,
                        ),
                        items: semesters.map((semester) {
                          return DropdownMenuItem<String>(
                            value: semester,
                            child: Text(
                              semester,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  selectedSemester = value;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Select your semester';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Password',
                          Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: SpiderColors.textSecondary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a password';
                          }
                          if (value.length < 6) {
                            return 'Use at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: hideConfirmPassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldDecoration(
                          'Confirm Password',
                          Icons.shield_outlined,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: SpiderColors.textSecondary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Create Account Button
                      ElevatedButton(
                        onPressed: isLoading ? null : registerStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpiderColors.spiderRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: SpiderColors.spiderRed.withValues(alpha: 0.5),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Already have account
                      Center(
                        child: TextButton(
                          onPressed:
                              isLoading ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: SpiderColors.electricBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
