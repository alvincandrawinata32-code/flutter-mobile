import 'package:flutter/material.dart'; 
import 'screens/login_screen.dart'; 

class Modul06App extends StatelessWidget {
  const Modul06App({super.key}); 
  
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Modul 06 — Login &amp; Session Dasar', 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)), 
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}