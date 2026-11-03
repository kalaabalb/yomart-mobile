// widgets/custom_dropdown.dart
import 'package:flutter/material.dart';
import '../utility/marketplace_design.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayItem;
  final TextStyle? hintStyle;
  final TextStyle? itemStyle;
  final Color? dropdownColor;

  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    this.onChanged,
    required this.displayItem,
    this.hintStyle,
    this.itemStyle,
    this.dropdownColor,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? MarketPalette.homeSurfaceRaised
            : const Color(0x99FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isDarkMode ? MarketPalette.homeBorder : const Color(0xFFDDE8F3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.hintText,
              style: widget.hintStyle ??
                  TextStyle(
                    color: isDarkMode
                        ? MarketPalette.homeMuted
                        : const Color(0xFF506984),
                  ),
            ),
          ),
          isExpanded: true,
          items: widget.items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.displayItem(item),
                  style: widget.itemStyle ??
                      TextStyle(
                        color: isDarkMode ? Colors.white : MarketPalette.ink,
                      ),
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          dropdownColor: widget.dropdownColor ??
              (isDarkMode ? MarketPalette.homeSurface : Colors.white),
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.arrow_drop_down,
              color: isDarkMode
                  ? MarketPalette.homeMuted
                  : const Color(0xFF506984),
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : MarketPalette.ink,
          ),
        ),
      ),
    );
  }
}
