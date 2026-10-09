import 'package:carbsense/utils/route_names.dart';
import 'package:flutter/material.dart';
import 'package:carbsense/widgets/carbsense_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Fade in animation
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Scale up — starts small, grows to normal
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    // Start animation, then navigate
    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushNamed(context, RouteNames.welcomeView);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // pure white background
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo widget//size 44 for app bar, 160 for splash screen
                CarbSenseLogo(size: 160),

                SizedBox(height: 24),

                // App name
                Text(
                  'CarbSense',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),

                SizedBox(height: 6),

                // Tagline
                Text(
                  'EAT SMART. LIVE WELL.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB0B7C3),
                    letterSpacing: 3,
                  ),
                ),

                SizedBox(height: 60),

                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(1.0),
                    SizedBox(width: 6),
                    _dot(0.45),
                    SizedBox(width: 6),
                    _dot(0.2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Small helper for loading dot
  Widget _dot(double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFF1A56DB),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
