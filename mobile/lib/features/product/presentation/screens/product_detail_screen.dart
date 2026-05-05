import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/failures.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../review/domain/entities/review_entity.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productState =
        ref.watch(productDetailNotifierProvider(widget.productId));
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final isInWishlist = wishlistState.valueOrNull?.any(
          (p) => p.id == widget.productId,
        ) ??
        false;

    return Scaffold(
      body: productState.when(
        loading: () => _buildLoading(context),
        error: (error, st) => _buildError(context, error),
        data: (product) {
          if (product == null) {
            return _buildError(context, 'Product not found');
          }
          return _buildContent(context, product, isInWishlist);
        },
      ),
      bottomNavigationBar: productState.whenOrNull(
        data: (product) =>
            product != null ? _buildBottomBar(context, product) : null,
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _buildBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surface,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 24, width: 200, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 16, width: 150, color: Colors.white),
                  const SizedBox(height: 24),
                  Container(
                      height: 100, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref
                  .invalidate(productDetailNotifierProvider(widget.productId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ProductEntity product, bool isInWishlist) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _buildBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildProductImage(product, colorScheme),
                // Gradient overlay for status bar visibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).padding.top + 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (product.isOnSale && product.discountPercentage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (product.isOnSale) const Spacer(),
                    _buildFavoriteButton(isInWishlist),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => _shareProduct(product),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (product.numReviews > 0)
                  Row(
                    children: [
                      Icon(Icons.star, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        product.ratings.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.numReviews} reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                    ),
                    if (product.comparePrice != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '\$${product.comparePrice!.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock: ${product.stock} available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: product.stock > 0 ? Colors.green : Colors.red,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (product.specifications.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...product.specifications.map((spec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${spec.key}: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              spec.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 24),
                _buildReviewsSection(context, product),
                const SizedBox(height: 24),
                Text(
                  'Category: ${product.category.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductEntity product) {
    return Consumer(
      builder: (context, ref, child) {
        final reviewsAsync =
            ref.watch(productReviewsNotifierProvider(product.id));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => _showAllReviewsDialog(context, ref, product),
                  child: Text(product.numReviews > 0
                      ? 'See all (${product.numReviews})'
                      : 'See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            reviewsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) {
                final errorMessage = error is Failure
                    ? error.message
                    : (error is Exception
                        ? error.toString().replaceAll('Exception: ', '')
                        : 'Failed to load reviews');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(
                            productReviewsNotifierProvider(product.id)),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              data: (reviews) {
                if (reviews.isEmpty) {
                  return _buildEmptyReviews(context, ref, product);
                }
                return Column(
                  children: [
                    ...reviews
                        .take(3)
                        .map((review) => _ReviewCard(review: review)),
                    if (reviews.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '+ ${reviews.length - 3} more reviews',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildWriteReviewButton(context, ref, product),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductImage(ProductEntity product, ColorScheme colorScheme) {
    if (product.images.isEmpty) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image,
            size: 100,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.images.first.url,
      fit: BoxFit.cover,
      cacheManager: AppCacheManager.instance,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image,
            size: 100,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ProductEntity product) {
    final colorScheme = Theme.of(context).colorScheme;
    final canAddToCart = product.stock > 0 && _quantity <= product.stock;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                  ),
                  Text(
                    '$_quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    canAddToCart ? () => _addToCart(context, product) : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  product.stock > 0
                      ? 'Add - \$${(product.price * _quantity).toStringAsFixed(2)}'
                      : 'Out of Stock',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, ProductEntity product) async {
    final failure = await ref.read(cartNotifierProvider.notifier).addToCart(
          productId: product.id,
          quantity: _quantity,
        );

    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity item(s) to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _quantity = 1);
    }
  }

  Widget _buildFavoriteButton(bool isInWishlist) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: isInWishlist ? colorScheme.error : null,
      ),
      onPressed: () => _toggleWishlist(isInWishlist),
    );
  }

  Future<void> _toggleWishlist(bool isInWishlist) async {
    if (isInWishlist) {
      try {
        await ref
            .read(wishlistNotifierProvider.notifier)
            .removeFromWishlist(widget.productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from wishlist')),
          );
        }
      } on Failure catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove from wishlist'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      try {
        await ref
            .read(wishlistNotifierProvider.notifier)
            .addToWishlist(widget.productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to wishlist')),
          );
        }
      } on Failure catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add to wishlist'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareProduct(ProductEntity product) {
    final productUrl = 'https://westore.app/products/${product.slug}';
    final message =
        '🛒 Check out ${product.name} - \$${product.price.toStringAsFixed(2)}\n\n$productUrl';

    Share.share(
      message,
      subject: product.name,
    );
  }

  Widget _buildEmptyReviews(
      BuildContext context, WidgetRef ref, ProductEntity product) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts about this product',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            if (user != null)
              FilledButton.icon(
                onPressed: () => _showWriteReviewDialog(context, ref, product),
                icon: const Icon(Icons.edit),
                label: const Text('Write a Review'),
              )
            else
              FilledButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Login to Review'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteReviewButton(
      BuildContext context, WidgetRef ref, ProductEntity product) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return OutlinedButton.icon(
        onPressed: () => context.push('/login'),
        icon: const Icon(Icons.login),
        label: const Text('Login to Write a Review'),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showWriteReviewDialog(context, ref, product),
      icon: const Icon(Icons.edit),
      label: const Text('Write a Review'),
    );
  }

  Future<void> _showAllReviewsDialog(
      BuildContext context, WidgetRef ref, ProductEntity product) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, child) {
              final reviewsAsync =
                  ref.watch(productReviewsNotifierProvider(product.id));

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Reviews'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          _showWriteReviewDialog(context, ref, product),
                      child: const Text('Write a Review'),
                    ),
                  ],
                ),
                body: reviewsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text('Failed to load reviews'),
                        TextButton(
                          onPressed: () => ref.invalidate(
                              productReviewsNotifierProvider(product.id)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return _buildEmptyReviews(context, ref, product);
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return _ReviewCard(review: reviews[index]);
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showWriteReviewDialog(
      BuildContext context, WidgetRef ref, ProductEntity product) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => _WriteReviewDialog(
        product: product,
        onSubmit: (rating, title, comment) async {
          return await ref
              .read(productReviewsNotifierProvider(product.id).notifier)
              .createReview(
                product.id,
                rating: rating,
                title: title,
                comment: comment,
              );
        },
      ),
    );
  }
}

