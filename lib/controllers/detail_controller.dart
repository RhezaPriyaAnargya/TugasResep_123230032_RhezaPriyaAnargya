import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class DetailController extends GetxController {
  final String recipeId = Get.arguments;

  var isLoading = true.obs;
  var recipeDetail = Rxn<RecipeModel>();
  var isFavorite = false.obs;
  
  final _favoriteBox = Hive.box('favoriteBox');
  final ApiService _apiService = ApiService(); 

  @override
  void onInit() {
    super.onInit();
    fetchRecipeDetail();
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() {
    isFavorite.value = _favoriteBox.containsKey(recipeId);
  }

  Future<void> fetchRecipeDetail() async {
    isLoading.value = true;
    try {
      final data = await _apiService.fetchRecipeDetail(recipeId);
      recipeDetail.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail resep', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite() {
    if (isFavorite.value) {
      _favoriteBox.delete(recipeId);
      Get.snackbar('Sukses', 'Dihapus dari Favorit', snackPosition: SnackPosition.BOTTOM);
    } else {
      final recipe = recipeDetail.value;
      if (recipe != null) {
        _favoriteBox.put(recipeId, recipe.toJson());
      }
      Get.snackbar('Sukses', 'Ditambahkan ke Favorit', snackPosition: SnackPosition.BOTTOM);
    }
    isFavorite.value = !isFavorite.value;
  }

  List<String> getIngredients() {
    return recipeDetail.value?.ingredients ?? <String>[];
  }
}