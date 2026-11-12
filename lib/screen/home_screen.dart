import 'dart:math' as math;

import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/cart_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/favorite_screen.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/brands_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/product_list_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/profile_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  _HomeTab _currentTab = _HomeTab.home;
  late final AnimationController _waterAnimation;

  @override
  void initState() {
    super.initState();
    _waterAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _waterAnimation.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
        ProductListScreen(
          onSearch: _openSearch,
        ),
        const CartScreen(),
        const FavoriteScreen(),
        const ProfileScreen(),
      ];

  void _selectTab(_HomeTab tab) {
    if (_currentTab != tab) setState(() => _currentTab = tab);
    _waterAnimation.forward(from: 0);
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _SearchResultsScreen(
          onCancel: () {
            context
                .read<ProductListProvider>()
                .clearSearch(context.read<DataProvider>().allProducts);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = context.watch<DataProvider>().isDarkMode;
    final darkSurface = isDarkTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            darkSurface ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            darkSurface ? const Color(0xFF091422) : const Color(0xFFF1F6FC),
        systemNavigationBarIconBrightness:
            darkSurface ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: darkSurface,
      ),
      child: Scaffold(
        backgroundColor: MarketPalette.pageCanvas(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final desktop =
                constraints.maxWidth >= ResponsiveLayout.desktopBreakpoint;
            final maxWidth =
                ResponsiveLayout.contentMaxWidth(constraints.maxWidth);
            final content = Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child:
                    IndexedStack(index: _currentTab.index, children: _screens),
              ),
            );
            if (desktop) {
              return Row(
                children: [
                  _buildDesktopNavigation(!darkSurface),
                  Expanded(child: content),
                ],
              );
            }
            return content;
          },
        ),
        bottomNavigationBar: MediaQuery.sizeOf(context).width >=
                ResponsiveLayout.desktopBreakpoint
            ? null
            : _buildBottomNavigationBar(!darkSurface),
      ),
    );
  }

  Widget _buildDesktopNavigation(bool lightMode) {
    final entries = [
      (
        _HomeTab.home,
        Icons.home_outlined,
        Icons.home_rounded,
        context.l10n.home
      ),
      (
        _HomeTab.cart,
        Icons.shopping_cart_outlined,
        Icons.shopping_cart_rounded,
        context.l10n.cart
      ),
      (
        _HomeTab.favorites,
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
        context.l10n.my_favorites
      ),
      (
        _HomeTab.account,
        Icons.person_outline_rounded,
        Icons.person_rounded,
        context.l10n.account_tab
      ),
    ];
    final background =
        lightMode ? const Color(0xFFF1F6FC) : const Color(0xFF091422);
    final muted = lightMode ? const Color(0xFF8195AC) : const Color(0xFF9AADC4);
    final active =
        lightMode ? const Color(0xFF075DC9) : const Color(0xFF66B4FF);
    return Container(
      width: 224,
      color: background,
      padding: const EdgeInsets.fromLTRB(16, 24, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset('assets/images/yomart_gold_mark.png',
                width: 44, height: 44),
            const SizedBox(width: 9),
            Text('YoMart',
                style: TextStyle(
                    color: lightMode ? MarketPalette.ink : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17)),
          ]),
          const SizedBox(height: 32),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: _currentTab == entry.$1
                    ? active.withValues(alpha: lightMode ? .11 : .18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => _selectTab(entry.$1),
                  child: SizedBox(
                    height: 48,
                    child: Row(children: [
                      const SizedBox(width: 13),
                      Icon(_currentTab == entry.$1 ? entry.$3 : entry.$2,
                          size: 20,
                          color: _currentTab == entry.$1 ? active : muted),
                      const SizedBox(width: 12),
                      Text(entry.$4,
                          style: TextStyle(
                            color: _currentTab == entry.$1 ? active : muted,
                            fontWeight: _currentTab == entry.$1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          )),
                    ]),
                  ),
                ),
              ),
            ),
          const Spacer(),
          Divider(
              color: lightMode
                  ? const Color(0xFFDCE8F4)
                  : const Color(0xFF1B2A3E)),
          Text('YoMart', style: TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool lightMode) {
    final entries = [
      (
        _HomeTab.home,
        Icons.home_outlined,
        Icons.home_rounded,
        context.l10n.home
      ),
      (
        _HomeTab.cart,
        Icons.shopping_cart_outlined,
        Icons.shopping_cart_rounded,
        context.l10n.cart
      ),
      (
        _HomeTab.favorites,
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
        context.l10n.my_favorites
      ),
      (
        _HomeTab.account,
        Icons.person_outline_rounded,
        Icons.person_rounded,
        context.l10n.account_tab
      ),
    ];
    final muted = lightMode ? const Color(0xFF8195AC) : const Color(0xFF9AADC4);
    final active =
        lightMode ? const Color(0xFF075DC9) : const Color(0xFF66B4FF);

    return Container(
      color: lightMode ? const Color(0xFFF1F6FC) : const Color(0xFF091422),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WaterSurfacePainter(
                  animation: _waterAnimation,
                  selectedIndex: _currentTab.index,
                  fillColor: lightMode
                      ? const Color(0xF5F4F8FC)
                      : const Color(0xF0091423),
                  edgeColor: lightMode
                      ? const Color(0xFFDCE8F4)
                      : const Color(0x1A9CBDE8),
                  rippleColor: active,
                ),
              ),
            ),
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              color: Colors.transparent,
              child: Row(
                children: entries.map((entry) {
                  final selected = _currentTab == entry.$1;
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: entry.$4,
                      child: Tooltip(
                        message: entry.$4,
                        child: InkWell(
                          onTap: () => _selectTab(entry.$1),
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox.expand(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: selected ? 1.12 : 1,
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  child: Icon(
                                    selected ? entry.$3 : entry.$2,
                                    size: 19,
                                    color: selected ? active : muted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  style: TextStyle(
                                    color: selected ? active : muted,
                                    fontSize: 9.5,
                                    height: 1,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    entry.$4,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              top: -32,
              left: 0,
              right: 0,
              height: 34,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WaterRipplePainter(
                    animation: _waterAnimation,
                    selectedIndex: _currentTab.index,
                    color: active,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterSurfacePainter extends CustomPainter {
  _WaterSurfacePainter({
    required this.animation,
    required this.selectedIndex,
    required this.fillColor,
    required this.edgeColor,
    required this.rippleColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final int selectedIndex;
  final Color fillColor;
  final Color edgeColor;
  final Color rippleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final impact = ((progress - .2) / .8).clamp(0.0, 1.0);
    final ripplePhase = (impact / .82).clamp(0.0, 1.0);
    final centerX = size.width * (selectedIndex + .5) / 4;
    final radius = ripplePhase * math.min(size.height * .72, size.width * .42);
    final width = 14 + ripplePhase * 8;
    final waveHeight = 8 * math.sin(math.pi * ripplePhase);

    double surfaceY(double x) {
      if (impact == 0) return 0;
      final distance = (x - centerX).abs();
      // A droplet pulls the surface down at the impact point. The raised rim
      // travels away from it, like water in a shallow glass.
      final impactDip =
          10 * math.exp(-impact * 5) * math.exp(-math.pow(distance / 11, 2));
      final travelingCrest =
          waveHeight * math.exp(-math.pow((distance - radius) / width, 2));
      return (impactDip - travelingCrest).clamp(-8.0, 11.0);
    }

    final surface = Path()..moveTo(0, surfaceY(0));
    for (double x = 2; x < size.width; x += 2) {
      surface.lineTo(x, surfaceY(x));
    }
    surface
      ..lineTo(size.width, surfaceY(size.width))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillBounds = Offset.zero & size;
    canvas.drawPath(
      surface,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor,
            Color.lerp(fillColor, rippleColor, .035) ?? fillColor,
          ],
        ).createShader(fillBounds),
    );
    canvas.save();
    canvas.clipPath(surface);
    if (ripplePhase > .015 && ripplePhase < 1) {
      // One lower semicircle spreads from the impact through the liquid. It
      // shares the waterline wave's radius and fades before reaching the bar's
      // sides.
      final ripple = Path()
        ..addArc(
          Rect.fromCircle(center: Offset(centerX, 0), radius: radius),
          0,
          math.pi,
        );
      canvas.drawPath(
        ripple,
        Paint()
          ..color = rippleColor.withValues(alpha: .42 * (1 - ripplePhase))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.restore();
    final edge = Path()..moveTo(0, surfaceY(0));
    for (double x = 2; x < size.width; x += 2) {
      edge.lineTo(x, surfaceY(x));
    }
    edge.lineTo(size.width, surfaceY(size.width));
    canvas.drawPath(
      edge,
      Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterSurfacePainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.edgeColor != edgeColor ||
      oldDelegate.rippleColor != rippleColor;
}

class _WaterRipplePainter extends CustomPainter {
  _WaterRipplePainter({
    required this.animation,
    required this.selectedIndex,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final int selectedIndex;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    const fallDuration = .23;
    if (progress >= fallDuration) return;
    final centerX = size.width * (selectedIndex + .5) / 4;
    final fall = Curves.easeInCubic.transform(progress / fallDuration);
    final centerY = -2 + fall * 34;
    final drop = Path()
      ..moveTo(centerX, centerY - 6)
      ..cubicTo(centerX + 1, centerY - 2, centerX + 5, centerY + 1, centerX + 4,
          centerY + 4)
      ..cubicTo(centerX + 3, centerY + 9, centerX - 3, centerY + 9, centerX - 4,
          centerY + 4)
      ..cubicTo(centerX - 5, centerY + 1, centerX - 1, centerY - 2, centerX,
          centerY - 6)
      ..close();
    final opacity = (1 - math.pow(fall, 2)).toDouble();
    canvas.drawPath(
      drop,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, .48)!.withValues(alpha: opacity),
            color.withValues(alpha: opacity),
          ],
        ).createShader(Rect.fromLTWH(centerX - 5, centerY - 6, 10, 15)),
    );
  }

  @override
  bool shouldRepaint(covariant _WaterRipplePainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex || oldDelegate.color != color;
}

enum _HomeTab { home, cart, favorites, account }

class _SearchResultsScreen extends StatefulWidget {
  const _SearchResultsScreen({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<_SearchResultsScreen> {
  static const List<String> _filters = [
    'All',
    'Phones',
    'Brands',
    'Accessories',
  ];

  late final TextEditingController _controller;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ProductListProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancelSearch() {
    setState(() => _activeFilter = 'All');
    widget.onCancel();
  }

  Future<void> _selectSearchFilter(String filter) async {
    if (filter == 'Brands') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => BrandsScreen(
            brands: context.read<DataProvider>().brands,
            products: context.read<DataProvider>().allProducts,
          ),
        ),
      );
      return;
    }
    setState(() => _activeFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final searchQuery = context.watch<ProductListProvider>().searchQuery;
    if (_controller.text != searchQuery) {
      _controller.value = TextEditingValue(
        text: searchQuery,
        selection: TextSelection.collapsed(offset: searchQuery.length),
      );
    }

    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                controller: _controller,
                                onChanged: (value) => context
                                    .read<ProductListProvider>()
                                    .searchProducts(
                                      value,
                                      context.read<DataProvider>().allProducts,
                                    ),
                                style: TextStyle(
                                  color:
                                      dark ? Colors.white : MarketPalette.ink,
                                  fontSize: 14,
                                ),
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  hintText: context.l10n.search_catalog,
                                  hintStyle: TextStyle(
                                    color: dark
                                        ? MarketPalette.homeMuted
                                        : const Color(0xFF8498B1),
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: dark
                                        ? MarketPalette.homeMuted
                                        : const Color(0xFF7790AC),
                                    size: 20,
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints.tightFor(
                                          width: 44, height: 40),
                                  suffixIconConstraints:
                                      const BoxConstraints.tightFor(
                                          width: 40, height: 40),
                                  suffixIcon: _controller.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: context.l10n.clear_search,
                                          onPressed: () {
                                            _controller.clear();
                                            context
                                                .read<ProductListProvider>()
                                                .searchProducts(
                                                  '',
                                                  context
                                                      .read<DataProvider>()
                                                      .allProducts,
                                                );
                                          },
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: dark
                                                ? MarketPalette.homeMuted
                                                : const Color(0xFF8EA1B8),
                                            size: 18,
                                          ),
                                        ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  filled: true,
                                  fillColor: dark
                                      ? MarketPalette.homeSurfaceRaised
                                          .withValues(alpha: .92)
                                      : const Color(0xCFFFFFFF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: dark
                                          ? MarketPalette.homeBorder
                                          : const Color(0xFFDDE8F3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: dark
                                          ? const Color(0xFF459BFA)
                                          : const Color(0xFF91B6DF),
                                    ),
                                  ),
                                ),
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _cancelSearch,
                            style: TextButton.styleFrom(
                              foregroundColor: dark
                                  ? const Color(0xFF6BB7FF)
                                  : MarketPalette.blueDeep,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              minimumSize: const Size(48, 40),
                            ),
                            child: Text(
                              context.l10n.cancel,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final selected = filter == _activeFilter;
                            return ChoiceChip(
                              label: Text(_localizedFilter(context, filter)),
                              selected: selected,
                              onSelected: (_) => _selectSearchFilter(filter),
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                color: selected
                                    ? (dark
                                        ? Colors.white
                                        : const Color(0xFF17416F))
                                    : (dark
                                        ? MarketPalette.homeMuted
                                        : const Color(0xFF506984)),
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              backgroundColor: dark
                                  ? MarketPalette.homeSurfaceRaised
                                  : const Color(0x99FFFFFF),
                              selectedColor: dark
                                  ? const Color(0xFF155CA9)
                                  : const Color(0xFFDCEAF8),
                              side: BorderSide(
                                color: selected
                                    ? (dark
                                        ? const Color(0xFF459BFA)
                                        : const Color(0xFFC5D9EE))
                                    : (dark
                                        ? MarketPalette.homeBorder
                                        : const Color(0xFFDDE8F3)),
                              ),
                              shape: const StadiumBorder(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Consumer2<ProductListProvider, DataProvider>(
                          builder: (context, products, data, _) {
                            final source = products.searchQuery.isEmpty
                                ? data.allProducts
                                : products.filteredProducts;
                            final items = source
                                .where((product) => _matchesFilter(product))
                                .toList();
                            if (data.isProductsLoading && items.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: MarketPalette.blue,
                                ),
                              );
                            }
                            if (items.isEmpty) {
                              return Center(
                                child: Text(
                                  products.searchQuery.isEmpty
                                      ? context.l10n.no_products_available
                                      : context.l10n.no_search_matches,
                                  style: TextStyle(
                                      color: dark
                                          ? MarketPalette.homeMuted
                                          : MarketPalette.muted),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.only(top: 2),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => SizedBox(
                                height: 9,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 94),
                                  child: Divider(
                                    height: 1,
                                    thickness: .7,
                                    color: dark
                                        ? MarketPalette.homeBorder
                                        : const Color(0xFFDDE8F3),
                                  ),
                                ),
                              ),
                              itemBuilder: (context, index) => _SearchResultRow(
                                product: items[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _matchesFilter(Product product) {
    if (_activeFilter == 'All') return true;
    final category = (product.proCategoryId?.name ?? '').toLowerCase();
    final name = (product.name ?? '').toLowerCase();
    if (_activeFilter == 'Phones') {
      return category.contains('phone') ||
          name.contains('iphone') ||
          name.contains('pixel') ||
          name.contains('galaxy s');
    }
    if (_activeFilter == 'Brands') {
      return (product.proBrandId?.name ?? '').trim().isNotEmpty;
    }
    return category.contains('accessor') ||
        category.contains('audio') ||
        name.contains('airpods') ||
        name.contains('case');
  }

  String _localizedFilter(BuildContext context, String filter) =>
      switch (filter) {
        'All' => context.l10n.search_all,
        'Phones' => context.l10n.search_phones,
        'Brands' => context.l10n.search_brands,
        _ => context.l10n.search_accessories,
      };
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final imageUrl = product.images?.isNotEmpty == true
        ? product.images!.first.url ?? ''
        : '';
    final amount = product.offerPrice ?? product.price ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 94,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 78,
                  decoration: BoxDecoration(
                    color: dark
                        ? MarketPalette.homeSurfaceRaised
                        : const Color(0xFFDDEAF6).withValues(alpha: .65),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name ?? context.l10n.product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: dark ? Colors.white : MarketPalette.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Birr ${_formatSearchPrice(amount)}',
                        style: TextStyle(
                          color: dark
                              ? MarketPalette.homeMuted
                              : MarketPalette.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14,
                              color: dark
                                  ? const Color(0xFFFFC857)
                                  : MarketPalette.navy),
                          const SizedBox(width: 3),
                          Text(
                            context.l10n.no_reviews_yet,
                            style: TextStyle(
                              color: (dark
                                      ? MarketPalette.homeMuted
                                      : MarketPalette.muted)
                                  .withValues(alpha: .9),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color:
                      dark ? MarketPalette.homeMuted : const Color(0xFF8EA5BF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatSearchPrice(num amount) =>
      amount == amount.roundToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2);
}
