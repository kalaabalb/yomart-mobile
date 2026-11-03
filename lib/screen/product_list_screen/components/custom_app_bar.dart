import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onCollections,
    this.onSearchTap,
  });

  final VoidCallback? onCollections;
  final VoidCallback? onSearchTap;

  @override
  Size get preferredSize => const Size.fromHeight(134);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ProductListProvider>().searchQuery,
    );
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _actionButton(IconData icon, VoidCallback? onTap, bool dark) =>
      Material(
        color: dark ? MarketPalette.homeSurfaceRaised : const Color(0xEFFFFFFF),
        shape: CircleBorder(
          side: BorderSide(
            color: dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F4),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              color: dark ? const Color(0xFFC6D7EC) : const Color(0xFF536E8D),
              size: 18,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final surface =
        dark ? MarketPalette.homeSurfaceRaised : const Color(0xEFFFFFFF);
    final border = dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F4);
    final muted = dark ? MarketPalette.homeMuted : MarketPalette.muted;
    return Padding(
      // Keep the children within preferredSize (25 + 38 + 19 + 44 + 8 = 134).
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/yomart_gold_mark.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YoMart',
                    style: TextStyle(
                      color: dark ? Colors.white : MarketPalette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _actionButton(Icons.auto_awesome_mosaic_outlined,
                  widget.onCollections, dark),
            ],
          ),
          const SizedBox(height: 19),
          Consumer2<DataProvider, ProductListProvider>(
            builder: (context, dataProvider, products, child) {
              if (_searchController.text != products.searchQuery &&
                  !_searchFocusNode.hasFocus) {
                _searchController.text = products.searchQuery;
              }
              return Container(
                height: 44,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    readOnly: widget.onSearchTap != null,
                    onTap: widget.onSearchTap,
                    onChanged: (value) => products.searchProducts(
                        value, dataProvider.allProducts),
                    style: TextStyle(
                      color: dark ? Colors.white : MarketPalette.ink,
                      fontSize: 13,
                    ),
                    cursorColor: const Color(0xFF4FAEFF),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      isDense: true,
                      filled: true,
                      fillColor: surface,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: muted,
                        size: 19,
                      ),
                      prefixIconConstraints: const BoxConstraints.tightFor(
                        width: 42,
                        height: 40,
                      ),
                      suffixIconConstraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      hintText: context.l10n.search_catalog,
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: muted,
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: muted,
                              onPressed: () {
                                _searchController.clear();
                                products.clearSearch(dataProvider.allProducts);
                              },
                            ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
