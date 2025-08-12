import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:covid_tracker/view/worldstate_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorldstateScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // take only needed height
            children: [
              AnimatedBuilder(
                animation: _controller,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(child: Image.asset('images/virus.png')),
                ),
                builder: (context, child) => Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ), // was * 08 (8x) — now 8%
              const Text(
                'Covid-19 \n Tracker App',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
