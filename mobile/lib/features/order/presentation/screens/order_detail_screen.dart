import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_cache_manager.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';

/// Standalone OrderDetailScreen with its own AppBar
/// Use this when navigating from order list
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailNotifierProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, ref, error),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _OrderDetailContent(order: order, orderId: orderId);
        },
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
              onPressed: () =>
                  ref.invalidate(orderDetailNotifierProvider(orderId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content-only version for TrackOrderScreen
/// Does not include Scaffold or AppBar
class OrderDetailContent extends ConsumerWidget {
  final String orderId;

  const OrderDetailContent({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailNotifierProvider(orderId));

    return orderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, ref, error),
      data: (order) {
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }
        return _OrderDetailContent(order: order, orderId: orderId);
      },
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
              onPressed: () =>
                  ref.invalidate(orderDetailNotifierProvider(orderId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailContent extends ConsumerWidget {
  final OrderEntity order;
  final String orderId;

  const _OrderDetailContent({required this.order, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderHeaderCard(order: order),
          const SizedBox(height: 16),
          _StatusTimelineCard(order: order),
          const SizedBox(height: 16),
          _OrderItemsCard(orderItems: order.orderItems),
          const SizedBox(height: 16),
          _OrderSummaryCard(order: order),
          const SizedBox(height: 16),
          _ShippingAddressCard(shippingAddress: order.shippingAddress),
          const SizedBox(height: 16),
          _PaymentInfoCard(paymentInfo: order.paymentInfo),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.pending ||
              order.status == OrderStatus.processing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context, ref),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.isEmpty
                  ? 'No reason provided'
                  : reasonController.text;

              Navigator.pop(ctx);

              final failure = await ref
                  .read(orderDetailNotifierProvider(orderId).notifier)
                  .cancelOrder(reason);

              if (failure != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled')),
                );
              }
            },
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderHeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status, colorScheme)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status, colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Order Date',
              DateFormat('MMM dd, yyyy').format(order.createdAt),
            ),
            if (order.paidAt != null)
              _buildInfoRow(
                context,
                'Paid At',
                DateFormat('MMM dd, yyyy HH:mm').format(order.paidAt!),
              ),
            if (order.deliveredAt != null)
              _buildInfoRow(
                context,
                'Delivered At',
                DateFormat('MMM dd, yyyy').format(order.deliveredAt!),
              ),
            if (order.cancellationReason != null)
              _buildInfoRow(
                context,
                'Cancellation Reason',
                order.cancellationReason!,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status, ColorScheme colorScheme) {
    switch (status) {
      case OrderStatus.pending:
        return colorScheme.secondary;
      case OrderStatus.processing:
        return colorScheme.primary;
      case OrderStatus.shipped:
        return colorScheme.tertiary;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return colorScheme.error;
      case OrderStatus.refunded:
        return colorScheme.error;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.name[0].toUpperCase() + status.name.substring(1);
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimelineCard extends StatelessWidget {
  final OrderEntity order;

  const _StatusTimelineCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _getStatusSteps();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return _TimelineStep(
                title: step.title,
                date: step.date,
                isCompleted: step.isCompleted,
                isFirst: index == 0,
                isLast: index == steps.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_StatusStep> _getStatusSteps() {
    final steps = <_StatusStep>[
      _StatusStep(
        title: 'Order Placed',
        date: DateFormat('MMM dd, HH:mm').format(order.createdAt),
        isCompleted: true,
      ),
    ];

    final isProcessing = order.status.index >= OrderStatus.processing.index;
    steps.add(_StatusStep(
      title: 'Processing',
      date: isProcessing ? 'In progress' : 'Pending',
      isCompleted: isProcessing,
    ));

    final isShipped = order.status.index >= OrderStatus.shipped.index;
    steps.add(_StatusStep(
      title: 'Shipped',
      date: isShipped ? 'In transit' : 'Pending',
      isCompleted: isShipped,
    ));

    if (order.status == OrderStatus.cancelled) {
      steps.add(_StatusStep(
        title: 'Cancelled',
        date: DateFormat('MMM dd, HH:mm').format(order.updatedAt),
        isCompleted: true,
      ));
    } else {
      steps.add(_StatusStep(
        title: 'Delivered',
        date: order.deliveredAt != null
            ? DateFormat('MMM dd, HH:mm').format(order.deliveredAt!)
            : 'Pending',
        isCompleted: order.status == OrderStatus.delivered,
      ));
    }

    return steps;
  }
}

class _StatusStep {
  final String title;
  final String date;
  final bool isCompleted;

  _StatusStep({
    required this.title,
    required this.date,
    required this.isCompleted,
  });
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String date;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              if (!isFirst)
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        isCompleted ? colorScheme.primary : colorScheme.outline,
                  ),
                ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted ? colorScheme.primary : colorScheme.outline,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        isCompleted ? colorScheme.primary : colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  final List<OrderItemEntity> orderItems;

  const _OrderItemsCard({required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${orderItems.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...orderItems.map((item) => _OrderItemTile(item: item)),
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItemEntity item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.image,
                      fit: BoxFit.cover,
                      cacheManager: AppCacheManager.instance,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (item.variant != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variant!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(context, 'Subtotal',
                '\$${order.itemsPrice.toStringAsFixed(2)}'),
            _buildSummaryRow(context, 'Shipping',
                '\$${order.shippingPrice.toStringAsFixed(2)}'),
            _buildSummaryRow(
                context, 'Tax', '\$${order.taxPrice.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              context,
              'Total',
              '\$${order.totalPrice.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ShippingAddressCard extends StatelessWidget {
  final ShippingAddressEntity shippingAddress;

  const _ShippingAddressCard({required this.shippingAddress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              shippingAddress.fullName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              shippingAddress.phone,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _buildAddress(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAddress() {
    final parts = <String>[
      shippingAddress.address,
      shippingAddress.city,
      if (shippingAddress.state.isNotEmpty) shippingAddress.state,
      shippingAddress.postalCode,
      if (shippingAddress.country.isNotEmpty) shippingAddress.country,
    ];
    return parts.join(', ');
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final PaymentInfoEntity paymentInfo;

  const _PaymentInfoCard({required this.paymentInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getPaymentIcon(),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (paymentInfo.cardLast4 != null)
                      Text(
                        'Card ending in ${paymentInfo.cardLast4}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: paymentInfo.status == 'success'
                        ? Colors.green.withValues(alpha: 0.1)
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paymentInfo.status == 'success' ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color: paymentInfo.status == 'success'
                          ? Colors.green
                          : colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon() {
    switch (paymentInfo.method.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'cod':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodText() {
    switch (paymentInfo.method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return paymentInfo.method;
    }
  }
}
