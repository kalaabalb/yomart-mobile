import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/order_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:e_commerce_flutter/utility/constants.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final snapshot = order.paymentMethodSnapshot;
    final method = snapshot?.name.isNotEmpty == true
        ? snapshot!.name
        : switch (order.paymentMethod) {
            'cbe' => context.l10n.bank_transfer,
            'telebirr' => context.l10n.telebirr,
            'cod' => context.l10n.cash_on_delivery,
            _ => order.paymentMethod ?? '—'
          };
    final proof = order.paymentProof;
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: MarketPalette.ink,
          title: Text(context.l10n.payment_details,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
      body: MarketBackdrop(
          child: SafeArea(
              child: ListView(padding: const EdgeInsets.all(20), children: [
        _section(context.l10n.payment_method, method),
        if (snapshot != null) ...[
          if (snapshot.providerName.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Provider', snapshot.providerName),
          ],
          if (snapshot.accountHolder.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Recipient', snapshot.accountHolder),
          ],
          if (snapshot.accountIdentifier.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Payment identifier', snapshot.accountIdentifier),
          ],
          if (snapshot.additionalDetails.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Details', snapshot.additionalDetails),
          ],
          if (snapshot.instructions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Instructions', snapshot.instructions),
          ],
        ],
        const SizedBox(height: 12),
        _section(context.l10n.order_status,
            localizePaymentStatus(context.l10n, order.paymentStatus),
            status: true),
        const SizedBox(height: 12),
        Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .64),
                borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.l10n.payment_proof,
                  style: const TextStyle(color: MarketPalette.muted)),
              const SizedBox(height: 12),
              if (snapshot?.requiresProof == false)
                const Text('No payment receipt was required for this method.', style: TextStyle(color: MarketPalette.muted))
              else if (proof?.available == true && order.sId != null) ...[
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: Image.network(
                          '$mainUrl/payment/proofs/${Uri.encodeComponent(order.sId!)}',
                          fit: BoxFit.cover,
                          headers: {
                            if (GetStorage().read('auth_token') is String)
                              'Authorization':
                                  'Bearer ${GetStorage().read('auth_token')}',
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text(
                                'Receipt is unavailable. Refresh your orders and try again.'),
                          ),
                        ))),
                const SizedBox(height: 10),
                Text(
                    context.l10n
                        .submitted_on(_date(context, proof?.uploadedAt)),
                    style: const TextStyle(
                        color: MarketPalette.muted, fontSize: 12)),
              ] else ...[
                Text(context.l10n.no_payment_proof,
                    style: const TextStyle(color: MarketPalette.muted)),
              ],
            ])),
      ]))),
    );
  }

  Widget _section(String title, String value, {bool status = false}) =>
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .64),
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: MarketPalette.muted)),
          const SizedBox(height: 7),
          Row(children: [
            if (status)
              const Icon(Icons.circle, size: 10, color: MarketPalette.warning),
            if (status) const SizedBox(width: 8),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: MarketPalette.ink))
          ]),
        ]),
      );

  String _date(BuildContext context, String? value) {
    if (value == null) return context.l10n.recently;
    final d = DateTime.tryParse(value);
    return d == null ? value : '${d.month}/${d.day}/${d.year}';
  }
}
