import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../utility/marketplace_design.dart';

class MultiSelectDropDown<T> extends StatelessWidget {
  final String? hintText;
  final List<T> items;
  final Function(List<T>) onSelectionChanged;
  final String Function(T) displayItem;
  final List<T> selectedItems;

  const MultiSelectDropDown({
    super.key,
    required this.items,
    required this.onSelectionChanged,
    required this.displayItem,
    required this.selectedItems,
    this.hintText = 'Select Items',
  });

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    final foreground = dark ? Colors.white : MarketPalette.ink;
    final surface =
        dark ? MarketPalette.homeSurfaceRaised : const Color(0x99FFFFFF);
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Text(
              '$hintText',
              style: TextStyle(
                fontSize: 14,
                color: dark ? MarketPalette.homeMuted : const Color(0xFF506984),
              ),
            ),
            items: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return DropdownMenuItem<T>(
                value: item,
                enabled: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? (dark
                                ? const Color(0xFF69B5FF)
                                : MarketPalette.blueDeep)
                            : (dark
                                ? MarketPalette.homeMuted
                                : MarketPalette.muted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayItem(item),
                          style: TextStyle(fontSize: 14, color: foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            value: selectedItems.isEmpty ? null : selectedItems.last,
            onChanged: (value) {
              if (value == null) return;
              final updated = List<T>.from(selectedItems);
              if (updated.contains(value)) {
                updated.remove(value);
              } else {
                updated.add(value);
              }
              onSelectionChanged(updated);
            },
            selectedItemBuilder: (context) {
              return items.map(
                (item) {
                  return Container(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      selectedItems.map(displayItem).join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        color: foreground,
                      ),
                      maxLines: 1,
                    ),
                  );
                },
              ).toList();
            },
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(left: 16, right: 8),
              height: 50,
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(
                  color:
                      dark ? MarketPalette.homeBorder : const Color(0xFFDDE8F3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.zero,
            ),
            dropdownStyleData: DropdownStyleData(
              elevation: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: dark ? MarketPalette.homeSurface : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
