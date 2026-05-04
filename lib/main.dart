import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database lokal Hive untuk Flutter
  await Hive.initFlutter();
  await Hive.openBox('favoriteBox');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // Menyesuaikan tema warna dengan mockup aplikasi (dominan oranye)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}