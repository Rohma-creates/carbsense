import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem item;

  const FoodDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeroImage()),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name + category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.foodItem,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6C63FF,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C63FF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (item.foodDetail.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.foodDetail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Nutrition cards
                  _buildInfoGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    final url = item.imageUrl.trim();

    if (url.isEmpty) {
      return _heroPlaceholder();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 260,
      errorBuilder: (_, __, ___) => _heroPlaceholder(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _heroPlaceholder();
      },
    );
  }
  /* {
      return Container(
        color: const Color(0xFFF0F1F5),
        child: const Center(
          child: Icon(Icons.restaurant, size: 80, color: Color(0xFFCCCDD5)),
        ),
      );
    }

    return Image.network(
      item.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder:
          (_, __, ___) => Container(
            color: const Color(0xFFF0F1F5),
            child: const Center(
              child: Icon(Icons.restaurant, size: 80, color: Color(0xFFCCCDD5)),
            ),
          ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF0F1F5),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
              strokeWidth: 2.5,
            ),
          ),
        );
      },
    );*/

  Widget _heroPlaceholder() {
    return Container(
      color: const Color(0xFFF0F1F5),
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: Color(0xFFCCCDD5)),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final tiles = [
      _InfoTile(
        icon: Icons.straighten,
        label: 'Serving Size',
        value: item.servingSize.isNotEmpty ? item.servingSize : '—',
        color: const Color(0xFF43B89C),
      ),
      _InfoTile(
        icon: Icons.grain,
        label: 'Carbohydrates',
        value: item.carbohydrates.isNotEmpty ? item.carbohydrates : '—',
        color: const Color(0xFF6C63FF),
      ),
      _InfoTile(
        icon: Icons.vaccines_outlined,
        label: 'Insulin',
        value: item.insulin.isNotEmpty ? item.insulin : '—',
        color: const Color(0xFFFF6584),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Info',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 14),
        ...tiles.map(
          (tile) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildInfoRow(tile),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(_InfoTile tile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tile.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tile.icon, color: tile.color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            tile.label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              tile.value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
