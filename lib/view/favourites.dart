import 'package:cook_ease/model/ResRecipe.dart';
import 'package:cook_ease/view/detailscreen.dart';
import 'package:flutter/material.dart';

class FavouritesScreen extends StatefulWidget {
  final List<Recipes> favourites;
  final void Function(Recipes) onToggleFavourite;

  const FavouritesScreen({
    super.key,
    required this.favourites,
    required this.onToggleFavourite,
  });

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  void _remove(Recipes recipe) {
    widget.onToggleFavourite(recipe);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.favourites;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Your Favourites ❤️',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            title: const Text('Clear all favourites?'),
                            content: const Text(
                                'This will remove all saved recipes from your favourites.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Color(0xFF888888))),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.favourites.clear();
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.delete_sweep,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 8),
                                          Text('All favourites cleared'),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFE07B2A),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text('Clear',
                                    style: TextStyle(
                                        color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Count subtitle
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  '${items.length} saved recipe${items.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF888888)),
                ),
              ),

            // ── Content ──
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recipe = items[index];
                        return _FavouriteCard(
                          recipe: recipe,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                recipe: recipe,
                                isFavourite: true,
                                onToggleFavourite: () {
                                  _remove(recipe);
                                },
                              ),
                            ),
                          ).then((_) => setState(() {})),
                          onRemove: () => _remove(recipe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('❤️', style: TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No favourites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart on any recipe\nto save it here!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Favourite Card ──
class _FavouriteCard extends StatelessWidget {
  final Recipes recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavouriteCard({
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: recipe.image != null
                    ? Image.network(
                        recipe.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF0E6D3),
                          child: const Icon(Icons.restaurant,
                              color: Color(0xFFE07B2A)),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF0E6D3),
                        child: const Icon(Icons.restaurant,
                            color: Color(0xFFE07B2A)),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFE07B2A), size: 13),
                      const SizedBox(width: 4),
                      Text('${recipe.rating ?? '--'}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF555555))),
                      const Text(' · ',
                          style:
                              TextStyle(color: Color(0xFFCCCCCC))),
                      const Icon(Icons.schedule,
                          color: Color(0xFF888888), size: 13),
                      const SizedBox(width: 4),
                      Text('${recipe.cookTimeMinutes ?? '--'} min',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF555555))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Meal type tags
                  if (recipe.mealType != null &&
                      recipe.mealType!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: recipe.mealType!
                          .take(2)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E6),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFE07B2A),
                                        fontWeight:
                                            FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),

            // Remove heart button
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite,
                    color: Color(0xFFE07B2A), size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}