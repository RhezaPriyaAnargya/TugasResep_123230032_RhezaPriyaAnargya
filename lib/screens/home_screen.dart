import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tugas_2_prakmobile/screens/detail_screen.dart'; 
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; 
  bool _isLoading = true; 
  List<dynamic> _recipes = []; 
  
  // Panggil box Hive yang sudah diinisialisasi di main.dart
  final _favoriteBox = Hive.box('favoriteBox');

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); 
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('currentUser');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?c=Chicken')); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recipes = data['meals'];
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data resep');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat memuat data')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bodyWidgets = [
      _buildHomeBody(),
      _buildFavoriteBody(), 
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFEF5E7), 
      appBar: AppBar(
        // Judul AppBar berubah dinamis sesuai tab yang aktif
        title: Text(
          _selectedIndex == 0 ? 'ResepKu' : 'Favorit Saya',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout, 
          ),
        ],
      ),
      body: bodyWidgets[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar( 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }

  // ==== WIDGET UNTUK TAB HOME ====
  Widget _buildHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Resep Chicken',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : _recipes.isEmpty
                  ? const Center(child: Text('Tidak ada resep ditemukan.'))
                  : GridView.builder( 
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 12, 
                        mainAxisSpacing: 12, 
                        childAspectRatio: 0.85, 
                      ),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
        ),
      ],
    );
  }

  // ==== WIDGET KARTU RESEP (HOME) ====
  Widget _buildRecipeCard(dynamic recipe) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias, 
      elevation: 3,
      child: InkWell(
        onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(id: recipe['idMeal']))); 
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                recipe['strMealThumb'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe['strMeal'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
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
  Widget _buildFavoriteBody() {
    // ValueListenableBuilder bertugas mendengarkan perubahan pada box Hive
    return ValueListenableBuilder(
      valueListenable: _favoriteBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada resep favorit.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // Mengambil semua kunci (ID resep) yang tersimpan
        final favoriteKeys = box.keys.toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: favoriteKeys.length,
          itemBuilder: (context, index) {
            final key = favoriteKeys[index];
            final recipe = box.get(key); // Mengambil detail data resep dari Hive
            
            return _buildFavoriteCard(key, recipe);
          },
        );
      },
    );
  }

  // ==== WIDGET KARTU RESEP FAVORIT (Dengan Tombol X) ====
  Widget _buildFavoriteCard(dynamic key, dynamic recipe) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Klik item favorit akan membuka DetailScreen sesuai ketentuan tugas
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(id: recipe['idMeal'])));
        },
        child: Stack(
          children: [
            // Konten Kartu Utama (Gambar & Teks)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    recipe['strMealThumb'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipe['strMeal'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Tombol 'X' (Hapus dari favorit) di pojok kanan atas
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  _favoriteBox.delete(key); // Menghapus data dari database lokal Hive
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resep dihapus dari favorit')),
                  );
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}