import 'package:cook_ease/model/ResRecipe.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final Recipes recipe;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const DetailScreen({
    super.key,
    required this.recipe,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late bool _isFavourite;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _isFavourite = widget.isFavourite;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFavouriteTap() {
    final wasAlreadyFavourite = _isFavourite;
    widget.onToggleFavourite();
    setState(() => _isFavourite = !_isFavourite);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                wasAlreadyFavourite
                    ? Icons.heart_broken_outlined
                    : Icons.favorite,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(wasAlreadyFavourite
                  ? 'Removed from favourites'
                  : 'Added to favourites'),
            ],
          ),
          backgroundColor: const Color(0xFFE07B2A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Build list of content items for the selected tab
  List<Widget> _ingredientItems(Recipes recipe) {
    final ingredients = recipe.ingredients ?? [];
    if (ingredients.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text('No ingredients listed.',
                style: TextStyle(color: Color(0xFF888888))),
          ),
        )
      ];
    }
    return List.generate(ingredients.length, (i) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE07B2A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(ingredients[i],
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF333333))),
              ),
            ],
          ),
        ),
        if (i < ingredients.length - 1)
          const Divider(height: 1),
      ],
    ));
  }

  List<Widget> _instructionItems(Recipes recipe) {
    final instructions = recipe.instructions ?? [];
    if (instructions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text('No instructions listed.',
                style: TextStyle(color: Color(0xFF888888))),
          ),
        )
      ];
    }
    return List.generate(instructions.length, (i) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFE07B2A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${i + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(instructions[i],
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF444444),
                    height: 1.5)),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: Stack(
        children: [
          // ── Scrollable body ──
          CustomScrollView(
            slivers: [
              // ── Hero Image as SliverAppBar ──
              SliverAppBar(
                expandedHeight: 280,
                pinned: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      recipe.image != null
                          ? Image.network(
                              recipe.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF0E6D3),
                                child: const Center(
                                  child: Icon(Icons.restaurant,
                                      color: Color(0xFFE07B2A),
                                      size: 60),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF0E6D3),
                              child: const Center(
                                child: Icon(Icons.restaurant,
                                    color: Color(0xFFE07B2A), size: 60),
                              ),
                            ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF6F0),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe name
                      Text(
                        recipe.name ?? 'Unknown Recipe',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.star,
                            iconColor: const Color(0xFFE07B2A),
                            label: '${recipe.rating ?? '--'}',
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            icon: Icons.schedule,
                            iconColor: const Color(0xFF888888),
                            label:
                                '${recipe.cookTimeMinutes ?? '--'} min',
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            icon: Icons.people_outline,
                            iconColor: const Color(0xFF888888),
                            label: '${recipe.servings ?? '--'} Servings',
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Tab bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFFE07B2A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF555555),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                          unselectedLabelStyle:
                              const TextStyle(fontWeight: FontWeight.w500),
                          onTap: (_) => setState(() {}),
                          tabs: const [
                            Tab(text: 'Ingredients'),
                            Tab(text: 'Instructions'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Tab content as sliver (no TabBarView) ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _tabController.index == 0
                        ? _ingredientItems(recipe)
                        : _instructionItems(recipe),
                  ),
                ),
              ),
            ],
          ),

          // ── Floating back + favourite buttons ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _CircleButton(
                    icon: _isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor: _isFavourite
                        ? const Color(0xFFE07B2A)
                        : Colors.white,
                    onTap: _handleFavouriteTap,
                  ),
                ],
              ),
            ),
          ),

          // ── Pinned bottom Save button ──
        
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleButton(
      {required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1), blurRadius: 8)
          ],
        ),
        child: Icon(icon,
            color: iconColor ?? const Color(0xFF1A1A1A), size: 18),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatChip(
      {required this.icon,
      required this.iconColor,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}