import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/snake_provider.dart';
import '../models/snake_model.dart';

class SnakeDetailScreen extends StatelessWidget {
  final Snake snake;

  const SnakeDetailScreen({super.key, required this.snake});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          snake.name,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<SnakeProvider>(
            builder: (context, snakeProvider, child) {
              final isFav = snakeProvider.isFavorite(snake.name);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () {
                  snakeProvider.toggleFavorite(snake);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFav
                          ? 'Removed from favorites'
                          : 'Added to favorites'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              snake.imagePath,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 80),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: snake.venomColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: snake.venomColor, width: 2),
                      ),
                      child: Text(
                        snake.venomLevel,
                        style: TextStyle(
                          color: snake.venomColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildDetailSection(
                    context,
                    icon: Icons.visibility,
                    title: 'Identification (හඳුනාගැනීම)',
                    content: snake.identification,
                    iconColor: Colors.blue,
                  ),
                  const Divider(height: 40),
                  _buildDetailSection(
                    context,
                    icon: Icons.medical_services,
                    title: 'Venom Effect (විෂෙහි බලපෑම)',
                    content: snake.venomEffect,
                    iconColor: Colors.red,
                  ),
                  const Divider(height: 40),
                  _buildDetailSection(
                    context,
                    icon: Icons.access_time,
                    title: 'Active Time (ක්‍රියාකාරී කාලය)',
                    content: snake.activeTime,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
