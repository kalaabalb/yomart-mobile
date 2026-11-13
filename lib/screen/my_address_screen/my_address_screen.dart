import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/shared/widgets/delivery_location_map.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});

  @override
  State<MyAddressPage> createState() => _MyAddressPageState();
}

class _MyAddressPageState extends State<MyAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  bool _editing = false;
  int? _editingIndex;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _syncCart(ProfileProvider profile, CartProvider cart) {
    cart.phoneController.text = profile.phoneController.text;
    cart.streetController.text = profile.streetController.text;
    cart.cityController.text = profile.cityController.text;
    cart.stateController.text = profile.stateController.text;
    cart.postalCodeController.text = profile.postalCodeController.text;
    cart.countryController.text = profile.countryController.text;
    cart.setCoordinates(profile.latitude, profile.longitude);
  }

  void _startAdd(ProfileProvider profile) {
    _editingIndex = null;
    _labelController.text = profile.savedAddresses.isEmpty
        ? context.l10n.home_address
        : context.l10n.office_address;
    profile.phoneController.clear();
    profile.streetController.clear();
    profile.cityController.clear();
    profile.stateController.clear();
    profile.postalCodeController.clear();
    profile.countryController.clear();
    profile.setCoordinates(null, null);
    setState(() => _editing = true);
  }

  void _save(ProfileProvider profile, CartProvider cart) {
    if (!_formKey.currentState!.validate()) return;
    profile.saveNamedAddress(_labelController.text, index: _editingIndex);
    profile.retrieveSavedAddress();
    _syncCart(profile, cart);
    setState(() {
      _editing = false;
      _editingIndex = null;
    });
  }

  Future<void> _showMapPicker(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final cart = context.read<CartProvider>();
    LatLng? selected = profile.latitude != null && profile.longitude != null
        ? LatLng(profile.latitude!, profile.longitude!)
        : DeliveryLocationMap.addisAbaba;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setMapState) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.select_delivery_location,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: MarketPalette.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: DeliveryLocationMap(
                        initialCenter: selected!,
                        initialZoom: 14,
                        selectedPoint: selected,
                        onPointSelected: (point) =>
                            setMapState(() => selected = point),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selected == null
                          ? null
                          : () async {
                              final point = selected!;
                              profile.setCoordinates(
                                  point.latitude, point.longitude);
                              cart.setCoordinates(
                                  point.latitude, point.longitude);
                              try {
                                final places = await placemarkFromCoordinates(
                                  point.latitude,
                                  point.longitude,
                                );
                                if (places.isNotEmpty) {
                                  final place = places.first;
                                  profile.streetController.text =
                                      place.street?.isNotEmpty == true
                                          ? place.street!
                                          : place.thoroughfare ?? '';
                                  profile.cityController.text =
                                      place.locality ??
                                          place.subAdministrativeArea ??
                                          '';
                                  profile.stateController.text =
                                      place.administrativeArea ?? '';
                                  profile.countryController.text =
                                      place.country ?? '';
                                  profile.postalCodeController.text =
                                      place.postalCode ?? '';
                                }
                              } catch (_) {
                                // Keep the selected map coordinates if address lookup fails.
                              }
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(context.l10n.confirm_location),
                      style: FilledButton.styleFrom(
                        backgroundColor: MarketPalette.blueDeep,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final dark = MarketPalette.isDark(context);
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              final addresses = profile.savedAddresses;
              final selectedIndex = profile.selectedAddressIndex;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 7, 18, 14),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: context.l10n.back,
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            size: 29,
                            color:
                                dark ? Colors.white : const Color(0xFF213D5D),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          context.l10n.delivery_addresses,
                          style: TextStyle(
                            color: dark ? Colors.white : MarketPalette.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _editing
                        ? _addressForm(context, profile, cart, dark)
                        : addresses.isEmpty
                            ? _emptyAddresses(context, profile)
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 0, 18, 22),
                                children: [
                                  for (var i = 0; i < addresses.length; i++)
                                    _addressCard(
                                      context,
                                      addresses[i],
                                      i,
                                      i == selectedIndex,
                                      profile,
                                      cart,
                                      dark,
                                    ),
                                  const SizedBox(height: 8),
                                  _addAddressAction(context, profile),
                                ],
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addressCard(
    BuildContext context,
    Map<String, dynamic> address,
    int index,
    bool selected,
    ProfileProvider profile,
    CartProvider cart,
    bool dark,
  ) {
    final street = address['street']?.toString() ?? '';
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final country = address['country']?.toString() ?? '';
    final locality = [city, state].where((part) => part.isNotEmpty).join(', ');
    final label = address['label']?.toString() ?? context.l10n.home_address;
    final foreground = dark ? Colors.white : const Color(0xFF314D6D);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: dark
            ? MarketPalette.homeSurface.withValues(alpha: .84)
            : Colors.white.withValues(alpha: .64),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected
              ? (dark ? const Color(0xFF549EFF) : const Color(0xFFBFD6EE))
              : (dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F3)),
          width: selected ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .08 : .025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          profile.selectAddress(index);
          _syncCart(profile, cart);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 9, 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? const Color(0xFF1675E8)
                      : const Color(0xFF9AAFC5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF4E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.l10n.default_label,
                              style: const TextStyle(
                                color: Color(0xFF388A5D),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (street.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(street,
                          style: TextStyle(
                              color: dark
                                  ? MarketPalette.homeMuted
                                  : const Color(0xFF627C99),
                              fontSize: 12)),
                    ],
                    if (locality.isNotEmpty || country.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        [locality, country]
                            .where((part) => part.isNotEmpty)
                            .join(', '),
                        style: TextStyle(
                          color: dark
                              ? MarketPalette.homeMuted
                              : const Color(0xFF627C99),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!selected)
                IconButton(
                  tooltip: context.l10n.remove_address,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    profile.removeNamedAddress(index);
                    cart.retrieveSavedAddress();
                    if (profile.savedAddresses.isEmpty) {
                      _startAdd(profile);
                    }
                  },
                  icon: Icon(Icons.close_rounded,
                      size: 17,
                      color: dark
                          ? MarketPalette.homeMuted
                          : const Color(0xFF8CA0B7)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addAddressAction(
    BuildContext context,
    ProfileProvider profile, {
    bool centered = false,
  }) =>
      Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _startAdd(profile),
          icon: const Icon(Icons.add_circle_rounded, size: 21),
          label: Text(context.l10n.add_new_address),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2676D9),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
          ),
        ),
      );

  Widget _emptyAddresses(BuildContext context, ProfileProvider profile) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.saved_addresses_empty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MarketPalette.isDark(context)
                      ? MarketPalette.homeMuted
                      : MarketPalette.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              _addAddressAction(context, profile, centered: true),
            ],
          ),
        ),
      );

  Widget _addressForm(
    BuildContext context,
    ProfileProvider profile,
    CartProvider cart,
    bool dark,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            _editingIndex == null
                ? context.l10n.add_new_address
                : context.l10n.edit_address,
            style: TextStyle(
              color: dark ? Colors.white : MarketPalette.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _input(
            context,
            controller: _labelController,
            label: context.l10n.address_name,
          ),
          const SizedBox(height: 12),
          _input(
            context,
            controller: profile.phoneController,
            label: context.l10n.phone_number,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _input(
            context,
            controller: profile.streetController,
            label: context.l10n.street_building,
          ),
          const SizedBox(height: 12),
          _input(context,
              controller: profile.cityController, label: context.l10n.city),
          const SizedBox(height: 12),
          _input(context,
              controller: profile.stateController, label: context.l10n.state),
          const SizedBox(height: 12),
          _input(
            context,
            controller: profile.countryController,
            label: context.l10n.country,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showMapPicker(context),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text(context.l10n.map_address),
            style: OutlinedButton.styleFrom(
              foregroundColor: MarketPalette.blueDeep,
              side: const BorderSide(color: Color(0xFFD0E1F1)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
          ),
          if (profile.latitude != null && profile.longitude != null) ...[
            const SizedBox(height: 5),
            Text(
              '${profile.latitude!.toStringAsFixed(4)}, ${profile.longitude!.toStringAsFixed(4)}',
              style: TextStyle(
                color: dark ? MarketPalette.homeMuted : MarketPalette.muted,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    profile.retrieveSavedAddress();
                    _syncCart(profile, cart);
                    setState(() => _editing = false);
                  },
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MarketPrimaryButton(
                  text: context.l10n.save_address,
                  onPressed: () => _save(profile, cart),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final dark = MarketPalette.isDark(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: dark ? Colors.white : MarketPalette.ink),
      validator: (value) => value == null || value.trim().isEmpty
          ? context.l10n.please_enter_field(label)
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: dark ? MarketPalette.homeMuted : MarketPalette.muted,
        ),
        filled: true,
        fillColor: dark
            ? MarketPalette.homeSurfaceRaised.withValues(alpha: .8)
            : Colors.white.withValues(alpha: .62),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
              color: dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
              color: dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: MarketPalette.blue, width: 1.4),
        ),
      ),
    );
  }
}
