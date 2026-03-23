import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/neutralitical_brand.dart';
import '../../data/services/product_catalog_service.dart';
import '../../data/services/product_media_library_service.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_media.dart';
import '../controllers/product_catalog_controller.dart';
import '../widgets/product_catalog_card.dart';
import '../widgets/product_media_image.dart';
import '../widgets/product_video_controller_factory.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({
    super.key,
    required this.productCatalogService,
    required this.productMediaLibraryService,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.onSignOut,
  });

  final ProductCatalogService productCatalogService;
  final ProductMediaLibraryService productMediaLibraryService;
  final String currentUserName;
  final String currentUserEmail;
  final Future<void> Function() onSignOut;

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  late final ProductCatalogController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = ProductCatalogController(
      productCatalogService: widget.productCatalogService,
      productMediaLibraryService: widget.productMediaLibraryService,
    )..loadProducts();
    _searchController = TextEditingController()..addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearch)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    setState(() {});
    _controller.setQuery(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.setQuery('');
  }

  Future<void> _handleUploadMedia(Product product) async {
    await _controller.addMedia(product);
    _showControllerMessage();
  }

  Future<void> _handleRemoveMedia(Product product, ProductMedia media) async {
    await _controller.removeUploadedMedia(product, media);
    _showControllerMessage();
  }

  void _showControllerMessage() {
    final message = _controller.takeStatusMessage();
    if (!mounted || message == null || message.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(
        product: product,
        controller: _controller,
        onUploadRequested: _handleUploadMedia,
        onRemoveRequested: _handleRemoveMedia,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: NeutraliticalBrand.shellGradient,
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _controller.loadProducts,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _CatalogHero(
                          controller: _controller,
                          currentUserName: widget.currentUserName,
                          currentUserEmail: widget.currentUserEmail,
                          onSignOut: widget.onSignOut,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: _CatalogControls(
                          searchController: _searchController,
                          onClearSearch: _clearSearch,
                          controller: _controller,
                        ),
                      ),
                    ),
                    if (_controller.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _CatalogStatusView(
                          icon: Icons.inventory_2_outlined,
                          title: 'Loading registered products',
                          message:
                              'Preparing the latest catalog entries for display.',
                          showProgress: true,
                        ),
                      )
                    else if (_controller.errorMessage != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _CatalogStatusView(
                          icon: Icons.cloud_off,
                          title: 'Catalog unavailable',
                          message: _controller.errorMessage!,
                          actionLabel: 'Retry',
                          onActionPressed: _controller.loadProducts,
                        ),
                      )
                    else if (_controller.products.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _CatalogStatusView(
                          icon: Icons.inventory_outlined,
                          title: 'No registered products yet',
                          message:
                              'Add product records to the catalog asset to display them here.',
                        ),
                      )
                    else ...[
                      if (!_controller.hasActiveFilters &&
                          _controller.featuredProducts.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
                            child: _SectionHeading(
                              title: 'Featured products',
                              subtitle:
                                  'Priority formulations, curated media, and flagship products ready to spotlight.',
                            ),
                          ),
                        ),
                      if (!_controller.hasActiveFilters &&
                          _controller.featuredProducts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 380,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                              scrollDirection: Axis.horizontal,
                              itemCount: _controller.featuredProducts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final product =
                                    _controller.featuredProducts[index];
                                final media = _controller.mediaFor(product);
                                return FeaturedProductCard(
                                  product: product,
                                  primaryMedia: _controller.primaryVisualFor(
                                    product,
                                  ),
                                  mediaCount: media.length,
                                  onTap: () => _showProductDetails(product),
                                );
                              },
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _SectionHeading(
                            title: _controller.selectedCategory == 'All'
                                ? 'All registered products'
                                : _controller.selectedCategory,
                            subtitle:
                                '${_controller.visibleProducts.length} product${_controller.visibleProducts.length == 1 ? '' : 's'} matched your current view.',
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _ProductCatalogGrid(
                          products: _controller.visibleProducts,
                          controller: _controller,
                          onProductTap: _showProductDetails,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    required this.controller,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.onSignOut,
  });

  final ProductCatalogController controller;
  final String currentUserName;
  final String currentUserEmail;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: NeutraliticalBrand.heroGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  NeutraliticalBrand.markAsset,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1E8).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Registered product catalog',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: onSignOut,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Display every registered Neutralitical product with curated media, generated visuals, and upload-ready product stories.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse the catalog, open a product to review dosage and packaging, then attach official photos or short videos directly from the device when shared assets are missing.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE8DDD0),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStat(
                label: 'Registered',
                value: controller.products.length.toString(),
              ),
              _HeroStat(
                label: 'With media',
                value: controller.productsWithMediaCount.toString(),
              ),
              _HeroStat(
                label: 'Uploads',
                value: controller.uploadedMediaCount.toString(),
              ),
              _HeroStat(
                label: 'Categories',
                value:
                    (controller.categories.length > 1
                            ? controller.categories.length - 1
                            : 0)
                        .toString(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      currentUserName.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signed in as $currentUserName',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUserEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE8DDD0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogControls extends StatelessWidget {
  const _CatalogControls({
    required this.searchController,
    required this.onClearSearch,
    required this.controller,
  });

  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final ProductCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE6DEC9)),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText:
                  'Search registered products, ingredients, categories, or dosage',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Browse by category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF212625),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final selected = category == controller.selectedCategory;

              return FilterChip(
                selected: selected,
                label: Text(category),
                showCheckmark: false,
                onSelected: (_) => controller.setSelectedCategory(category),
                selectedColor: const Color(0xFF18392B),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF18392B)
                      : const Color(0xFFE2D9C8),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF534D45),
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCatalogGrid extends StatelessWidget {
  const _ProductCatalogGrid({
    required this.products,
    required this.controller,
    required this.onProductTap,
  });

  final List<Product> products;
  final ProductCatalogController controller;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: _EmptyFilterState(),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1120
        ? 3
        : width >= 760
        ? 2
        : 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 1 ? 1.02 : 0.72,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final media = controller.mediaFor(product);
          return ProductCatalogCard(
            product: product,
            primaryMedia: controller.primaryVisualFor(product),
            mediaCount: media.length,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  const _ProductDetailSheet({
    required this.product,
    required this.controller,
    required this.onUploadRequested,
    required this.onRemoveRequested,
  });

  final Product product;
  final ProductCatalogController controller;
  final Future<void> Function(Product product) onUploadRequested;
  final Future<void> Function(Product product, ProductMedia media)
  onRemoveRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final media = controller.mediaFor(product);
        final isBusy = controller.busyProductId == product.id;

        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.58,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1C7B6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D2321),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        product.priceLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C5B45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailBadge(label: product.category),
                      _DetailBadge(label: product.form),
                      if (product.dosage != null)
                        _DetailBadge(label: product.dosage!),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _MediaLibrarySection(
                    product: product,
                    media: media,
                    supportsUploads: controller.supportsUploads,
                    isBusy: isBusy,
                    onUploadRequested: () => onUploadRequested(product),
                    onRemoveRequested: (item) =>
                        onRemoveRequested(product, item),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5A605D),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Ingredients',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...product.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF1C5B45),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF4C5450),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (product.packaging != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Packaging',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.packaging!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4C5450),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MediaLibrarySection extends StatelessWidget {
  const _MediaLibrarySection({
    required this.product,
    required this.media,
    required this.supportsUploads,
    required this.isBusy,
    required this.onUploadRequested,
    required this.onRemoveRequested,
  });

  final Product product;
  final List<ProductMedia> media;
  final bool supportsUploads;
  final bool isBusy;
  final Future<void> Function() onUploadRequested;
  final ValueChanged<ProductMedia> onRemoveRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadedItems = media.where((item) => item.isUploaded).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product media',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    media.isEmpty
                        ? 'No official images were matched from the shared folder yet, so a generated cover is being used.'
                        : 'Curated Drive references and uploaded files attached to this product.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF62645F),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: isBusy ? null : onUploadRequested,
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_rounded),
              label: const Text('Upload images or videos'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!supportsUploads)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EADD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE3D8C6)),
            ),
            child: Text(
              'Local uploads are available in Android and desktop builds. Open this product there to attach packaging shots or explainer videos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5E584F),
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 236,
          child: media.isEmpty
              ? _GeneratedMediaFallback(product: product)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: media.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = media[index];
                    return _MediaTile(
                      product: product,
                      media: item,
                      onRemoveRequested: item.isUploaded
                          ? () => onRemoveRequested(item)
                          : null,
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MediaPill(
              icon: Icons.cloud_outlined,
              label:
                  '${media.where((item) => !item.isUploaded).length} Drive reference${media.where((item) => !item.isUploaded).length == 1 ? '' : 's'}',
            ),
            _MediaPill(
              icon: Icons.upload_file_outlined,
              label:
                  '$uploadedItems uploaded item${uploadedItems == 1 ? '' : 's'}',
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.product,
    required this.media,
    this.onRemoveRequested,
  });

  final Product product;
  final ProductMedia media;
  final VoidCallback? onRemoveRequested;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 258,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (media.isVideo) {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) => _VideoPreviewSheet(media: media),
              );
              return;
            }

            showDialog<void>(
              context: context,
              builder: (context) =>
                  _ImagePreviewDialog(product: product, media: media),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8DEC9)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MediaPreview(product: product, media: media),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          media.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (onRemoveRequested != null)
                        IconButton(
                          onPressed: onRemoveRequested,
                          tooltip: 'Remove uploaded media',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF7EFE3),
                            foregroundColor: const Color(0xFF5F574B),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        )
                      else
                        Icon(
                          media.isVideo
                              ? Icons.play_circle_outline_rounded
                              : Icons.open_in_full_rounded,
                          color: const Color(0xFF6A665F),
                        ),
                    ],
                  ),
                  if (media.caption != null && media.caption!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        media.caption!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF69645E),
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.product, required this.media});

  final Product product;
  final ProductMedia media;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    if (media.isVideo) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C2230), Color(0xFF364354)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                media.isUploaded
                    ? 'Uploaded video for ${product.name}'
                    : 'Reference video for ${product.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: buildProductMediaImage(
            uri: media.uri,
            fit: BoxFit.cover,
            borderRadius: borderRadius,
            fallback: _GeneratedMediaFallback(product: product),
          ),
        ),
        Positioned(top: 10, left: 10, child: _MediaSourceBadge(media: media)),
      ],
    );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  const _ImagePreviewDialog({required this.product, required this.media});

  final Product product;
  final ProductMedia media;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      media.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (media.caption != null && media.caption!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    media.caption!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF68645E),
                    ),
                  ),
                ),
              Expanded(
                child: buildProductMediaImage(
                  uri: media.uri,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(20),
                  fallback: _GeneratedMediaFallback(product: product),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPreviewSheet extends StatefulWidget {
  const _VideoPreviewSheet({required this.media});

  final ProductMedia media;

  @override
  State<_VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<_VideoPreviewSheet> {
  VideoPlayerController? _videoController;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = await createProductVideoController(widget.media.uri);
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isLoading = false;
      });
      await controller.setLooping(true);
      await controller.play();
    } on UnsupportedError catch (error) {
      setState(() {
        _errorMessage =
            error.message?.toString() ?? 'Video playback is unavailable.';
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to preview this video right now.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.media.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EEE3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF625C54),
                  ),
                ),
              )
            else if (_videoController != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedMediaFallback extends StatelessWidget {
  const _GeneratedMediaFallback({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 170;
        final veryCompact = constraints.maxHeight < 110;

        return Container(
          width: 258,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E50), Color(0xFFE4BA79)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              veryCompact
                  ? 10
                  : compact
                  ? 14
                  : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 12,
                    vertical: veryCompact
                        ? 4
                        : compact
                        ? 6
                        : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Generated cover',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: veryCompact
                          ? 11
                          : compact
                          ? 12
                          : null,
                    ),
                  ),
                ),
                if (!veryCompact) const Spacer(),
                if (veryCompact) const SizedBox(height: 6),
                Text(
                  product.name,
                  maxLines: veryCompact
                      ? 1
                      : compact
                      ? 2
                      : 3,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.headlineSmall)
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreviewChip(label: product.form),
                      if (product.dosage != null)
                        _PreviewChip(label: product.dosage!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaSourceBadge extends StatelessWidget {
  const _MediaSourceBadge({required this.media});

  final ProductMedia media;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        media.isUploaded ? 'Uploaded' : 'Drive reference',
        style: const TextStyle(
          color: Color(0xFF3E3932),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MediaPill extends StatelessWidget {
  const _MediaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5DAC7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF46544C)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4F4A44),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFE8DDD0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2522),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5A605D),
          ),
        ),
      ],
    );
  }
}

class _CatalogStatusView extends StatelessWidget {
  const _CatalogStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.showProgress = false,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showProgress;
  final String? actionLabel;
  final Future<void> Function()? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showProgress)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircularProgressIndicator(),
                )
              else
                Icon(icon, size: 64, color: const Color(0xFFB5AB9C)),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF66615A),
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onActionPressed,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6DEC9)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No products match your current filters.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a broader category or search term to bring registered products back into view.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF66615A)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9DC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF4F4A44),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
