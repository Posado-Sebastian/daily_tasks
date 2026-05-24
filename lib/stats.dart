import 'package:flutter/material.dart';
class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Stats coming soon!'),
      ),
    );
  }
}