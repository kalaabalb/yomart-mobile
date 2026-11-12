import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/models/store_settings.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/location_picker_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/widget/custom_text_field.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:provider/provider.dart';

class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({super.key});

  @override
  State<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends State<CheckoutFlowScreen> {
  int _step = 0;
  List<String> _titles(BuildContext context) => [
    context.l10n.destination_information,
    context.l10n.review_order,
    context.l10n.payment_method,
    context.l10n.payment_proof,
  ];

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  void _continue(
    CartProvider cart,
    List<StorePaymentMethod> configuredMethods,
  ) {
    if (_step == 0) {
      final form = cart.buyNowFormKey.currentState;
      if (form == null || !form.validate()) return;
      form.save();
    }
    if (_step == 2) {
      final selected = configuredMethods.where(
        (method) => method.enabled && method.code == cart.selectedPaymentOption,
      );
      if (selected.isEmpty) return;
      if (!selected.first.requiresProof) {
        cart.addOrder(context);
        return;
      }
      setState(() => _step++);
      return;
    }
    if (_step == 3) {
      final selected = configuredMethods.where(
        (method) => method.enabled && method.code == cart.selectedPaymentOption,
      );
      if (selected.isEmpty ||
          (selected.first.requiresProof && !cart.isPaymentProofReady))
        return;
      cart.addOrder(context);
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Consumer2<DataProvider, CartProvider>(
            builder: (context, data, cart, _) => Column(
              children: [
                _header(cart),
                Expanded(
                  child: Form(
                    key: cart.buyNowFormKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: switch (_step) {
                          0 => _deliveryStep(cart),
                          1 => _reviewStep(cart, data.hasLoadedStoreSettings),
                          2 => _paymentStep(
                            cart,
                            data.storeSettings.paymentMethods,
                          ),
                          _ => _proofStep(
                            cart,
                            data.storeSettings.paymentMethods,
                          ),
                        },
                      ),
                    ),
                  ),
                ),
                _footer(cart, data.storeSettings.paymentMethods),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 6, 18, 5),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
                color: MarketPalette.ink,
              ),
              Expanded(
                child: Text(
                  _titles(context)[_step],
                  style: const TextStyle(
                    color: MarketPalette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final active = index <= (_step == 3 ? 2 : _step);
              return Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? MarketPalette.blue : Colors.white,
                  border: Border.all(
                    color: active ? MarketPalette.blue : MarketPalette.border,
                  ),
                  boxShadow: active
                      ? const [
                          BoxShadow(color: Color(0x443A8DF0), blurRadius: 9),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : MarketPalette.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _deliveryStep(CartProvider cart) {
    final user = context.read<UserProvider>().getLoginUsr();
    return Column(
      key: const ValueKey('delivery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.destination_information,
          style: const TextStyle(
            color: MarketPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        _fieldLabel(context.l10n.full_name),
        _readOnlyField(user?.name ?? context.l10n.account_name),
        const SizedBox(height: 12),
        _checkoutField(
          label: context.l10n.phone_number,
          controller: cart.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.destination_city,
                style: const TextStyle(
                  color: MarketPalette.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
              ),
              icon: const Icon(Icons.location_on_outlined, size: 17),
              label: Text(context.l10n.choose_on_map),
              style: TextButton.styleFrom(
                foregroundColor: MarketPalette.blueDeep,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        _checkoutField(
          label: context.l10n.area_landmark_optional,
          controller: cart.streetController,
          required: false,
        ),
        const SizedBox(height: 8),
        _checkoutField(
          label: context.l10n.destination_city,
          controller: cart.cityController,
        ),
        if (cart.latitude != null && cart.longitude != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 14,
                color: MarketPalette.success,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  context.l10n.map_location_selected(
                    '${cart.latitude!.toStringAsFixed(4)}, ${cart.longitude!.toStringAsFixed(4)}',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: MarketPalette.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          context.l10n.collection_explanation,
          style: const TextStyle(color: MarketPalette.muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _checkoutField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) => CustomTextField(
    controller: controller,
    labelText: label,
    inputType: keyboardType,
    marketStyle: true,
    validator: (value) => required && (value == null || value.trim().isEmpty)
        ? context.l10n.please_enter_field(label)
        : null,
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      label,
      style: const TextStyle(
        color: MarketPalette.muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _readOnlyField(String value) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: MarketPalette.border),
    ),
    child: Text(value, style: const TextStyle(color: MarketPalette.ink)),
  );

  Widget _reviewStep(CartProvider cart, bool hasLoadedStoreSettings) {
    final subtotal = cart.getCartSubTotal();
    final products = context.read<DataProvider>().allProducts;
    return Column(
      key: const ValueKey('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.review_order,
          style: const TextStyle(
            color: MarketPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...cart.myCartItems.map((item) => _reviewItem(item, products)),
        const SizedBox(height: 12),
        _summaryRow(
          context.l10n.total,
          hasLoadedStoreSettings
              ? 'Birr ${subtotal.toStringAsFixed(0)}'
              : context.l10n.not_available,
          strong: true,
        ),
        if (!hasLoadedStoreSettings) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.read<DataProvider>().getStoreSettings(),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: Text(context.l10n.try_again),
          ),
        ],
      ],
    );
  }

  Widget _reviewItem(CartModel item, List products) {
    final catalogProduct = products.where((p) => p.sId == item.productId);
    final image =
        item.productImages?.firstOrNull ??
        (catalogProduct.isEmpty
            ? ''
            : catalogProduct.first.images?.firstOrNull?.url ?? '');
    final variant = item.variants.isEmpty
        ? ''
        : [
            item.variants.first.color,
            item.variants.first.size,
          ].where((value) => value?.isNotEmpty == true).join(' · ');
    // Older saved carts may lack variant pricing; the API confirms the price at checkout.
    final unitPrice = item.variants.isEmpty ? null : item.variants.first.price;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomNetworkImage(
              imageUrl: image,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              placeholderColor: const Color(0xFFEAF1F8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MarketPalette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    variant,
                    style: const TextStyle(
                      color: MarketPalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  unitPrice == null
                      ? 'Price confirmed at checkout'
                      : 'Birr ${unitPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: MarketPalette.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '×${item.quantity}',
            style: const TextStyle(
              color: MarketPalette.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9EB2C8)),
        ],
      ),
    );
  }

  Widget _paymentStep(
    CartProvider cart,
    List<StorePaymentMethod> settingsMethods,
  ) {
    final methods = settingsMethods.where((method) => method.enabled).toList();
    final selectedMethod = methods
        .where((method) => method.code == cart.selectedPaymentOption)
        .firstOrNull;
    if (methods.isNotEmpty &&
        !methods.any((method) => method.code == cart.selectedPaymentOption)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !methods.any(
              (method) => method.code == cart.selectedPaymentOption,
            )) {
          cart.setPaymentOption(methods.first.code);
        }
      });
    }
    return Column(
      key: const ValueKey('payment'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.payment_method,
          style: const TextStyle(
            color: MarketPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (methods.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.check_connection_retry),
              TextButton.icon(
                onPressed: () =>
                    context.read<DataProvider>().getStoreSettings(),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(context.l10n.try_again),
              ),
            ],
          )
        else
          ...methods.map(
            (method) => _paymentOption(
              cart,
              method.code,
              method.title,
              method.subtitle,
              switch (method.category) {
                'bank_transfer' => Icons.account_balance_rounded,
                'mobile_wallet' => Icons.phone_android_rounded,
                'cash_collection' => Icons.payments_outlined,
                _ => Icons.account_balance_wallet_outlined,
              },
            ),
          ),
        if (selectedMethod != null) _paymentMethodDetails(selectedMethod),
      ],
    );
  }

  Widget _paymentOption(
    CartProvider cart,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final selected = cart.selectedPaymentOption == value;
    return GestureDetector(
      onTap: () => cart.setPaymentOption(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? MarketPalette.blue : MarketPalette.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MarketPalette.blueDeep, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: MarketPalette.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: MarketPalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? MarketPalette.blue : MarketPalette.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodDetails(StorePaymentMethod method) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: MarketPalette.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (method.providerName.isNotEmpty)
          _paymentDetail('Provider', method.providerName),
        if (method.accountHolder.isNotEmpty)
          _paymentDetail('Recipient', method.accountHolder),
        if (method.accountIdentifier.isNotEmpty)
          _paymentDetail('Payment identifier', method.accountIdentifier),
        if (method.additionalDetails.isNotEmpty)
          _paymentDetail('Details', method.additionalDetails),
        if (method.instructions.isNotEmpty) ...[
          if (method.providerName.isNotEmpty ||
              method.accountIdentifier.isNotEmpty)
            const SizedBox(height: 6),
          Text(
            method.instructions,
            style: const TextStyle(color: MarketPalette.muted, height: 1.4),
          ),
        ],
        Text(
          method.requiresProof
              ? 'A payment receipt is required.'
              : 'No payment receipt is required.',
          style: const TextStyle(color: MarketPalette.muted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _paymentDetail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      '$label: $value',
      style: const TextStyle(
        color: MarketPalette.ink,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _proofStep(
    CartProvider cart,
    List<StorePaymentMethod> settingsMethods,
  ) {
    final selectedMethod = settingsMethods
        .where((method) => method.code == cart.selectedPaymentOption)
        .firstOrNull;
    final paymentInstructions = selectedMethod?.instructions;
    final hasProof =
        cart.paymentProofImage != null ||
        (cart.paymentProofRecordId?.isNotEmpty ?? false);
    return Column(
      key: const ValueKey('proof'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMethod?.providerName.isNotEmpty == true)
          _paymentDetail('Provider', selectedMethod!.providerName),
        if (selectedMethod?.accountHolder.isNotEmpty == true)
          _paymentDetail('Recipient', selectedMethod!.accountHolder),
        if (selectedMethod?.accountIdentifier.isNotEmpty == true)
          _paymentDetail(
            'Payment identifier',
            selectedMethod!.accountIdentifier,
          ),
        if (selectedMethod?.additionalDetails.isNotEmpty == true)
          _paymentDetail('Details', selectedMethod!.additionalDetails),
        if (paymentInstructions?.isNotEmpty == true) ...[
          Text(
            paymentInstructions!,
            style: const TextStyle(color: MarketPalette.muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          context.l10n.payment_proof,
          style: const TextStyle(
            color: MarketPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.upload_receipt_instruction,
          style: const TextStyle(color: MarketPalette.muted, height: 1.35),
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: cart.isUploadingPaymentProof
              ? null
              : cart.pickPaymentProofImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBDD5F1), width: 1.2),
            ),
            child: hasProof
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: cart.buildProofPreview(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: MarketPalette.blue,
                        size: 39,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cart.isUploadingPaymentProof
                            ? context.l10n.uploading
                            : context.l10n.tap_to_upload,
                        style: const TextStyle(
                          color: MarketPalette.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.image_format_limit,
                        style: const TextStyle(
                          color: MarketPalette.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasProof) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: cart.removePaymentProofImage,
            icon: const Icon(Icons.delete_outline),
            label: Text(context.l10n.choose_different_image),
          ),
        ],
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool strong = false}) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          color: strong ? MarketPalette.ink : MarketPalette.muted,
          fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: MarketPalette.ink,
          fontSize: strong ? 16 : 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _footer(
    CartProvider cart,
    List<StorePaymentMethod> configuredMethods,
  ) {
    final label = switch (_step) {
      0 => context.l10n.continue_to_review,
      1 => context.l10n.continue_to_payment,
      2 =>
        configuredMethods
                    .where(
                      (method) =>
                          method.enabled &&
                          method.code == cart.selectedPaymentOption,
                    )
                    .firstOrNull
                    ?.requiresProof ==
                true
            ? context.l10n.continue_to_payment_proof
            : context.l10n.place_order,
      _ => context.l10n.place_order,
    };
    final selectedMethod = configuredMethods
        .where(
          (method) =>
              method.enabled && method.code == cart.selectedPaymentOption,
        )
        .firstOrNull;
    final proofNeeded = _step == 3 && selectedMethod?.requiresProof == true;
    final paymentUnavailable =
        _step == 2 &&
        !configuredMethods.any(
          (method) =>
              method.enabled && method.code == cart.selectedPaymentOption,
        );
    final disabled =
        cart.isProcessingPayment ||
        cart.isUploadingPaymentProof ||
        paymentUnavailable ||
        (proofNeeded && !cart.isPaymentProofReady);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xDDF4F8FD),
        border: Border(top: BorderSide(color: Color(0xFFDCE8F5))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: disabled
                ? null
                : () => _continue(cart, configuredMethods),
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketPalette.blueDeep,
              disabledBackgroundColor: MarketPalette.blue.withValues(alpha: .5),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: cart.isProcessingPayment || cart.isUploadingPaymentProof
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}
