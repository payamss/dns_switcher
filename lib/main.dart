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
      debugShowCheckedModeBanner: false,
      title: 'DNS Switcher',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
