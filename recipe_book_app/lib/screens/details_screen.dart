import 'package:flutter/material.dart';
import '../models/recipe.dart';

class DetailsScreen extends StatefulWidget {
  final Recipe recipe;
  const DetailsScreen({super.key, required this.recipe});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              widget.recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                widget.recipe.isFavorite = !widget.recipe.isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.recipe.imagePath,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Ingredients",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ...widget.recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("• $ingredient"),
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Instructions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(widget.recipe.instructions),
            ),
          ],
        ),
      ),
    );
  }
}
