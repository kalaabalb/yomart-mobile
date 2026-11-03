import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/order_localization.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.url, this.order});
  final String? url;
  final Order? order;

  @override
  Widget build(BuildContext context) {
    final steps = orderTrackingLabels(context.l10n, order?.orderStatus);
    final status = order?.orderStatus?.toLowerCase() ?? 'pending';
    final current = orderTrackingActiveIndex(status);
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: MarketPalette.ink,
          title: Text(context.l10n.track_order,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
      body: MarketBackdrop(
          child: SafeArea(
              child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(context.l10n.order_number(_short(order?.sId)),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MarketPalette.ink)),
          const SizedBox(height: 6),
          Text(context.l10n.placed_on(_date(order?.orderDate)),
              style: const TextStyle(color: MarketPalette.muted)),
          const SizedBox(height: 25),
          ...List.generate(
              steps.length,
              (i) =>
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                        width: 34,
                        child: Column(children: [
                          Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i <= current
                                      ? MarketPalette.blue
                                      : Colors.white,
                                  border: Border.all(
                                      color: i <= current
                                          ? MarketPalette.blue
                                          : MarketPalette.muted,
                                      width: 2)),
                              child: i <= current
                                  ? const Icon(Icons.check,
                                      size: 13, color: Colors.white)
                                  : null),
                          if (i < steps.length - 1)
                            Container(
                                width: 2,
                                height: 48,
                                color: i < current
                                    ? MarketPalette.blue
                                    : MarketPalette.border),
                        ])),
                    Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(steps[i],
                            style: TextStyle(
                                fontWeight: i == current
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i <= current
                                    ? MarketPalette.ink
                                    : MarketPalette.muted))),
                  ])),
          const SizedBox(height: 18),
          if (url?.isNotEmpty == true)
            Text(context.l10n.tracking_reference(url!),
                style: const TextStyle(color: MarketPalette.muted)),
          if (current < 0)
            Text(context.l10n.tracking_confirmation_pending,
                style: const TextStyle(color: MarketPalette.muted)),
        ],
      ))),
    );
  }

  String _short(String? id) => id == null
      ? 'N/A'
      : id.length > 8
          ? id.substring(id.length - 8).toUpperCase()
          : id.toUpperCase();
  String _date(String? value) {
    if (value == null) return '—';
    final d = DateTime.tryParse(value);
    return d == null ? value : '${d.day}/${d.month}/${d.year}';
  }
}
