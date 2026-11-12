import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/product_detail_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/rating_provider.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/preview_catalog.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/retailer_contact_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _galleryController;
  int _selectedImage = 0;

  bool get _isDark => MarketPalette.isDark(context);
  Color get _background => MarketPalette.pageCanvas(context);
  Color get _surface =>
      _isDark ? const Color(0xFF101A2A) : const Color(0xFFEAF3FC);
  Color get _muted => _isDark ? const Color(0xFF9BAAC0) : MarketPalette.muted;
  Color get _primaryText => _isDark ? Colors.white : MarketPalette.ink;
  static const _colorChoices = <(String, Color)>[
    ('Blue', Color(0xFF66AFFF)),
    ('Silver', Color(0xFFE6E9EF)),
    ('Graphite', Color(0xFF596679)),
    ('Black', Color(0xFF171C26)),
  ];

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    final detailState = context.read<ProductDetailProvider>();
    detailState.selectedVariant = widget.product.proVariantId?.firstOrNull;
    detailState.selectedColor = 'Blue';
    final id = widget.product.sId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<RatingProvider>().getRatingStats(id);
      });
    }
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images ?? const <Images>[];
    final variants = widget.product.proVariantId ?? const <String>[];
    final price = widget.product.offerPrice ?? widget.product.price ?? 0;
    final oldPrice = widget.product.price ?? 0;
    final galleryHeight =
        (MediaQuery.sizeOf(context).height * .36).clamp(225.0, 340.0);
    final hasDiscount = widget.product.offerPrice != null &&
        widget.product.offerPrice! < oldPrice;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            _isDark ? const Color(0xFF091422) : const Color(0xFFF1F6FC),
        systemNavigationBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: MarketBackdrop(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildTopBar()),
                      SliverToBoxAdapter(
                        child: _buildGallery(images, galleryHeight),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 9, 18, 22),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name ?? 'Product',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _primaryText,
                                  fontSize: 19,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 7),
                              _buildRating(),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    isPreviewCatalog
                                        ? 'Price to be confirmed'
                                        : 'Birr ${_formatPrice(price)}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFA34A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (!isPreviewCatalog && hasDiscount) ...[
                                    const SizedBox(width: 9),
                                    Text(
                                      'Birr ${_formatPrice(oldPrice)}',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: _muted,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    _discountBadge(oldPrice, price),
                                  ],
                                ],
                              ),
                              if (isPreviewCatalog) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Preview catalogue. Price and availability are being confirmed; ordering is temporarily unavailable.',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 11),
                              if (!isPreviewCatalog) _buildColorChoices(),
                              if (!isPreviewCatalog && variants.isNotEmpty) ...[
                                const SizedBox(height: 13),
                                Text(
                                  widget.product.proVariantTypeId?.type ??
                                      'Options',
                                  style: TextStyle(
                                    color: _primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildVariantChoices(variants),
                              ],
                              if ((widget.product.description ?? '')
                                      .isNotEmpty &&
                                  !widget.product.description!
                                      .startsWith('DEMO CATALOG')) ...[
                                const SizedBox(height: 14),
                                Text(
                                  widget.product.description!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _muted,
                                    height: 1.35,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              _buildContactActions(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAddToCart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: context.l10n.go_back,
            onTap: () => Navigator.pop(context),
          ),
          Consumer<FavoriteProvider>(
            builder: (context, favorites, _) {
              final id = widget.product.sId;
              final isFavorite =
                  id != null && favorites.checkIsItemFavorite(id);
              return _roundIconButton(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? const Color(0xFFFF6C83) : _primaryText,
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onTap: id == null
                    ? null
                    : () {
                        favorites.updateToFavoriteList(id);
                        favorites.loadFavoriteItems(
                          context.read<DataProvider>().allProducts,
                        );
                      },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _isDark ? const Color(0xCC111B2A) : const Color(0xCCFFFFFF),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: color ?? _primaryText, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(List<Images> images, double galleryHeight) {
    return SizedBox(
      height: galleryHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: images.isEmpty
                ? Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: _muted,
                      size: 56,
                    ),
                  )
                : PageView.builder(
                    controller: _galleryController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _selectedImage = index),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(7, 2, 7, 48),
                      child: CustomNetworkImage(
                        imageUrl: images[index].url ?? '',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        placeholderColor: _surface,
                      ),
                    ),
                  ),
          ),
          if (images.length > 1)
            Positioned(
              left: 14,
              right: 14,
              bottom: 8,
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (context, index) {
                  final selected = index == _selectedImage;
                  return GestureDetector(
                    onTap: () => _galleryController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 62,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF3996FF)
                              : const Color(0xFF344359),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomNetworkImage(
                        imageUrl: images[index].url ?? '',
                        fit: BoxFit.cover,
                        width: 62,
                        height: 40,
                        placeholderColor: _surface,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    final id = widget.product.sId;
    return Consumer<RatingProvider>(
      builder: (context, ratings, _) {
        final stats = id == null ? null : ratings.productRatingStats[id];
        final average = stats?.averageRating ?? 0;
        final count = stats?.ratingCount ?? 0;
        return Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= average.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: _isDark ? const Color(0xFFDFE7F3) : MarketPalette.muted,
                size: 14,
              ),
            const SizedBox(width: 7),
            Text(
              count > 0
                  ? '${average.toStringAsFixed(1)} ($count ${count == 1 ? 'review' : 'reviews'})'
                  : 'No reviews yet',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        );
      },
    );
  }

  Widget _discountBadge(double oldPrice, double price) {
    final percent = ((oldPrice - price) / oldPrice * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A956A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent% OFF',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildColorChoices() {
    return Consumer<ProductDetailProvider>(
      builder: (context, details, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color',
            style: TextStyle(
              color: _primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final choice in _colorChoices)
                GestureDetector(
                  onTap: () {
                    details.selectedColor = choice.$1;
                    details.updateUI();
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    margin: const EdgeInsets.only(right: 9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: details.selectedColor == choice.$1
                          ? Border.all(color: const Color(0xFF72B7FF), width: 2)
                          : null,
                      boxShadow: details.selectedColor == choice.$1
                          ? const [
                              BoxShadow(
                                  color: Color(0x663B91F5), blurRadius: 9),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: choice.$2,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF637187)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChoices(List<String> variants) {
    return Consumer<ProductDetailProvider>(
      builder: (context, details, _) => Wrap(
        spacing: 8,
        runSpacing: 7,
        children: variants.map((variant) {
          final selected = details.selectedVariant == variant;
          return Material(
            color: selected ? const Color(0xFF1B5DBD) : _surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                details.selectedVariant = variant;
                details.updateUI();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(minWidth: 72),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF5EAAFF)
                        : const Color(0xFF28384E),
                  ),
                ),
                child: Text(
                  variant,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : _muted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddToCart() {
    final unavailable = isPreviewCatalog || (widget.product.quantity ?? 0) <= 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: .96),
        border: Border(
            top: BorderSide(
                color: _isDark
                    ? const Color(0xFF182438)
                    : const Color(0x55718AA8))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: unavailable
                  ? const LinearGradient(
                      colors: [Color(0xFF374357), Color(0xFF202A3B)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF45258C), Color(0xFF0876F9)],
                    ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: unavailable
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x55216DE0),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: unavailable
                    ? null
                    : () => context
                        .read<ProductDetailProvider>()
                        .addToCart(widget.product, context),
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Text(
                    isPreviewCatalog
                        ? 'Ordering unavailable'
                        : unavailable
                            ? 'Out of stock'
                            : 'Add to Cart',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactActions() {
    final data = context.watch<DataProvider>();
    final contacts = data.retailerContacts
        .where((contact) => contact.appearsAt('product_details'))
        .toList();
    if (data.isRetailerContactsLoading && contacts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 18),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (contacts.isEmpty) {
      if (data.retailerContactsError != null) {
        return TextButton.icon(
          onPressed: data.getRetailerContacts,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Contact options unavailable · Retry'),
        );
      }
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: contacts.map((contact) {
          final uri = retailerContactUri(contact);
          if (uri == null) return const SizedBox.shrink();
          final icon = switch (contact.type) {
            'phone' => Icons.call_outlined,
            'telegram' => Icons.send_rounded,
            'whatsapp' => Icons.chat_outlined,
            'email' => Icons.email_outlined,
            _ => Icons.open_in_new_rounded,
          };
          return OutlinedButton.icon(
            onPressed: () async {
              try {
                final opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open this contact option.')),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open this contact option.')),
                  );
                }
              }
            },
            icon: Icon(icon, size: 16),
            label: Text(contact.label),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryText,
              side: BorderSide(color: _muted.withValues(alpha: .4)),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatPrice(num value) => value.toStringAsFixed(0);
}
