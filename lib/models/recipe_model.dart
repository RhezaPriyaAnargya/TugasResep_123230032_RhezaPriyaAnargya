class RecipeModel {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String? area;
  final String? instructions;
  final List<String> ingredients; 

  RecipeModel({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
    this.area,
    this.instructions,
    required this.ingredients,
  });

  // Factory untuk mengubah JSON dari API menjadi Objek RecipeModel
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        parsedIngredients.add('${measure ?? ''} $ingredient'.trim());
      }
    }

    return RecipeModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumb: json['strMealThumb'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      ingredients: parsedIngredients, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumb,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'ingredients': ingredients,
    };
  }
}