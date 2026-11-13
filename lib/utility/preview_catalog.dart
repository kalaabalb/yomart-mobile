/// Build-time guard for catalogue previews. Production builds default to
/// normal retail presentation; closed-test builds explicitly enable preview.
const bool isPreviewCatalog = bool.fromEnvironment(
  'YOMART_PREVIEW_CATALOG',
  defaultValue: true,
);

/// Prices and stock are intentionally omitted in preview-only builds.
bool canDisplayCatalogPrice({required bool previewMode, required num? price}) =>
    !previewMode && price != null && price > 0;
