import 'package:flutter/material.dart';
import '../data/recipes_data.dart';
import '../models/recipe.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Recipe Book",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.blueAccent,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/ocean.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    label: const Text('View Favourites'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FavoritesScreen(
                            favoriteRecipes: sampleRecipes
                                .where((r) => r.isFavorite)
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sampleRecipes.length,
                  itemBuilder: (context, index) {
                    final Recipe recipe = sampleRecipes[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.85),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            recipe.imagePath,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.redAccent,
                                  ),
                                ),
                          ),
                        ),
                        title: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
