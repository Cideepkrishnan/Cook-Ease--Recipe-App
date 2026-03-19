import 'package:cook_ease/model/ResRecipe.dart';
import 'package:cook_ease/service/apiservice.dart';
import 'package:cook_ease/view/detailscreen.dart';
import 'package:cook_ease/view/favourites.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final Apiservice apiservice = Apiservice();
  final TextEditingController _searchController = TextEditingController();
  final List<Recipes> favourites = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  late Future<List<Recipes>> _recipesFuture;

  static const String _favKey = 'favourite_ids';

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    _recipesFuture = _loadRecipes();
  }

  Future<List<Recipes>> _loadRecipes() async {
    final recipes = await apiservice.fetchrecipes();
    await _loadFavourites(recipes);
    return recipes;
  }

  void _retryLoad() {
    setState(() {
      _recipesFuture = _loadRecipes();
    });
  }

  Future<void> _loadFavourites(List<Recipes> allRecipes) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_favKey) ?? [];
    if (savedIds.isEmpty) return;

    // mounted check before setState
    if (!mounted) return;
    setState(() {
      for (final recipe in allRecipes) {
        if (savedIds.contains(recipe.id?.toString()) &&
            !favourites.contains(recipe)) {
          favourites.add(recipe);
        }
      }
    });
  }

  Future<void> _saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = favourites
        .where((r) => r.id != null)
        .map((r) => r.id.toString())
        .toList();
    await prefs.setStringList(_favKey, ids);
  }

  void _toggleFavourite(Recipes recipe) {
    if (!mounted) return;
    setState(() {
      if (favourites.contains(recipe)) {
        favourites.remove(recipe);
        _showSnack(
            '${recipe.name} removed from favourites',
            Icons.heart_broken_outlined);
      } else {
        favourites.add(recipe);
        _showSnack(
            '${recipe.name} added to favourites', Icons.favorite);
      }
    });
    _saveFavourites();
  }

  void _showSnack(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE07B2A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Recipes> _filterRecipes(List<Recipes> recipes) {
    return recipes.where((r) {
      final matchesQuery = _searchQuery.isEmpty ||
          (r.name
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCategory = _selectedCategory == 'All' ||
          (r.mealType != null &&
              r.mealType!.any((m) =>
                  m.toLowerCase() ==
                  _selectedCategory.toLowerCase()));
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'What do you want to cook today?',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _dismissKeyboard();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FavouritesScreen(
                                  favourites: favourites,
                                  onToggleFavourite: _toggleFavourite,
                                ),
                              ),
                            ).then((_) {
                              _dismissKeyboard();
                              if (mounted) setState(() {});
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF000000)
                                      .withOpacity(0.08),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Icon(
                              favourites.isNotEmpty
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color(0xFFE07B2A),
                              size: 22,
                            ),
                          ),
                        ),
                        if (favourites.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE07B2A),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${favourites.length}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Search Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: TextField(
                    autofocus: false,
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _dismissKeyboard(),
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      if (v.isEmpty) _dismissKeyboard();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBBBBBB), fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFBBBBBB), size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _dismissKeyboard();
                              },
                              child: const Icon(Icons.close,
                                  color: Color(0xFFBBBBBB), size: 18),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Category Chips ──
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE07B2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE07B2A)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF555555),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Recipe Grid ──
              Expanded(
                child: FutureBuilder<List<Recipes>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const _ShimmerGrid();
                    }

                    // Error
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off,
                                color: Color(0xFFE07B2A), size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No internet connection',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Check your connection and try again',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _retryLoad,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE07B2A),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE07B2A)
                                          .withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Retry',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Data loaded
                    final filtered = _filterRecipes(snapshot.data!);

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No recipes found 🍽️',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        final isFav = favourites.contains(recipe);
                        return _RecipeCard(
                          recipe: recipe,
                          onTap: () {
                            _dismissKeyboard();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  recipe: recipe,
                                  isFavourite: isFav,
                                  onToggleFavourite: () =>
                                      _toggleFavourite(recipe),
                                ),
                              ),
                            ).then((_) {
                              _dismissKeyboard();
                              if (mounted) setState(() {});
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shimmer Grid ──
class _ShimmerGrid extends StatefulWidget {
  const _ShimmerGrid();

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: 6,
          itemBuilder: (_, __) =>
              _ShimmerCard(shimmerValue: _animation.value),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double shimmerValue;
  const _ShimmerCard({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: _shimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 100, height: 12, borderRadius: 6),
                const SizedBox(height: 8),
                _shimmerBox(width: 70, height: 10, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFF5F5F5),
            Color(0xFFEEEEEE),
          ],
          transform: _SlidingGradientTransform(shimmerValue),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// ── Recipe Card ──
class _RecipeCard extends StatelessWidget {
  final Recipes recipe;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: recipe.image != null
                    ? Image.network(
                        recipe.image!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF0E6D3),
                          child: const Center(
                            child: Icon(Icons.restaurant,
                                color: Color(0xFFE07B2A), size: 40),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF0E6D3),
                        child: const Center(
                          child: Icon(Icons.restaurant,
                              color: Color(0xFFE07B2A), size: 40),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFE07B2A), size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.rating ?? '--'}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(' · ',
                          style:
                              TextStyle(color: Color(0xFFCCCCCC))),
                      const Icon(Icons.schedule,
                          color: Color(0xFF888888), size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.cookTimeMinutes ?? '--'} min',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}