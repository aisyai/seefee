import 'package:flutter/material.dart';
import 'views/main_workspace.dart';

void main() {
  runApp(const SeefeeApp());
}

class SeefeeApp extends StatelessWidget {
  const SeefeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seefee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate Navy modern
          primary: const Color(0xFF2563EB), // Royal Blue aksen utama
          secondary: const Color(0xFF3B82F6),
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const MainWorkspace(),
    );
  }
}
