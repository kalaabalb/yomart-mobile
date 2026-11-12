import 'dart:io';
import 'dart:convert';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/order_confirmation_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../login_screen/provider/user_provider.dart';
import '../../../core/data/data_provider.dart';
import '../../profile_screen/provider/profile_provider.dart';
import '../../../services/http_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utility/order_attempt.dart';
import '../../../models/api_response.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';

class CartProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final box = GetStorage();
  final FlutterCart flutterCart = FlutterCart();
  List<CartModel> myCartItems = [];

  // Use shared storage keys for address synchronization with ProfileProvider
  static const String _savedAddressKey = 'savedAddress';

  final GlobalKey<FormState> buyNowFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool isExpanded = false;

  // GPS coordinates from map picker
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  String selectedPaymentOption = '';

  File? _paymentProofImage;
  File? get paymentProofImage => _paymentProofImage;
  bool _isUploadingPaymentProof = false;
  bool get isUploadingPaymentProof => _isUploadingPaymentProof;
  String? _paymentProofRecordId;
  String? get paymentProofRecordId => _paymentProofRecordId;

  bool _showPaymentInstructions = false;
  bool get showPaymentInstructions => _showPaymentInstructions;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  CartProvider() {
    getCartItems();
    retrieveSavedAddress();
  }

  void getCartItems() {
    try {
      myCartItems = List<CartModel>.from(flutterCart.cartItemsList);

      notifyListeners();
    } catch (e) {
      myCartItems = [];
      notifyListeners();
    }
  }

  void updateUI() => notifyListeners();

  void addToCart({
    required String productId,
    required String productName,
    required double price,
    required List<String> productImages,
    List<ProductVariant>? variants,
    int quantity = 1,
  }) {
    try {
      final cartVariants =
          variants ?? [ProductVariant(price: price, color: null, size: null)];

      bool itemExists = myCartItems.any(
        (item) =>
            item.productId == productId &&
            _areVariantsEqual(item.variants, cartVariants),
      );

      if (itemExists) {
        var existingItem = myCartItems.firstWhere(
          (item) =>
              item.productId == productId &&
              _areVariantsEqual(item.variants, cartVariants),
        );

        flutterCart.updateQuantity(
          productId,
          cartVariants,
          existingItem.quantity + 1,
        );
      } else {
        CartModel newItem = CartModel(
          productId: productId,
          productName: productName,
          productDetails: productName,
          productImages: productImages,
          variants: cartVariants,
          quantity: quantity,
        );

        flutterCart.addToCart(cartModel: newItem);
      }

      getCartItems();
      SnackBarHelper.showSuccessSnackBar(
        SnackBarHelper.localized(
          (s) => s.item_added_to_cart,
          fallback: 'Item added to cart',
        ),
      );
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.failed_add_item,
          fallback: 'Failed to add item to cart',
        ),
      );
    }
  }

  void updateCart(CartModel cartItem, int quantity) {
    try {
      int newQuantity = cartItem.quantity + quantity;

      if (newQuantity <= 0) {
        flutterCart.removeItem(cartItem.productId, cartItem.variants);
        SnackBarHelper.showSuccessSnackBar(
          SnackBarHelper.localized(
            (s) => s.item_removed,
            fallback: 'Item removed from cart',
          ),
        );
      } else {
        flutterCart.updateQuantity(
          cartItem.productId,
          cartItem.variants,
          newQuantity,
        );
      }

      getCartItems();
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.failed_update_cart,
          fallback: 'Could not update the cart. Please try again.',
        ),
      );
    }
  }

  bool _areVariantsEqual(List<ProductVariant>? v1, List<ProductVariant>? v2) {
    if (v1 == null && v2 == null) return true;
    if (v1 == null || v2 == null) return false;
    if (v1.length != v2.length) return false;

    for (int i = 0; i < v1.length; i++) {
      if (v1[i].color != v2[i].color ||
          v1[i].size != v2[i].size ||
          v1[i].price != v2[i].price) {
        return false;
      }
    }
    return true;
  }

  double getCartSubTotal() {
    return flutterCart.subtotal;
  }

  void clearCartItems() {
    flutterCart.clearCart();
    getCartItems();
    SnackBarHelper.showSuccessSnackBar(
      SnackBarHelper.localized((s) => s.cart_cleared, fallback: 'Cart cleared'),
    );
  }

  double getGrandTotal() {
    final grandTotal = getCartSubTotal();
    return grandTotal > 0 ? grandTotal : 0;
  }

  Future<void> pickPaymentProofImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        _paymentProofImage = File(image.path);
        _paymentProofRecordId = null;
        notifyListeners();
        SnackBarHelper.showSuccessSnackBar(
          SnackBarHelper.localized(
            (s) => s.payment_proof_selected,
            fallback: 'Payment proof image selected',
          ),
        );

        await uploadPaymentProof();
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.an_error_occurred,
          fallback: 'Could not select the image. Please try again.',
        ),
      );
    }
  }

  void removePaymentProofImage() {
    _paymentProofImage = null;
    _paymentProofRecordId = null;

    notifyListeners();
    SnackBarHelper.showSuccessSnackBar(
      SnackBarHelper.localized(
        (s) => s.payment_proof_removed,
        fallback: 'Payment proof removed',
      ),
    );
  }

  Future<bool> uploadPaymentProof() async {
    if (_paymentProofImage == null) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.payment_proof_required,
          fallback: 'Please select a payment proof image.',
        ),
      );
      return false;
    }

    try {
      _isUploadingPaymentProof = true;
      notifyListeners();

      List<int> imageBytes = await _paymentProofImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      final extension = _paymentProofImage!.path.split('.').last.toLowerCase();
      final mimeType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      String fileName =
          'payment_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Map<String, dynamic> uploadData = {
        'image': 'data:$mimeType;base64,$base64Image',
        'fileName': fileName,
        'orderAmount': getGrandTotal(),
      };

      final response = await service.addItem(
        endpointUrl: 'payment/upload-proof-base64',
        itemData: uploadData,
      );

      if (response.isOk && response.body != null) {
        final responseMap = response.body as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          final dataMap = responseMap['data'] as Map<String, dynamic>;
          final proofRecordId = dataMap['proofRecordId']?.toString();

          if (proofRecordId != null && proofRecordId.isNotEmpty) {
            _paymentProofRecordId = proofRecordId;

            notifyListeners();
            return true;
          }
        }
      }

      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.upload_failed,
          fallback: 'Could not upload the payment proof. Please try again.',
        ),
      );
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.upload_failed,
          fallback: 'Could not upload the payment proof. Please try again.',
        ),
      );
      return false;
    } finally {
      _isUploadingPaymentProof = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(BuildContext context) async {
    try {
      _isProcessingPayment = true;
      notifyListeners();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final user = userProvider.getLoginUsr();

      if (user == null) {
        SnackBarHelper.showErrorSnackBar(
          SnackBarHelper.localized(
            (s) => s.login_required,
            fallback: 'Please sign in to place an order.',
          ),
        );
        return;
      }

      final selectedMethod = context
          .read<DataProvider>()
          .storeSettings
          .paymentMethods
          .where(
            (method) => method.enabled && method.code == selectedPaymentOption,
          )
          .firstOrNull;
      if (selectedMethod == null) {
        SnackBarHelper.showErrorSnackBar(
          'This payment method is unavailable. Refresh checkout and try again.',
        );
        return;
      }
      if (selectedMethod.requiresProof && !isPaymentProofReady) {
        SnackBarHelper.showErrorSnackBar(
          SnackBarHelper.localized(
            (s) => s.payment_proof_required,
            fallback:
                'Upload payment proof for this method before placing the order.',
          ),
        );
        return;
      }
      if (!selectedMethod.requiresProof) {
        _paymentProofImage = null;
        _paymentProofRecordId = null;
      }

      // Step A: Cache the final total amount BEFORE clearing any states
      final double finalSubtotal = getCartSubTotal();
      final double finalAmount = finalSubtotal;
      // Collection fulfillment has no customer delivery charge.

      Map<String, dynamic> order = {
        'items': cartItemToOrderItem(myCartItems),
        'totalPrice': finalAmount,
        'shippingAddress': {
          'phone': phoneController.text.trim(),
          'street': streetController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text,
          'country': countryController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'paymentMethod': selectedPaymentOption,
        if (selectedMethod.requiresProof && _paymentProofRecordId != null)
          'paymentProof': {
            'proofRecordId': _paymentProofRecordId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'verified': false,
          },
        'orderTotal': {
          "subtotal": finalSubtotal,
          "delivery": 0,
          "total": finalAmount,
        },
      };

      final previousAttempt = box.read('order_idempotency_attempt');
      final idempotencyKey = retainOrderIdempotencyKey(
        request: order,
        previousFingerprint: previousAttempt is Map
            ? previousAttempt['fingerprint']?.toString()
            : null,
        previousKey: previousAttempt is Map
            ? previousAttempt['key']?.toString()
            : null,
      );
      box.write('order_idempotency_attempt', {
        'fingerprint': orderRequestFingerprint(order),
        'key': idempotencyKey,
      });

      // Step B: Process the network request to submit the order
      final response = await service.addItem(
        endpointUrl: 'orders',
        itemData: order,
        extraHeaders: {'Idempotency-Key': idempotencyKey},
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(
            SnackBarHelper.localized(
              (s) => s.order_created,
              fallback: 'Order created successfully!',
            ),
          );
          saveAddress();
          // Synchronize address with ProfileProvider
          _syncAddressWithProfileProvider(profileProvider);
          clearCartItems();
          box.remove('order_idempotency_attempt');
          _paymentProofImage = null;
          _paymentProofRecordId = null;

          if (!context.mounted) {
            return;
          }

          final responseBody = response.body;
          final responseData = responseBody is Map<String, dynamic>
              ? responseBody['data']
              : null;
          final createdOrderId = responseData is Map<String, dynamic>
              ? responseData['_id']?.toString()
              : null;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(
                orderId: createdOrderId,
                amount: finalAmount,
              ),
            ),
          );
        } else {
          SnackBarHelper.showErrorSnackBar(
            SnackBarHelper.localized(
              (s) => s.order_create_failed,
              fallback: 'Could not create the order. Please try again.',
            ),
          );
        }
      } else {
        debugPrint(
          'ADD ORDER HTTP Error: ${response.statusCode} - ${response.body}',
        );
        SnackBarHelper.showErrorSnackBar(
          SnackBarHelper.localized(
            (s) => s.order_create_failed,
            fallback: 'Could not create the order. Please try again.',
          ),
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.order_create_failed,
          fallback: 'Could not create the order. Please try again.',
        ),
      );
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  // Synchronize address with ProfileProvider so both screens stay in sync
  void _syncAddressWithProfileProvider(ProfileProvider profileProvider) {
    try {
      profileProvider.phoneController.text = phoneController.text;
      profileProvider.streetController.text = streetController.text;
      profileProvider.cityController.text = cityController.text;
      profileProvider.stateController.text = stateController.text;
      profileProvider.postalCodeController.text = postalCodeController.text;
      profileProvider.countryController.text = countryController.text;
      // Persist to shared storage
      profileProvider.storeAddress();
    } catch (e) {
      debugPrint('Failed to sync address with ProfileProvider: $e');
    }
  }

  void submitOrder(BuildContext context) async {
    if (!buyNowFormKey.currentState!.validate()) {
      SnackBarHelper.showErrorSnackBar(
        SnackBarHelper.localized(
          (s) => s.please_fill_all_fields,
          fallback: 'Please fill all required fields',
        ),
      );
      return;
    }

    buyNowFormKey.currentState!.save();

    if (isExpanded) {
      if (phoneController.text.trim().isEmpty ||
          cityController.text.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar(
          SnackBarHelper.localized(
            (s) => s.address_fields_required,
            fallback: 'Phone number and destination city are required.',
          ),
        );
        return;
      }
    }

    final method = context
        .read<DataProvider>()
        .storeSettings
        .paymentMethods
        .where((entry) => entry.code == selectedPaymentOption && entry.enabled)
        .firstOrNull;
    if (method == null) return;
    if (!method.requiresProof) {
      await addOrder(context);
      return;
    }
    final result = await _showConfiguredPaymentInstructions(context);
    if (result == true && context.mounted) await addOrder(context);
  }

  Future<bool?> _showConfiguredPaymentInstructions(BuildContext context) {
    final settings = context.read<DataProvider>().storeSettings;
    final method = settings.paymentMethods
        .where((entry) => entry.code == selectedPaymentOption && entry.enabled)
        .firstOrNull;
    if (method == null) return Future.value(false);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MarketPalette.pageCanvas(context),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: MarketPalette.border),
        ),
        title: Text(method.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (method.instructions.trim().isNotEmpty) ...[
                Text(method.instructions.trim()),
                const SizedBox(height: 15),
              ],
              if (method.providerName.isNotEmpty)
                Text('Provider: ${method.providerName}'),
              if (method.accountHolder.isNotEmpty)
                Text('Recipient: ${method.accountHolder}'),
              if (method.accountIdentifier.isNotEmpty)
                Text('Payment identifier: ${method.accountIdentifier}'),
              if (method.additionalDetails.isNotEmpty)
                Text(method.additionalDetails),
              if (method.requiresProof) _buildPaymentProofUploadSection(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) => TextButton(
              onPressed:
                  !method.requiresProof || cartProvider.isPaymentProofReady
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: MarketPalette.blueDeep,
              ),
              child: Text(context.l10n.confirm_payment),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofUploadSection() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final hasProof =
            cartProvider.paymentProofImage != null ||
            (cartProvider.paymentProofRecordId != null &&
                cartProvider.paymentProofRecordId!.isNotEmpty);

        return Column(
          children: [
            const Text(
              '📸 Upload Payment Proof',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: MarketPalette.field,
                border: Border.all(
                  color: hasProof
                      ? MarketPalette.success
                      : MarketPalette.border,
                  width: hasProof ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cartProvider.buildProofPreview(),
            ),
            const SizedBox(height: 10),
            if (hasProof)
              const Text(
                '✓ Proof uploaded successfully',
                style: TextStyle(
                  color: MarketPalette.success,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (cartProvider.isUploadingPaymentProof)
              const Text(
                'Uploading...',
                style: TextStyle(color: MarketPalette.warningDark),
              )
            else
              Text(
                context.l10n.no_proof_uploaded,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: cartProvider.isUploadingPaymentProof
                      ? null
                      : () => cartProvider.pickPaymentProofImage(),
                  icon: const Icon(Icons.upload),
                  label: Text(context.l10n.upload_proof),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketPalette.blueDeep,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (hasProof)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: cartProvider.isUploadingPaymentProof
                          ? null
                          : () => cartProvider.removePaymentProofImage(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildProofPreview() {
    if (_paymentProofImage != null) {
      return Image.file(_paymentProofImage!, fit: BoxFit.cover);
    } else if (_paymentProofRecordId != null &&
        _paymentProofRecordId!.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 40, color: Colors.green),
            SizedBox(height: 8),
            Text('Payment proof uploaded'),
          ],
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No proof uploaded', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  bool get isPaymentProofReady {
    return _paymentProofRecordId != null && _paymentProofRecordId!.isNotEmpty;
  }

  void setCoordinates(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void retrieveSavedAddress() {
    try {
      // First try to load from ProfileProvider's shared keys
      phoneController.text = box.read(phoneKey) ?? '';
      streetController.text = box.read(streetKey) ?? '';
      cityController.text = box.read(cityKey) ?? '';
      stateController.text = box.read(stateKey) ?? '';
      postalCodeController.text = box.read(postalCodeKey) ?? '';
      countryController.text = box.read(countryKey) ?? '';

      // Fallback to legacy saved address if shared keys are empty
      if (phoneController.text.isEmpty &&
          streetController.text.isEmpty &&
          cityController.text.isEmpty) {
        final savedAddress = box.read(_savedAddressKey);
        if (savedAddress != null) {
          phoneController.text = savedAddress['phone'] ?? '';
          streetController.text = savedAddress['street'] ?? '';
          cityController.text = savedAddress['city'] ?? '';
          stateController.text = savedAddress['state'] ?? '';
          postalCodeController.text = savedAddress['postalCode'] ?? '';
          countryController.text = savedAddress['country'] ?? '';
        }
      }
    } catch (e) {
      return;
    }
  }

  void saveAddress() {
    try {
      // Save to both legacy key and shared ProfileProvider keys
      final address = {
        'phone': phoneController.text,
        'street': streetController.text,
        'city': cityController.text,
        'state': stateController.text,
        'postalCode': postalCodeController.text,
        'country': countryController.text,
      };
      box.write(_savedAddressKey, address);

      // Also save to shared keys for ProfileProvider synchronization
      box.write(phoneKey, phoneController.text);
      box.write(streetKey, streetController.text);
      box.write(cityKey, cityController.text);
      box.write(stateKey, stateController.text);
      box.write(postalCodeKey, postalCodeController.text);
      box.write(countryKey, countryController.text);
    } catch (e) {
      return;
    }
  }

  // New method to sync address from ProfileProvider (call when Profile updates)
  void syncFromProfileProvider(ProfileProvider profileProvider) {
    phoneController.text = profileProvider.phoneController.text;
    streetController.text = profileProvider.streetController.text;
    cityController.text = profileProvider.cityController.text;
    stateController.text = profileProvider.stateController.text;
    postalCodeController.text = profileProvider.postalCodeController.text;
    countryController.text = profileProvider.countryController.text;
    notifyListeners();
  }

  void togglePaymentInstructions() {
    _showPaymentInstructions = !_showPaymentInstructions;
    notifyListeners();
  }

  void setPaymentOption(String option) {
    if (selectedPaymentOption != option &&
        (_paymentProofImage != null || _paymentProofRecordId != null)) {
      _paymentProofImage = null;
      _paymentProofRecordId = null;
    }
    selectedPaymentOption = option;
    notifyListeners();
  }

  void toggleExpansion() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void clearForm() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();
    _paymentProofImage = null;
    _paymentProofRecordId = null;
    selectedPaymentOption = '';
    isExpanded = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> cartItemToOrderItem(List<CartModel> cartItems) {
    return cartItems.map((cartItem) {
      final variant = cartItem.variants.isEmpty
          ? null
          : [
              cartItem.variants.first.color,
              cartItem.variants.first.size,
            ].where((value) => value?.isNotEmpty == true).join(' · ');
      return {
        'productID': cartItem.productId,
        'productName': cartItem.productName,
        'quantity': cartItem.quantity,
        if (cartItem.variants.isNotEmpty)
          'price': cartItem.variants.first.price,
        'variant': variant?.isNotEmpty == true ? variant : 'Default',
      };
    }).toList();
  }

  @override
  void dispose() {
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
