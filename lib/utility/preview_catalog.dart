/// Build-time guard for catalogue previews. Production builds default to
/// normal retail presentation; closed-test builds explicitly enable preview.
const bool isPreviewCatalog = bool.fromEnvironment(
  'YOMART_PREVIEW_CATALOG',
  defaultValue: false,
);
