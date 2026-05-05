import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/detail_controller.dart';
import '../../models/recipe_model.dart'; 

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, String? id}); 

  @override
  Widget build(BuildContext context) {
    final DetailController controller = Get.put(DetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // 1. Cek apakah sedang loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        // 2. Ekstrak data modelnya. Jika null, tampilkan error.
        final RecipeModel? recipe = controller.recipeDetail.value;
        if (recipe == null) {
          return const Center(child: Text('Data tidak ditemukan.'));
        }

        // 3. Render UI menggunakan data dari Objek 'recipe'
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(recipe.thumb), 
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleAndChips(recipe.name, recipe.category, recipe.area), 
                    const SizedBox(height: 24),
                    _buildFavoriteButton(controller),
                    const SizedBox(height: 32),
                    _buildIngredientsList(recipe.ingredients), 
                    const SizedBox(height: 32),
                    _buildInstructions(recipe.instructions ?? ''), 
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderImage(String imageUrl) {
    return Stack(
      children: [
        Image.network(
          imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>  Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(), 
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndChips(String title, String? category, String? area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (category != null) _buildSmallChip(Icons.category, category),
            if (category != null) const SizedBox(width: 12),
            if (area != null) _buildSmallChip(Icons.location_on, area),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(DetailController controller) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isFavorite.value ? Colors.red[400] : Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: controller.toggleFavorite,
        icon: Icon(controller.isFavorite.value ? Icons.favorite : Icons.favorite_border),
        label: Text(
          controller.isFavorite.value ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )),
    );
  }

  Widget _buildIngredientsList(List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bahan-bahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...ingredients.map((item) => Padding( 
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildInstructions(String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cara Memasak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          instructions,
          style: const TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }
}