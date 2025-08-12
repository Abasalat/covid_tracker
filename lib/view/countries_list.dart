import 'package:flutter/material.dart';

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries List')),
      body: Center(
        child: Text(
          'List of countries will be displayed here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
