
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  InputDecoration fieldDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E0EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF6558D3),
          width: 2,
        ),
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
        return 'Please choose a stronger password.';
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
    // Validate the form before sending anything to Firebase.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCourse == null || selectedSemester == null) {
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

      // 1. Create the account in Firebase Authentication.
      // Firebase prevents duplicate email accounts.
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase did not return a user account.');
      }

      accountCreated = true;

      // Save the student's name to the Firebase Auth profile.
      await user.updateDisplayName(nameController.text.trim());

      // 2. Save the student profile in Cloud Firestore.
      // The Auth UID identifies the document.
      // PRN is ordinary information and is NOT required to be unique.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'prn': prnController.text.trim(),
        'email': email,
        'course': selectedCourse,
        'semester': selectedSemester,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // No dashboard yet, so return the student to Login.
      // Sign out so the newly registered student can test Login.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF6558D3),
              size: 48,
            ),
            title: const Text('Registration Successful!'),
            content: const Text(
              'Your student account has been created. '
              'You can now log in with your email and password.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Go to Login'),
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
            'Your authentication account was created, but saving '
            'the student profile failed. Check Firestore rules and '
            'your connection before trying again.',
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: const Color(0xFFF7F6FC),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF211D43),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your details to join the Student Portal.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),

                // Full name
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: fieldDecoration(
                    'Full Name',
                    Icons.person_outline,
                  ),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 18),

                // PRN: not unique
                TextFormField(
                  controller: prnController,
                  decoration: fieldDecoration(
                    'PRN Number',
                    Icons.badge_outlined,
                  ),
                  validator: requiredValidator,
                ),
                const SizedBox(height: 18),

                // Email: unique through Firebase Authentication
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: fieldDecoration(
                    'Email Address',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email address';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Course
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: fieldDecoration(
                    'Course',
                    Icons.school_outlined,
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course,
                      child: Text(course),
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
                const SizedBox(height: 18),

                // Semester
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: fieldDecoration(
                    'Semester',
                    Icons.calendar_month_outlined,
                  ),
                  items: semesters.map((semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester),
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
                const SizedBox(height: 18),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: fieldDecoration(
                    'Password',
                    Icons.lock_outline,
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
                const SizedBox(height: 18),

                // Confirm password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: fieldDecoration(
                    'Confirm Password',
                    Icons.lock_reset_outlined,
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

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6558D3),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Color(0xFF6558D3),
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
    );
  }
}
