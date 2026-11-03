import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:provider/provider.dart';

class ProductDetailProvider extends ChangeNotifier {
  String? selectedVariant;
  String? selectedColor;

  void addToCart(Product product, BuildContext context) {
    if ((product.proVariantId ?? []).isNotEmpty && selectedVariant == null) {
      SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
          (s) => s.please_select_variant,
          fallback: 'Please select a variant'));
      return;
    }

    double? price = product.offerPrice != product.price
        ? product.offerPrice
        : product.price;

    try {
      // Use CartProvider instead of local flutterCart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Use the CartProvider's addToCart method
      cartProvider.addToCart(
        productId: product.sId!,
        productName: product.name!,
        price: price?.toDouble() ?? 0.0,
        productImages:
            product.images?.map((img) => img.url ?? '').toList() ?? [],
        variants: [
          ProductVariant(
            price: price?.toDouble() ?? 0.0,
            color: selectedColor,
            size: selectedVariant,
          ),
        ],
        quantity: 1,
      );

      selectedVariant = null;
      selectedColor = null;
      SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
          (s) => s.item_added_to_cart,
          fallback: 'Item added to cart'));

      // Print cart contents for debugging

      // ignore: unused_local_variable
      for (var item in cartProvider.myCartItems) {}

      notifyListeners();
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
        (s) => s.failed_add_item,
        fallback: 'Failed to add item to cart',
      ));
    }
  }

  void updateUI() {
    notifyListeners();
  }
}
