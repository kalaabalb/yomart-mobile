import 'package:e_commerce_flutter/utility/preview_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release source defaults to preview-safe catalogue mode', () {
    expect(isPreviewCatalog, isTrue);
  });

  test('preview mode never displays price or stock placeholders as values', () {
    expect(canDisplayCatalogPrice(previewMode: true, price: 125000), isFalse);
    expect(canDisplayCatalogPrice(previewMode: false, price: null), isFalse);
    expect(canDisplayCatalogPrice(previewMode: false, price: 0), isFalse);
    expect(canDisplayCatalogPrice(previewMode: false, price: 125000), isTrue);
  });
}
