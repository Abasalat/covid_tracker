import 'package:flutter/material.dart';

class WorldstateScreen extends StatefulWidget {
  const WorldstateScreen({super.key});

  @override
  State<WorldstateScreen> createState() => _WorldstateScreenState();
}

class _WorldstateScreenState extends State<WorldstateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('World State Screen')));
  }
}
