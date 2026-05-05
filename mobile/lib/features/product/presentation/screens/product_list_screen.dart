import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_cache_manager.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/presentation/providers/product_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final bool isFlashSale;
  final bool isFeatured;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.isFlashSale = false,
    this.isFeatured = false,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _currentSort;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null) {
        // Category mode: search with category filter
        ref.read(productSearchNotifierProvider.notifier).search(
              category: widget.categoryId,
              sort: _currentSort,
            );
      } else if (!widget.isFlashSale && !widget.isFeatured) {
        // General search mode: load all products initially
        ref.read(productSearchNotifierProvider.notifier).search(
              sort: _currentSort,
            );
      }
    });
  }

  String get title {
    if (widget.isFlashSale) return 'Flash Sale';
    if (widget.isFeatured) return 'Featured Products';
    if (widget.categoryName != null) return widget.categoryName!;
    return 'Search';
  }

  bool get isSearchMode =>
      !widget.isFlashSale && !widget.isFeatured && widget.categoryId == null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      ref.invalidate(productSearchNotifierProvider);
    } else {
      ref
          .read(productSearchNotifierProvider.notifier)
          .search(query: query, sort: _currentSort);
    }
  }

  void _onSort(String? sort) {
    setState(() {
      _currentSort = sort;
    });
    final query = _searchController.text;

    // If we have a category filter, maintain it when sorting
    if (widget.categoryId != null) {
      ref.read(productSearchNotifierProvider.notifier).search(
            category: widget.categoryId,
            sort: sort,
          );
    } else {
      ref
          .read(productSearchNotifierProvider.notifier)
          .search(query: query.isEmpty ? null : query, sort: sort);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_currentSort != null)
                    TextButton(
                      onPressed: () {
                        _onSort(null);
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildSortOption('Price: Low to High', 'price-asc'),
            _buildSortOption('Price: High to Low', 'price-desc'),
            _buildSortOption('Newest First', 'newest'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _currentSort == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        _onSort(value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchMode
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (value) {
                  setState(() {});
                  _onSearch(value);
                },
              )
            : Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    if (widget.isFlashSale) {
      return _buildFromAsyncValue<FlashSaleState>(
        context,
        ref,
        ref.watch(flashSaleNotifierProvider),
        (data) => data.products,
        null,
      );
    }
    if (widget.isFeatured) {
      return _buildFromAsyncValue<List<ProductEntity>>(
        context,
        ref,
        ref.watch(featuredProductsNotifierProvider),
        (data) => data,
        null,
      );
    }
    return _buildSearchList(context, ref);
  }

  Widget _buildFromAsyncValue<T>(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<T> state,
    List<ProductEntity> Function(T) extractor,
    VoidCallback? loadMore,
  ) {
    return state.when(
      loading: () => _buildShimmer(context),
      error: (error, _) => _buildError(context, ref, error),
      data: (data) {
        final products = extractor(data);
        if (products.isEmpty) return _buildEmpty(context);
        return _buildGrid(context, products, loadMore);
      },
    );
  }

  Widget _buildSearchList(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(productSearchNotifierProvider);
    return searchState.when(
      loading: () => _buildShimmer(context),
      error: (error, _) => _buildSearchError(context, ref, error),
      data: (products) {
        if (products.isEmpty) return _buildEmpty(context);
        return _buildGrid(context, products, () {
          ref.read(productSearchNotifierProvider.notifier).loadMore();
        });
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (widget.isFlashSale) {
                  ref.invalidate(flashSaleNotifierProvider);
                } else if (widget.isFeatured) {
                  ref.invalidate(featuredProductsNotifierProvider);
                } else if (widget.categoryId != null) {
                  // Retry category search
                  ref.read(productSearchNotifierProvider.notifier).search(
                        category: widget.categoryId,
                        sort: _currentSort,
                      );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(productSearchNotifierProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<ProductEntity> products,
    VoidCallback? loadMore,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (loadMore != null &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
          loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(
            product: products[index],
            onTap: () => context.push('/home/products/${products[index].id}'),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const _ProductCard({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: product.images.first.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          cacheManager: AppCacheManager.instance,
                          placeholder: (_, __) => Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
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
