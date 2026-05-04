import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _recipeDetail;
  bool _isFavorite = false;
  final _favoriteBox = Hive.box('favoriteBox');

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
    _checkFavoriteStatus();
  }

  // ==========================================
  // BAGIAN 1: LOGIKA & API
  // ==========================================

  void _checkFavoriteStatus() {
    setState(() {
      _isFavorite = _favoriteBox.containsKey(widget.id);
    });
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.id}'));

      if (response.statusCode == 200) {
        setState(() {
          _recipeDetail = json.decode(response.body)['meals'][0];
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat resep');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan koneksi')),
        );
      }
    }
  }

  void _toggleFavorite() {
    if (_isFavorite) {
      _favoriteBox.delete(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari Favorit')));
    } else {
      _favoriteBox.put(widget.id, _recipeDetail);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ditambahkan ke Favorit')));
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  List<String> _getIngredients() {
    List<String> ingredients = [];
    if (_recipeDetail == null) return ingredients;

    for (int i = 1; i <= 20; i++) {
      final ingredient = _recipeDetail!['strIngredient$i'];
      final measure = _recipeDetail!['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add('${measure ?? ''} $ingredient'.trim());
      }
    }
    return ingredients;
  }

  // ===========================
  // BAGIAN 2: TAMPILAN UTAMA 
  // ===========================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_recipeDetail == null) return const Scaffold(body: Center(child: Text('Data tidak ditemukan.')));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(), // 1. Tampilkan Gambar Atas
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndChips(),    // 2. Tampilkan Judul & Kategori
                  const SizedBox(height: 24),
                  
                  _buildFavoriteButton(),   // 3. Tampilkan Tombol Favorit
                  const SizedBox(height: 32),
                  
                  _buildIngredientsList(),  // 4. Tampilkan Daftar Bahan
                  const SizedBox(height: 32),
                  
                  _buildInstructions(),     // 5. Tampilkan Cara Memasak
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================
  // BAGIAN 3: WIDGET 
  // ===================

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        Image.network(
          _recipeDetail!['strMealThumb'],
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _recipeDetail!['strMeal'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallChip(Icons.category, _recipeDetail!['strCategory']),
            const SizedBox(width: 12),
            _buildSmallChip(Icons.location_on, _recipeDetail!['strArea']),
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

  Widget _buildFavoriteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFavorite ? Colors.red[400] : Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _toggleFavorite,
        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
        label: Text(_isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = _getIngredients();
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

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cara Memasak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          _recipeDetail!['strInstructions'],
          style: const TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }
}