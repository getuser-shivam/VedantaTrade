import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';

class CategoryGrid extends StatelessWidget {
  final List<ProductCategory> categories;
  final Function(ProductCategory)? onCategoryTap;
  final int crossAxisCount;
  final double childAspectRatio;

  const CategoryGrid({
    Key? key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: () => onCategoryTap?.call(category),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback? onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: category.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: category.iconUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            _getCategoryIcon(category.name),
                            size: 30,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(category.name),
                        size: 30,
                        color: Colors.blue.shade700,
                      ),
              ),
              
              const SizedBox(height: 12),
              
              // Category Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Product Count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.productCount} products',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'analgesics':
        return Icons.healing;
      case 'antibiotics':
        return Icons.medication;
      case 'gastrointestinal':
        return Icons.stomach;
      case 'respiratory':
        return Icons.lungs;
      case 'antidiabetic':
        return Icons.monitor_heart;
      case 'cardiovascular':
        return Icons.favorite;
      case 'dermatological':
        return Icons.face;
      case 'vitamins':
        return Icons.energy_savings_leaf;
      case 'vaccines':
        return Icons.vaccines;
      case 'oncology':
        return Icons.biotech;
      default:
        return Icons.medication;
    }
  }
}

class CategoryList extends StatelessWidget {
  final List<ProductCategory> categories;
  final Function(ProductCategory)? onCategoryTap;

  const CategoryList({
    Key? key,
    required this.categories,
    this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryListItem(
          category: category,
          onTap: () => onCategoryTap?.call(category),
        );
      },
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback? onTap;

  const CategoryListItem({
    Key? key,
    required this.category,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: category.iconUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    imageUrl: category.iconUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      _getCategoryIcon(category.name),
                      size: 25,
                      color: Colors.blue.shade700,
                    ),
                  ),
                )
              : Icon(
                  _getCategoryIcon(category.name),
                  size: 25,
                  color: Colors.blue.shade700,
                ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          category.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${category.productCount}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            Text(
              'products',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'analgesics':
        return Icons.healing;
      case 'antibiotics':
        return Icons.medication;
      case 'gastrointestinal':
        return Icons.stomach;
      case 'respiratory':
        return Icons.lungs;
      case 'antidiabetic':
        return Icons.monitor_heart;
      case 'cardiovascular':
        return Icons.favorite;
      case 'dermatological':
        return Icons.face;
      case 'vitamins':
        return Icons.energy_savings_leaf;
      case 'vaccines':
        return Icons.vaccines;
      case 'oncology':
        return Icons.biotech;
      default:
        return Icons.medication;
    }
  }
}
