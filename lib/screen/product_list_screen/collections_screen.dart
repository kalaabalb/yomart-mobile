import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/collection.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/shared/widgets/marketplace_product_card.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<DataProvider>().collections.isEmpty) {
        context.read<DataProvider>().getAllCollections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Consumer<DataProvider>(
            builder: (context, catalog, _) {
              final products = catalog.allProducts;
              final collections = catalog.collections;
              final productsById = {
                for (final product in products)
                  if (product.sId != null) product.sId!: product,
              };
              final dark = MarketPalette.isDark(context);
              final cardHeight =
                  (MediaQuery.sizeOf(context).height * .16).clamp(120.0, 160.0);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 18, 17),
                    child: Row(
                      children: [
                        _RoundAction(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.collections,
                                style: TextStyle(
                                  color:
                                      dark ? Colors.white : MarketPalette.ink,
                                  fontSize: 20,
                                  height: 1.1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.curated_for_you,
                                style: TextStyle(
                                  color: dark
                                      ? MarketPalette.homeMuted
                                      : MarketPalette.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _RoundAction(
                          icon: Icons.search_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _CollectionProductsScreen(
                                title: context.l10n.search_products,
                                products: products,
                                searchable: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: catalog.isCollectionsLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF60AFFF),
                            ),
                          )
                        : catalog.collectionsFailedToLoad
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.l10n.general_retry,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: dark
                                              ? MarketPalette.homeMuted
                                              : MarketPalette.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: catalog.isCollectionsLoading
                                            ? null
                                            : () => catalog.getAllCollections(),
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: Text(context.l10n.general_retry),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : collections.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        context.l10n.no_collection_products,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: dark
                                              ? MarketPalette.homeMuted
                                              : MarketPalette.muted,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 0, 18, 22),
                                    itemCount: collections.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final collection = collections[index];
                                      final items = collection.productIds
                                          .map((id) => productsById[id])
                                          .whereType<Product>()
                                          .toList();
                                      return _CollectionCard(
                                        collection: collection,
                                        products: items,
                                        height: cardHeight,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                _CollectionProductsScreen(
                                              title: collection.title,
                                              products: items,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.products,
    required this.height,
    required this.onTap,
  });

  final StoreCollection collection;
  final List<Product> products;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final colors = _collectionColors(collection.id, dark);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: colors,
                    stops: const [0, .56, 1],
                  ),
                  border: Border.all(color: const Color(0x243F91D4)),
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              Positioned(
                right: -14,
                top: -58,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (dark ? Colors.white : const Color(0xFF5D96D4))
                        .withValues(alpha: dark ? .065 : .10),
                    boxShadow: [
                      BoxShadow(
                        color: colors.last.withValues(alpha: dark ? .42 : .26),
                        blurRadius: 45,
                        spreadRadius: 13,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: dark ? Colors.white : MarketPalette.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        collection.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: dark
                              ? const Color(0xFFC2CCDC)
                              : MarketPalette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 6,
                bottom: 5,
                width: MediaQuery.sizeOf(context).width * .48,
                child: _ProductCollage(products: products.take(3).toList()),
              ),
              Positioned(
                right: 12,
                bottom: 11,
                child: Icon(Icons.arrow_forward_rounded,
                    size: 17,
                    color: (dark ? Colors.white : MarketPalette.blueDeep)
                        .withValues(alpha: .76)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _collectionColors(String id, bool dark) {
    final palettes = dark
        ? const [
            [Color(0xFF303B56), Color(0xFF121C35), Color(0xFF583D91)],
            [Color(0xFF143348), Color(0xFF162131), Color(0xFF806448)],
            [Color(0xFF183B58), Color(0xFF111A2F), Color(0xFF373C6C)],
            [Color(0xFF353A43), Color(0xFF151B25), Color(0xFF53374E)],
          ]
        : const [
            [Color(0xFFEAF3FC), Color(0xFFDDEBFA), Color(0xFFCFE2F7)],
            [Color(0xFFE8F4F4), Color(0xFFD9ECEF), Color(0xFFCBE4F1)],
            [Color(0xFFECEFFC), Color(0xFFDFE5F7), Color(0xFFD2E1F5)],
            [Color(0xFFF1EFF7), Color(0xFFE6E8F4), Color(0xFFD7E5F3)],
          ];
    final stableIndex = id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return palettes[stableIndex % palettes.length];
  }
}

class _ProductCollage extends StatelessWidget {
  const _ProductCollage({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Icon(Icons.devices_other_rounded,
            size: 72, color: Color(0xFF9EBCE8)),
      );
    }
    final images = products
        .map((product) => product.images?.firstOrNull?.url ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    if (images.isEmpty) {
      return const Center(
        child: Icon(Icons.devices_other_rounded,
            size: 72, color: Color(0xFF9EBCE8)),
      );
    }
    if (images.length == 1) {
      return Align(
        alignment: Alignment.bottomRight,
        child: CustomNetworkImage(
          imageUrl: images.first,
          width: 120,
          height: 112,
          fit: BoxFit.contain,
        ),
      );
    }
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent
        ],
        stops: [0, .18, .82, 1],
      ).createShader(bounds),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (images.length > 2)
            Positioned(
              right: 6,
              bottom: 0,
              child: _DeviceImage(url: images[2], width: 78, height: 94),
            ),
          Positioned(
            right: 52,
            bottom: 1,
            child: _DeviceImage(url: images[1], width: 76, height: 98),
          ),
          Positioned(
            right: 96,
            bottom: -2,
            child: _DeviceImage(url: images.first, width: 74, height: 105),
          ),
        ],
      ),
    );
  }
}

class _DeviceImage extends StatelessWidget {
  const _DeviceImage(
      {required this.url, required this.width, required this.height});
  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: MarketPalette.isDark(context)
                  ? const Color(0x88000000)
                  : const Color(0x25345170),
              blurRadius: 11,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: CustomNetworkImage(imageUrl: url, fit: BoxFit.contain),
      );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    return Material(
      color: dark ? const Color(0x99192338) : const Color(0xCFFFFFFF),
      shape: CircleBorder(
        side: BorderSide(
          color: dark ? const Color(0x334B6185) : const Color(0xFFD6E4F2),
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: dark ? const Color(0xFFE0E8F5) : MarketPalette.blueDeep,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CollectionProductsScreen extends StatefulWidget {
  const _CollectionProductsScreen({
    required this.title,
    required this.products,
    this.searchable = false,
  });

  final String title;
  final List<Product> products;
  final bool searchable;

  @override
  State<_CollectionProductsScreen> createState() =>
      _CollectionProductsScreenState();
}

class _CollectionProductsScreenState extends State<_CollectionProductsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final muted = dark ? MarketPalette.homeMuted : MarketPalette.muted;
    final products = widget.products.where((product) {
      return (product.name ?? '').toLowerCase().contains(_query.toLowerCase());
    }).toList();
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : MarketPalette.ink,
        iconTheme:
            IconThemeData(color: dark ? Colors.white : MarketPalette.ink),
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : MarketPalette.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        title: Text(widget.title,
            style: TextStyle(
                color: dark ? Colors.white : MarketPalette.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: MarketBackdrop(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: dark
                        ? MarketPalette.homeSurfaceRaised
                        : const Color(0xEFFFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: dark
                          ? MarketPalette.homeBorder
                          : const Color(0xFFDCE8F4),
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    style: TextStyle(
                        color: dark ? Colors.white : MarketPalette.ink,
                        fontSize: 13),
                    cursorColor: const Color(0xFF4FAEFF),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: context.l10n.search_products,
                      hintStyle: TextStyle(fontSize: 11, color: muted),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: muted, size: 19),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Text(context.l10n.trending,
                  style: TextStyle(
                      color: dark ? Colors.white : MarketPalette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(context.l10n.no_collection_products,
                          style: TextStyle(color: muted)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                      itemCount: products.length,
                      gridDelegate: ResponsiveLayout.productGridDelegate(),
                      itemBuilder: (context, index) =>
                          MarketplaceProductCard(product: products[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
