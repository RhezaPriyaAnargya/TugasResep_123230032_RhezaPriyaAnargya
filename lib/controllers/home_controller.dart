import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart'; 

class HomeController extends GetxController {
  var selectedIndex = 0.obs; 
  var isLoading = true.obs; 
  var recipes = <RecipeModel>[].obs;
  
  final ApiService _apiService = ApiService(); 

  @override
  void onInit() {
    super.onInit();
    fetchRecipes(); 
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('currentUser');
    Get.offAllNamed(AppRoutes.login); 
  }

  Future<void> fetchRecipes() async {
    isLoading.value = true;
    try {
      final data = await _apiService.fetchChickenRecipes();
      recipes.assignAll(data); 
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat data', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; 
    }
  }
}