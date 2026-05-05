import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

// BERUBAH MENJADI STATELESS WIDGET!
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil/Mendaftarkan AuthController ke dalam UI ini
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: const Color(0xFFFEF5E7), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Icon(Icons.restaurant_menu, size: 60, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login untuk menjelajahi ribuan resep',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                const Text('Username', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                
                // MENGGUNAKAN CONTROLLER DARI AUTH_CONTROLLER
                TextField(
                  controller: authController.usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                
                // MENGGUNAKAN OBX AGAR UI REAKTIF SAAT MATA DITEKAN
                Obx(() => TextField(
                  controller: authController.passwordController,
                  obscureText: authController.isPasswordHidden.value, 
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: authController.togglePasswordVisibility, // Memanggil fungsi di controller
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                )),
                const SizedBox(height: 40),
                
                // TOMBOL LOGIN (Memanggil fungsi login dari controller)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: authController.login, 
                    child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    // NAVIGASI GETX YANG SANGAT PENDEK
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Belum punya akun? ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(text: 'Daftar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}