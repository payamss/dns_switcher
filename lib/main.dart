import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DnsSwitcherApp());
}

class DnsSwitcherApp extends StatelessWidget {
  const DnsSwitcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DNS Switcher',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
