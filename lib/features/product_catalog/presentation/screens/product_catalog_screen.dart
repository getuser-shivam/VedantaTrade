import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_grid.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/product_detail_sheet.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductCatalogProvider>().loadMoreProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Product Catalog',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_view), text: 'Products'),
                  Tab(icon: Icon(Icons.category), text: 'Categories'),
                  Tab(icon: Icon(Icons.star), text: 'Featured'),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<ProductCatalogProvider>(
                builder: (context, provider, child) {
                  return SearchFilterBar(
                    searchController: _searchController,
                    searchQuery: provider.searchQuery,
                    selectedCategory: provider.filterByCategory,
                    sortBy: provider.sortBy,
                    showInStockOnly: provider.showInStockOnly,
                    showExpiringSoonOnly: provider.showExpiringSoonOnly,
                    categories: provider.categories,
                    onSearchChanged: provider.searchProducts,
                    onCategoryChanged: provider.filterByCategory,
                    onSortChanged: provider.sortByProducts,
                    onInStockToggle: provider.toggleInStockFilter,
                    onExpiringSoonToggle: provider.toggleExpiringSoonFilter,
                    onClearFilters: provider.clearFilters,
                  );
                },
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(),
            _buildCategoriesTab(),
            _buildFeaturedTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildProductsTab() {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or search terms',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: provider.clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Statistics row
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Products',
                      provider.totalProducts.toString(),
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'In Stock',
                      provider.products
                          .where((p) => p.stockQuantity > 0)
                          .length
                          .toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Low Stock',
                      provider.lowStockProducts.length.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            
            // Products grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: ProductGrid(
                  products: provider.products,
                  onProductTap: _showProductDetails,
                  onProductEdit: _showEditProductDialog,
                  onProductDelete: _confirmDeleteProduct,
                  showActions: true,
                ),
              ),
            ),
            
            // Loading more indicator
            if (provider.isLoadingMore)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return CategoryGrid(
          categories: provider.categories,
          onCategoryTap: (category) {
            provider.filterByCategory(category.name);
            _tabController.animateTo(0);
          },
        );
      },
    );
  }

  Widget _buildFeaturedTab() {
    return Consumer<ProductCatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            // Featured products header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Featured Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.featuredProducts.length} products',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Featured products grid
            Expanded(
              child: ProductGrid(
                products: provider.featuredProducts,
                onProductTap: _showProductDetails,
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    context.read<ProductCatalogProvider>().selectProduct(product);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product),
    );
  }

  void _showAddProductDialog() {
    // TODO: Implement add product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add product feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    // TODO: Implement edit product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${product.name} feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete ${product.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductCatalogProvider>().deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
