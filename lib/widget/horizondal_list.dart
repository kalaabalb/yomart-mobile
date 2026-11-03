import 'package:flutter/material.dart';
import '../utility/app_color.dart';
import '../utility/marketplace_design.dart';

class HorizontalList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) itemToString;
  final T? selected;
  final void Function(T) onSelect;

  const HorizontalList({
    super.key,
    required this.items,
    required this.itemToString,
    required this.onSelect,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected == item;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                itemToString(item),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelect(item);
                }
              },
              backgroundColor:
                  isDarkMode ? MarketPalette.homeSurfaceRaised : Colors.white,
              selectedColor:
                  isDarkMode ? const Color(0xFF155CA9) : AppColor.darkOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? (isDarkMode
                          ? const Color(0xFF459BFA)
                          : AppColor.darkOrange)
                      : isDarkMode
                          ? Colors.grey[700]!
                          : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}

class FilterChipList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) itemToString;
  final T? selected;
  final void Function(T) onSelect;

  const FilterChipList({
    super.key,
    required this.items,
    required this.itemToString,
    required this.onSelect,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;

        return FilterChip(
          label: Text(
            itemToString(item),
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            onSelect(item);
          },
          backgroundColor: Colors.transparent,
          selectedColor: AppColor.darkOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppColor.darkOrange : Colors.grey.shade400,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }
}
