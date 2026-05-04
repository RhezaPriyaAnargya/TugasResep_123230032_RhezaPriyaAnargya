import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  void _logout() async {
    final prefs = await SharedPreferences.getInstance(); // [cite: 631]
    await prefs.setBool('loginData', false); // Merubah nilai SP sesuai prinsip authentication [cite: 627]
    await prefs.remove('currentUser'); // Opsional: Hapus info user yang sedang login

    if (mounted) {
      Navigator.pushAndRemoveUntil( // 
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepKu'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout, // Memanggil fungsi logout di AppBar [cite: 530]
          ),
        ],
      ),
      body: const Center(
        child: Text('Tampilan GridView Resep akan ada di sini'),
      ),
    );
  }
}