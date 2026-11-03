import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/shared/widgets/delivery_location_map.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    if (cart.latitude != null && cart.longitude != null) {
      _selected = LatLng(cart.latitude!, cart.longitude!);
    }
  }

  Future<void> _confirm() async {
    final location = _selected;
    if (location == null || _isSaving) return;
    setState(() => _isSaving = true);
    final cart = context.read<CartProvider>();
    cart.setCoordinates(location.latitude, location.longitude);
    try {
      final places = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        cart.streetController.text = _firstValue([
          place.street,
          place.name,
          place.thoroughfare,
        ]);
        cart.cityController.text = _firstValue([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ]);
        cart.stateController.text = place.administrativeArea ?? '';
        cart.countryController.text = place.country ?? '';
      }
    } catch (_) {
      // Coordinates are still saved if reverse geocoding is unavailable.
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  String _firstValue(List<String?> values) =>
      values.map((value) => value?.trim() ?? '').firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => '',
          );

  @override
  Widget build(BuildContext context) {
    final initial = _selected ?? DeliveryLocationMap.addisAbaba;
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MarketPalette.ink,
        title: Text(
          context.l10n.select_delivery_location,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          DeliveryLocationMap(
            initialCenter: initial,
            selectedPoint: _selected,
            onPointSelected: (point) => setState(() => _selected = point),
          ),
          Positioned(
            top: 14,
            left: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x200D2B57), blurRadius: 14),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded,
                      color: MarketPalette.blue),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      context.l10n.map_pin_instruction,
                      style: const TextStyle(
                          color: MarketPalette.ink, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                18 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x1A0D2B57),
                      blurRadius: 18,
                      offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.delivery_pin,
                      style: const TextStyle(
                          color: MarketPalette.muted, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(
                    _selected == null
                        ? context.l10n.choose_map_point
                        : '${_selected!.latitude.toStringAsFixed(5)}, ${_selected!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                        color: MarketPalette.ink, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: MarketPalette.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              _selected == null || _isSaving ? null : _confirm,
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    context.l10n.confirm_location,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ),
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
