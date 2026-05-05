import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../controllers/home_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/recipe_model.dart'; // Pastikan import model-nya

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil Controller (Karena kamu tidak pakai bindings, Get.put adalah cara yang paling tepat!)
    final HomeController homeController = Get.put(HomeController());
    
    final favoriteBox = Hive.box('favoriteBox');

    final List<Widget> bodyWidgets = [
      _buildHomeBody(homeController),
      _buildFavoriteBody(favoriteBox), 
    ];

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFFEF5E7), 
      appBar: AppBar(
        title: Text(
          homeController.selectedIndex.value == 0 ? 'ResepKu' : 'Favorit Saya',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: homeController.logout, 
          ),
        ],
      ),
      body: bodyWidgets[homeController.selectedIndex.value], 
      
      bottomNavigationBar: BottomNavigationBar( 
        currentIndex: homeController.selectedIndex.value,
        onTap: homeController.changeTabIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorit'),
        ],
      ),
    ));
  }

  // ==== WIDGET UNTUK TAB HOME ====
  Widget _buildHomeBody(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Resep Chicken', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }

            if (controller.recipes.isEmpty) {
              return const Center(child: Text('Tidak ada resep ditemukan.'));
            }

            return GridView.builder( 
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12, 
                childAspectRatio: 0.85, 
              ),
              itemCount: controller.recipes.length,
              itemBuilder: (context, index) {
                // Datanya sekarang jelas: RecipeModel
                final RecipeModel recipe = controller.recipes[index];
                return _buildRecipeCard(recipe);
              },
            );
          }),
        ),
      ],
    );
  }

  // ==== WIDGET KARTU RESEP (HOME) ====
  Widget _buildRecipeCard(RecipeModel recipe) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, 
      elevation: 3,
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.detail, arguments: recipe.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                recipe.thumb, // <-- Menggunakan properti objek (.thumb)
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe.name, // <-- Menggunakan properti objek (.name)
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2, 
                overflow: TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== WIDGET UNTUK TAB FAVORIT ====
  Widget _buildFavoriteBody(Box favoriteBox) {
    return ValueListenableBuilder(
      valueListenable: favoriteBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('Belum ada resep favorit.', style: TextStyle(color: Colors.grey, fontSize: 16)));
        }

        final favoriteKeys = box.keys.toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          itemCount: favoriteKeys.length,
          itemBuilder: (context, index) {
            final key = favoriteKeys[index];
            final recipeMap = box.get(key); // Data dari Hive biasanya berupa Map/JSON
            
            return _buildFavoriteCard(key, recipeMap, favoriteBox);
          },
        );
      },
    );
  }

  // ==== WIDGET KARTU RESEP FAVORIT ====
  Widget _buildFavoriteCard(dynamic key, dynamic recipe, Box favoriteBox) {
    // Karena kita tidak memakai Adapter Hive, kita baca datanya sebagai Map (JSON bawaan API)
    // Atau jika sebelumnya tersimpan sebagai RecipeModel, kita handle juga agar tidak error
    final String id = recipe is Map ? recipe['idMeal'] ?? '' : recipe.id;
    final String thumb = recipe is Map ? recipe['strMealThumb'] ?? '' : recipe.thumb;
    final String name = recipe is Map ? recipe['strMeal'] ?? '' : recipe.name;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.detail, arguments: id); // Gunakan variabel id
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    thumb, // Gunakan variabel thumb
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name, // Gunakan variabel name
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6, right: 6,
              child: GestureDetector(
                onTap: () {
                  favoriteBox.delete(key); 
                  Get.snackbar('Sukses', 'Resep dihapus dari favorit', snackPosition: SnackPosition.BOTTOM);
                },
                child: CircleAvatar(
                  radius: 12, backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.close, size: 16, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}