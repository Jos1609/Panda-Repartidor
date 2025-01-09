import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:panda_repartidor/screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda Repartidor',
      theme: ThemeData(
        primaryColor: const Color(0xFF22A45D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22A45D),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(), 
        '/home': (context) => const HomeScreen(),  
      },
    );
  }
}