import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/order_details_screen/order_details_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/favorite_screen.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/order_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/cards.dart';
import '../../utility/marketplace_design.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  bool _isLoading = true;
  String? _loadError;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      await context.dataProvider.getAllOrders();
    } catch (_) {
      _loadError =
          'We couldn’t load your orders. Check your connection and try again.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Consumer2<DataProvider, UserProvider>(
            builder: (context, dataProvider, userProvider, child) {
              // Get current user
              final currentUser = userProvider.getLoginUsr();

              // Filter orders by current user
              final userOrders = dataProvider.orders.where((order) {
                return order.userID?.sId == currentUser?.sId;
              }).toList();
              final visibleOrders = userOrders.where((order) {
                final status = order.orderStatus?.toLowerCase();
                return switch (_filter) {
                  'Processing' =>
                    status == 'processing' || status == 'payment_verified',
                  'Shipped' => status == 'shipped',
                  'Delivered' => status == 'delivered',
                  _ => true,
                };
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: ['All', 'Processing', 'Shipped', 'Delivered']
                          .map(_buildFilterChip)
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: MarketPalette.blue,
                            ),
                          )
                        : _buildOrdersBody(visibleOrders),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ColoredBox(
        // Keep the header visually continuous with the page background.
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                tooltip: context.l10n.back,
                visualDensity: VisualDensity.compact,
                onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: MarketPalette.isDark(context)
                    ? Colors.white
                    : MarketPalette.navy,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  context.l10n.my_orders,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MarketPalette.isDark(context)
                        ? Colors.white
                        : MarketPalette.ink,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.favorites_tooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                ),
                icon: const Icon(Icons.favorite_border_rounded, size: 20),
                color: MarketPalette.isDark(context)
                    ? MarketPalette.homeMuted
                    : MarketPalette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final selected = _filter == filter;
    final dark = MarketPalette.isDark(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: _localizedFilter(filter),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              if (_filter == filter) return;
              // This is an in-place filter. It must never push a route.
              setState(() => _filter = filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: selected
                    ? (dark ? const Color(0xFF167BEA) : MarketPalette.navy)
                    : (dark
                        ? MarketPalette.homeSurfaceRaised
                        : const Color(0x66FFFFFF)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                _localizedFilter(filter),
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : MarketPalette.isDark(context)
                          ? MarketPalette.homeMuted
                          : MarketPalette.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedFilter(String filter) => switch (filter) {
        'All' => context.l10n.all_filter,
        'Processing' => context.l10n.order_processing,
        'Shipped' => context.l10n.order_shipped,
        _ => context.l10n.order_delivered,
      };

  Widget _buildOrdersBody(List<Order> visibleOrders) {
    if (_loadError != null || visibleOrders.isEmpty) {
      final hasError = _loadError != null;
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 54, 22, 22),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0x44FFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x55FFFFFF)),
                    ),
                    child: Icon(
                      hasError
                          ? Icons.cloud_off_outlined
                          : Icons.receipt_long_outlined,
                      size: 27,
                      color: hasError
                          ? MarketPalette.error
                          : MarketPalette.blueDeep,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    hasError
                        ? context.l10n.orders_unavailable
                        : _filter == 'All'
                            ? context.l10n.no_orders_yet
                            : context.l10n.no_orders_for_filter(
                                _localizedFilter(_filter),
                              ),
                    style: TextStyle(
                      color: MarketPalette.isDark(context)
                          ? Colors.white
                          : MarketPalette.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasError ? _loadError! : context.l10n.orders_empty_message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MarketPalette.isDark(context)
                          ? MarketPalette.homeMuted
                          : MarketPalette.muted,
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 190,
                      child: MarketPrimaryButton(
                        text: context.l10n.try_again,
                        onPressed: _loadOrders,
                        icon: Icons.refresh_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
        itemCount: visibleOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 7),
        itemBuilder: (context, index) =>
            _buildOrderCard(context, visibleOrders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final products = context.read<DataProvider>().allProducts;
    final firstItem =
        order.items?.isNotEmpty == true ? order.items!.first : null;
    final product =
        products.where((p) => p.sId == firstItem?.productID).firstOrNull ??
            Product();
    final imageUrl = product.images?.isNotEmpty == true
        ? product.images!.first.url ?? ''
        : '';
    return CustomCard(
      marketStyle: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              width: 58,
              height: 58,
              color: MarketPalette.isDark(context)
                  ? MarketPalette.homeSurfaceRaised
                  : MarketPalette.field,
              child: CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
            )),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l10n.order_number(_shortOrderId(order.sId)),
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
              '${context.l10n.placed_on(_formatDate(order.orderDate))} · Birr ${order.totalPrice?.toStringAsFixed(0) ?? '0'}',
              style: TextStyle(
                  color: MarketPalette.isDark(context)
                      ? MarketPalette.homeMuted
                      : MarketPalette.muted,
                  fontSize: 12)),
          const SizedBox(height: 5),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                  color:
                      _getStatusColor(order.orderStatus).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(localizeOrderStatus(context.l10n, order.orderStatus),
                  style: TextStyle(
                      color: _getStatusColor(order.orderStatus),
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
        ])),
        Icon(Icons.chevron_right_rounded,
            color: MarketPalette.isDark(context)
                ? MarketPalette.homeMuted
                : MarketPalette.muted,
            size: 22),
      ]),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return MarketPalette.success;
      case 'shipped':
      case 'processing':
      case 'payment_verified':
        return MarketPalette.blue;
      case 'payment_pending':
        return MarketPalette.warning;
      case 'pending':
        return MarketPalette.muted;
      case 'cancelled':
        return MarketPalette.error;
      default:
        return MarketPalette.muted;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _shortOrderId(String? orderId) {
    if (orderId == null || orderId.isEmpty) return 'N/A';
    return orderId.length > 6
        ? orderId.substring(orderId.length - 6).toUpperCase()
        : orderId.toUpperCase();
  }
}
