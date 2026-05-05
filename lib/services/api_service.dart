import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart'; // IMPORT MODEL

class ApiService {
  // Mengembalikan List berisi Objek RecipeModel
  Future<List<RecipeModel>> fetchChickenRecipes() async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=Chicken'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['meals'];
      // Mapping JSON mentah menjadi List<RecipeModel>
      return data.map((json) => RecipeModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data resep');
    }
  }

  // Mengembalikan 1 Objek RecipeModel
  Future<RecipeModel> fetchRecipeDetail(String id) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['meals'][0];
      return RecipeModel.fromJson(data); // Ubah JSON ke Objek
    } else {
      throw Exception('Gagal memuat detail resep');
    }
  }
}