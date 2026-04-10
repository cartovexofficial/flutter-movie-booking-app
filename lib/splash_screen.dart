import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Timer(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CinemaRoute(page: const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── Particle background ─────────────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          // ── Radial glow at center ────────────────────────────────────
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.glowGradient,
              ),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.glowShadow,
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // App name
                Text(
                  'CinemaBook',
                  style: AppTheme.headline(38),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 10),

                // Tagline typewriter
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Your Cinema. Your Way.',
                      textStyle: AppTheme.body(16,
                          color: AppTheme.textSecondary),
                      speed: const Duration(milliseconds: 65),
                    ),
                  ],
                  totalRepeatCount: 1,
                  isRepeatingAnimation: false,
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),

                const SizedBox(height: 60),

                // Loading bar
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: AppTheme.card,
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Particle painter ──────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> _particles = List.generate(
    50,
    (i) => _Particle(seed: i),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in _particles) {
      final t = (progress + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = size.height - t * size.height * 1.2;
      final opacity = (math.sin(t * math.pi)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = (p.isAccent ? AppTheme.primary : AppTheme.accent)
            .withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x;
  final double offset;
  final double radius;
  final bool isAccent;

  _Particle({required int seed})
      : x = (seed * 37 % 100) / 100.0,
        offset = (seed * 53 % 100) / 100.0,
        radius = 1.0 + (seed % 3) * 0.8,
        isAccent = seed % 3 == 0;
}
