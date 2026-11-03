import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/tracking_screen/tracking_screen.dart';
import 'package:e_commerce_flutter/screen/order_details_screen/payment_details_screen.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/order_localization.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final total = order.totalPrice ?? order.orderTotal?.total ?? 0;
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MarketPalette.ink,
        title: Text(context.l10n.order_number(_shortId(order.sId)),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: MarketBackdrop(
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.l10n.placed_on(_date(order.orderDate)),
                    style: const TextStyle(color: MarketPalette.muted)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                children: [
                  _timeline(context),
                  const SizedBox(height: 12),
                  ...?order.items?.map((item) => _item(context, item)),
                  const SizedBox(height: 5),
                  _line(context.l10n.total, 'Birr ${total.toStringAsFixed(0)}',
                      bold: true),
                  const SizedBox(height: 14),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 5)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PaymentDetailsScreen(order: order))),
                    child: Row(children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 18, color: MarketPalette.blueDeep),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              '${_paymentName(context, order.paymentMethod)} · ${localizePaymentStatus(context.l10n, order.paymentStatus)}',
                              style:
                                  const TextStyle(color: MarketPalette.ink))),
                      const Icon(Icons.chevron_right,
                          color: MarketPalette.muted),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  _line(
                      context.l10n.destination_information,
                      [
                        order.shippingAddress?.formattedAddress,
                        order.shippingAddress?.phone
                      ]
                              .where(
                                  (value) => value != null && value.isNotEmpty)
                              .join(' · ')
                              .isEmpty
                          ? '—'
                          : [
                              order.shippingAddress?.formattedAddress,
                              order.shippingAddress?.phone
                            ]
                              .where(
                                  (value) => value != null && value.isNotEmpty)
                              .join(' · ')),
                  if (order.collectionPoint?.isComplete == true)
                    _line(context.l10n.collection_point,
                        '${order.collectionPoint!.name ?? ''} · ${order.collectionPoint!.formattedAddress}'),
                  if (order.orderStatus == 'ready_for_collection' &&
                      order.collectionPoint?.isComplete != true)
                    _line(context.l10n.collection_point,
                        context.l10n.collection_point_not_agreed),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: _button(context, context.l10n.track_order, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrackingScreen(url: order.trackingUrl, order: order),
                    ));
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _timeline(BuildContext context) {
    final stages = orderTrackingLabels(context.l10n, order.orderStatus);
    final status = order.orderStatus?.toLowerCase() ?? 'pending';
    final active = orderTrackingActiveIndex(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(
            stages.length,
            (index) => Expanded(
                  child: Column(children: [
                    Row(children: [
                      if (index > 0)
                        Expanded(
                            child: Container(
                                height: 2,
                                color: index <= active
                                    ? MarketPalette.blue
                                    : MarketPalette.border)),
                      Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= active
                                ? MarketPalette.blue
                                : Colors.white,
                            border: Border.all(
                                color: index <= active
                                    ? MarketPalette.blue
                                    : MarketPalette.muted,
                                width: 2)),
                        child: index == active
                            ? const Icon(Icons.circle,
                                size: 7, color: Colors.white)
                            : null,
                      ),
                      if (index < stages.length - 1)
                        Expanded(
                            child: Container(
                                height: 2,
                                color: index < active
                                    ? MarketPalette.blue
                                    : MarketPalette.border)),
                    ]),
                    const SizedBox(height: 7),
                    Text(stages[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: index <= active
                                ? MarketPalette.ink
                                : MarketPalette.muted)),
                  ]),
                )),
      ),
    );
  }

  Widget _item(BuildContext context, Items item) {
    final dataProvider = context.read<DataProvider>();
    final products = dataProvider.allProducts;
    final product =
        products.where((p) => p.sId == item.productID).firstOrNull ?? Product();
    final image = product.images?.isNotEmpty == true
        ? product.images!.first.url ?? ''
        : '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          var selectedProduct = product;
          if (selectedProduct.sId == null && item.productID != null) {
            try {
              await dataProvider.getAllProduct();
              selectedProduct = dataProvider.allProducts
                      .where((p) => p.sId == item.productID)
                      .firstOrNull ??
                  Product();
            } catch (_) {
              // Show the same actionable message below if the product is still
              // unavailable after trying to load the catalog.
            }
          }
          if (!context.mounted) return;
          if (selectedProduct.sId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.product_details_unavailable)),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(selectedProduct),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .65),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                    width: 62,
                    height: 62,
                    child: CustomNetworkImage(
                        imageUrl: image, fit: BoxFit.cover))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.productName ?? context.l10n.product,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (item.variant?.isNotEmpty == true)
                    Text(item.variant!,
                        style: const TextStyle(
                            color: MarketPalette.muted, fontSize: 12)),
                  Text(context.l10n.quantity('${item.quantity ?? 1}'),
                      style: const TextStyle(
                          color: MarketPalette.muted, fontSize: 12)),
                ])),
            Text(
                'Birr ${((item.price ?? 0) * (item.quantity ?? 1)).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  color: bold ? MarketPalette.ink : MarketPalette.muted,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: MarketPalette.ink,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
        ]),
      );

  Widget _button(BuildContext context, String label, VoidCallback onTap) =>
      SizedBox(
        height: 48,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: MarketPalette.primaryGradient,
              borderRadius: BorderRadius.circular(18)),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700))))),
        ),
      );

  String _shortId(String? id) => id == null
      ? 'N/A'
      : id.length > 8
          ? id.substring(id.length - 8).toUpperCase()
          : id.toUpperCase();
  String _date(String? value) {
    if (value == null) return '—';
    final d = DateTime.tryParse(value);
    return d == null ? value : '${_month(d.month)} ${d.day}, ${d.year}';
  }

  String _month(int m) => const [
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
      ][m - 1];
  String _paymentName(BuildContext context, String? m) => switch (m) {
        'cbe' => context.l10n.bank_transfer,
        'telebirr' => context.l10n.telebirr,
        'cod' => context.l10n.cash_on_delivery,
        _ => m ?? '—'
      };
}