/// Separate stateful widget for the write review dialog
class _WriteReviewDialog extends StatefulWidget {
  final ProductEntity product;
  final Future<AsyncValue<void>> Function(
      int rating, String title, String comment) onSubmit;

  const _WriteReviewDialog({
    required this.product,
    required this.onSubmit,
  });

  @override
  State<_WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<_WriteReviewDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final comment = _commentController.text.trim();

    if (title.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.onSubmit(_rating, title, comment);

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    _closeDialog();

    // Show result (no setState here, dialog is already closed)
    result.when(
      data: (_) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      },
      error: (err, _) {
        final message =
            err is Failure ? err.message : 'Failed to submit review';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colorScheme.error,
          ),
        );
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Write a Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this product',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber[600],
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Summarize your experience',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Review',
                hintText: 'What did you like or dislike?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _closeDialog,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: review.user.avatar != null &&
                          review.user.avatar!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: review.user.avatar!,
                            fit: BoxFit.cover,
                            cacheManager: AppCacheManager.instance,
                            placeholder: (context, url) => Icon(
                              Icons.person,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    review.user.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber[600],
                  );
                }),
                const SizedBox(width: 8),
                if (review.isVerifiedPurchase)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Verified',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (review.title.isNotEmpty)
              Text(
                review.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            if (review.comment.isNotEmpty) ...[
              if (review.title.isNotEmpty) const SizedBox(height: 4),
              Text(
                review.comment,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
