import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'spiderman_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getStudentData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No student is logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout failed: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpiderColors.darkRed,
          content: Text(
            'Logout failed. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: SpiderColors.darkBlue,
      appBar: AppBar(
        backgroundColor: SpiderColors.cardDark,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SpidermanAppLogo(size: 32, showGlow: false),
            SizedBox(width: 10),
            Text(
              'SPIDER PORTAL',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: SpiderColors.spiderRed),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Web
          Positioned.fill(
            child: CustomPaint(
              painter: SpiderWebPainter(
                webColor: SpiderColors.spiderRed.withValues(alpha: 0.06),
                showCornerWeb: true,
                showCenterWeb: true,
              ),
            ),
          ),

          SafeArea(
            child: user == null
                ? const Center(
                    child: Text(
                      'Please log in again.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: getStudentData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: SpiderColors.spiderRed,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: SpiderColors.spiderRed,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Unable to load student details.',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SpiderColors.spiderRed,
                                ),
                                onPressed: () => logout(context),
                                child: const Text('Back to Login'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SpidermanAppLogo(size: 80, showGlow: false),
                              const SizedBox(height: 16),
                              const Text(
                                'Student profile not found in database.',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SpiderColors.spiderRed,
                                ),
                                onPressed: () => logout(context),
                                child: const Text('Back to Login'),
                              ),
                            ],
                          ),
                        );
                      }

                      final data = snapshot.data!.data()!;

                      final name = data['name'] ?? 'Student Hero';
                      final prn = data['prn'] ?? 'N/A';
                      final email =
                          data['email'] ?? user.email ?? 'Not available';
                      final course = data['course'] ?? 'Not available';
                      final semester = data['semester'] ?? 'Not available';

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Profile Card
                            SpiderCard(
                              hasGlow: true,
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                children: [
                                  // Spider Avatar
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: SpiderColors.spiderRed,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: SpiderColors.spiderRed
                                              .withValues(alpha: 0.4),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: SpidermanAppLogo(
                                        size: 80,
                                        showGlow: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    name.toString().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: SpiderColors.spiderRed
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: SpiderColors.spiderRed
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      'ID / PRN: $prn',
                                      style: const TextStyle(
                                        color: SpiderColors.goldAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section Title
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: SpiderColors.spiderRed,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ACADEMIC PROFILE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Detail items
                            studentDetail(
                              Icons.badge_outlined,
                              'Student Name',
                              name.toString(),
                            ),
                            studentDetail(
                              Icons.credit_card_outlined,
                              'PRN Number',
                              prn.toString(),
                            ),
                            studentDetail(
                              Icons.alternate_email_rounded,
                              'Email Address',
                              email.toString(),
                            ),
                            studentDetail(
                              Icons.school_outlined,
                              'Course / Branch',
                              course.toString(),
                            ),
                            studentDetail(
                              Icons.menu_book_outlined,
                              'Current Semester',
                              semester.toString(),
                            ),
                            const SizedBox(height: 24),

                            // Logout Button
                            ElevatedButton.icon(
                              onPressed: () => logout(context),
                              icon: const Icon(Icons.logout_rounded, size: 20),
                              label: const Text(
                                'LOGOUT FROM PORTAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SpiderColors.cardDarkElevated,
                                foregroundColor: SpiderColors.spiderRed,
                                side: BorderSide(
                                  color: SpiderColors.spiderRed.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget studentDetail(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: SpiderColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222E4E)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SpiderColors.spiderRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: SpiderColors.spiderRed, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SpiderColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
