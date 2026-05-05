import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin(); 
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Fungsi mengubah logo mata
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final adaLogin = prefs.getBool('loginData') ?? false;

    if (adaLogin) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('user_$username');

    if (storedPassword != null && storedPassword == password) {
      await prefs.setBool('loginData', true);
      await prefs.setString('currentUser', username);
      
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar(
        'Gagal', 
        'Username atau Password salah!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Gagal', 'Username dan Password tidak boleh kosong', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Gagal', 'Password dan Konfirmasi Password tidak cocok!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('user_$username')) {
      Get.snackbar('Gagal', 'Username sudah terdaftar!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await prefs.setString('user_$username', password);

    Get.snackbar(
      'Sukses', 
      'Registrasi berhasil! Silakan Login.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    
    Get.back(); 
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('currentUser');
    
    Get.offAllNamed(AppRoutes.login);
  }
}