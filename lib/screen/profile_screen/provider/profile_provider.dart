import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';
import '../../../utility/snack_bar_helper.dart';

class ProfileProvider extends ChangeNotifier {
  final GetStorage box = GetStorage();
  static const String _savedAddressesKey = 'savedDeliveryAddresses';
  static const String _selectedAddressKey = 'selectedDeliveryAddress';

  // Address form controllers
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // GPS coordinates from map picker
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  ProfileProvider() {
    retrieveSavedAddress();
  }

  void storeAddress() {
    if (!addressFormKey.currentState!.validate()) {
      return;
    }

    addressFormKey.currentState!.save();

    box.write(phoneKey, phoneController.text);
    box.write(streetKey, streetController.text);
    box.write(cityKey, cityController.text);
    box.write(stateKey, stateController.text);
    box.write(postalCodeKey, postalCodeController.text);
    box.write(countryKey, countryController.text);
    final entries = savedAddresses.toList(growable: true);
    if (entries.isNotEmpty) {
      final index = selectedAddressIndex.clamp(0, entries.length - 1);
      entries[index] = _addressFromControllers(
        label: entries[index]['label']?.toString() ?? 'Home',
        isDefault: true,
      );
      box.write(_savedAddressesKey, entries);
    }
    // Also save GPS coordinates if available
    if (_latitude != null) box.write('LATITUDE_KEY', _latitude!);
    if (_longitude != null) box.write('LONGITUDE_KEY', _longitude!);

    SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
      (s) => s.address_stored,
      fallback: 'Address stored successfully',
    ));
    notifyListeners();
  }

  List<Map<String, dynamic>> get savedAddresses {
    final stored = box.read(_savedAddressesKey);
    if (stored is List) {
      return stored
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    final legacy = _addressFromControllers(label: 'Home', isDefault: true);
    if (_hasAddress(legacy)) {
      box.write(_savedAddressesKey, [legacy]);
      box.write(_selectedAddressKey, 0);
      return [legacy];
    }
    return const [];
  }

  int get selectedAddressIndex {
    final index = box.read(_selectedAddressKey);
    return index is int ? index : 0;
  }

  void saveNamedAddress(String label, {int? index}) {
    final entries = savedAddresses.toList(growable: true);
    final resolvedIndex = index ?? entries.length;
    final address = _addressFromControllers(
      label: label.trim().isEmpty ? 'Home' : label.trim(),
      isDefault: entries.isEmpty || resolvedIndex == selectedAddressIndex,
    );

    if (index != null && index >= 0 && index < entries.length) {
      entries[index] = address;
    } else {
      entries.add(address);
      if (entries.length == 1) box.write(_selectedAddressKey, 0);
    }

    box.write(_savedAddressesKey, entries);
    if (entries.length == 1 || resolvedIndex == selectedAddressIndex) {
      _selectAddressData(address);
    }
    notifyListeners();
  }

  void selectAddress(int index) {
    final entries = savedAddresses;
    if (index < 0 || index >= entries.length) return;
    final updated = entries
        .asMap()
        .entries
        .map((entry) => {
              ...entry.value,
              'isDefault': entry.key == index,
            })
        .toList(growable: false);
    box.write(_savedAddressesKey, updated);
    box.write(_selectedAddressKey, index);
    _selectAddressData(updated[index]);
    notifyListeners();
  }

  void removeNamedAddress(int index) {
    final entries = savedAddresses.toList(growable: true);
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    var selected = selectedAddressIndex;
    if (entries.isEmpty) {
      box.remove(_savedAddressesKey);
      box.remove(_selectedAddressKey);
      clearAddress();
      return;
    }
    if (index == selected) selected = 0;
    if (index < selected) selected--;
    box.write(_savedAddressesKey, entries);
    box.write(_selectedAddressKey, selected);
    _selectAddressData(entries[selected]);
    notifyListeners();
  }

  Map<String, dynamic> _addressFromControllers({
    required String label,
    required bool isDefault,
  }) =>
      {
        'label': label,
        'phone': phoneController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'country': countryController.text.trim(),
        'postalCode': postalCodeController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'isDefault': isDefault,
      };

  bool _hasAddress(Map<String, dynamic> address) =>
      (address['street'] as String? ?? '').isNotEmpty ||
      (address['city'] as String? ?? '').isNotEmpty ||
      (address['phone'] as String? ?? '').isNotEmpty;

  void _selectAddressData(Map<String, dynamic> address) {
    phoneController.text = address['phone']?.toString() ?? '';
    streetController.text = address['street']?.toString() ?? '';
    cityController.text = address['city']?.toString() ?? '';
    stateController.text = address['state']?.toString() ?? '';
    countryController.text = address['country']?.toString() ?? '';
    postalCodeController.text = address['postalCode']?.toString() ?? '';
    _latitude = (address['latitude'] as num?)?.toDouble();
    _longitude = (address['longitude'] as num?)?.toDouble();
    box.write(phoneKey, phoneController.text);
    box.write(streetKey, streetController.text);
    box.write(cityKey, cityController.text);
    box.write(stateKey, stateController.text);
    box.write(postalCodeKey, postalCodeController.text);
    box.write(countryKey, countryController.text);
    if (_latitude != null) box.write('LATITUDE_KEY', _latitude);
    if (_longitude != null) box.write('LONGITUDE_KEY', _longitude);
  }

  void retrieveSavedAddress() {
    final entries = box.read(_savedAddressesKey);
    if (entries is List && entries.isNotEmpty) {
      final selected = selectedAddressIndex.clamp(0, entries.length - 1);
      _selectAddressData(Map<String, dynamic>.from(entries[selected] as Map));
      return;
    }
    phoneController.text = box.read(phoneKey) ?? '';
    streetController.text = box.read(streetKey) ?? '';
    cityController.text = box.read(cityKey) ?? '';
    stateController.text = box.read(stateKey) ?? '';
    postalCodeController.text = box.read(postalCodeKey) ?? '';
    countryController.text = box.read(countryKey) ?? '';
    _latitude = box.read('LATITUDE_KEY');
    _longitude = box.read('LONGITUDE_KEY');
  }

  void clearAddress() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();

    box.remove(phoneKey);
    box.remove(streetKey);
    box.remove(cityKey);
    box.remove(stateKey);
    box.remove(postalCodeKey);
    box.remove(countryKey);
    box.remove('LATITUDE_KEY');
    box.remove('LONGITUDE_KEY');
    _latitude = null;
    _longitude = null;

    notifyListeners();
  }

  // Set GPS coordinates from map picker
  void setCoordinates(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  // Synchronize address from CartProvider
  void syncFromCartProvider(phone, street, city, state, postalCode, country,
      {lat, lng}) {
    phoneController.text = phone ?? '';
    streetController.text = street ?? '';
    cityController.text = city ?? '';
    stateController.text = state ?? '';
    postalCodeController.text = postalCode ?? '';
    countryController.text = country ?? '';
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }
}
