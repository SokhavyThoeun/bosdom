import 'package:flutter/material.dart';

class SampleGateScreen extends StatelessWidget {
  const SampleGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy sample')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '1-per-account sample purchase flow. UI comes in phase 4',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
