import 'package:get/get.dart';
import 'app_routes.dart';
import '../views/pages/login_screen.dart'; // Sesuaikan path jika error
import '../views/pages/register_screen.dart';
import '../views/pages/home_screen.dart';
import '../views/pages/detail_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    // Untuk detail, sementara kita bypass wajib kirim parameter id via constructor 
    // karena nanti ID akan kita ambil lewat Get.arguments
    GetPage(name: AppRoutes.detail, page: () => const DetailScreen(id: '')), 
  ];
}