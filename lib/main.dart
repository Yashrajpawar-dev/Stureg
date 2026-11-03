import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'spiderman_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stureg - Spider Portal',
      theme: getSpiderManTheme(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    checkLoginStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    // Show splash screen for 2.8 seconds
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    final User? user = FirebaseAuth.instance.currentUser;
    final Widget nextScreen =
        (user != null) ? const DashboardScreen() : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpiderColors.darkBlue,
      body: Stack(
        children: [
          // Background Spider Web lattice
          Positioned.fill(
            child: CustomPaint(
              painter: SpiderWebPainter(
                webColor: SpiderColors.spiderRed.withValues(alpha: 0.08),
                showCornerWeb: true,
                showCenterWeb: true,
              ),
            ),
          ),

          // Central Hero Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spider-Man App Logo
                      const SpidermanAppLogo(
                        size: 130,
                        showGlow: true,
                        heroTag: true,
                      ),
                      const SizedBox(height: 28),

                      // Title
                      const Text(
                        'STUREG PORTAL',
                        style: TextStyle(
                          color: SpiderColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(
                              color: SpiderColors.spiderRed,
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Superhero Tagline
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 1.5,
                            width: 24,
                            color: SpiderColors.spiderRed.withValues(alpha: 0.6),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'WITH GREAT POWER COMES GREAT KNOWLEDGE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: SpiderColors.goldAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            height: 1.5,
                            width: 24,
                            color: SpiderColors.spiderRed.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Spider-Verse Student Network',
                        style: TextStyle(
                          color: SpiderColors.textSecondary,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Neon Red & Blue Progress Indicator
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            SpiderColors.spiderRed,
                          ),
                          backgroundColor:
                              SpiderColors.heroBlue.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Version / Marvel Style Tag
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0 • POWERED BY SPIDER-TECH',
                style: TextStyle(
                  color: SpiderColors.textMuted.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
