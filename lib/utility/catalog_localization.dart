import '../l10n/app_localizations.dart';

String localizeCategoryName(AppLocalizations strings, String? category) {
  switch (category?.trim().toLowerCase()) {
    case 'phone':
    case 'phones':
      return strings.phones;
    case 'accessory':
    case 'accessories':
      return strings.accessories;
    case 'tablet':
    case 'tablets':
      return strings.tablets;
    case 'smartwatch':
    case 'smartwatches':
      return strings.smartwatches;
    case 'laptop':
    case 'laptops':
      return strings.laptops;
    case 'gaming':
      return strings.gaming;
    case 'audio':
      return strings.audio;
    case 'home & office':
    case 'home and office':
      return strings.home_office;
    default:
      return category ?? strings.category;
  }
}
