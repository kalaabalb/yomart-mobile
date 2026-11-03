import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/app_color.dart';
import '../utility/marketplace_design.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final double? height;
  final TextEditingController controller;
  final TextInputType? inputType;
  final int? lineNumber;
  final void Function(String?)? onSave;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLength;
  final bool showCounter;
  final bool marketStyle;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.inputType = TextInputType.text,
    this.lineNumber = 1,
    this.onSave,
    this.validator,
    this.height,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.maxLength,
    this.showCounter = false,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TextFormField(
            controller: controller,
            maxLines: lineNumber,
            maxLength: maxLength,
            obscureText: obscureText,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: labelText,
              filled: marketStyle,
              fillColor: marketStyle ? MarketPalette.field : null,
              labelStyle: TextStyle(
                color: marketStyle ? MarketPalette.muted : null,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(marketStyle ? 14 : 8),
                borderSide: BorderSide(
                  color:
                      marketStyle ? MarketPalette.border : AppColor.darkOrange,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(marketStyle ? 14 : 8),
                borderSide: BorderSide(
                  color: marketStyle ? MarketPalette.border : AppColor.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(marketStyle ? 14 : 8),
                borderSide: BorderSide(
                  color: marketStyle ? MarketPalette.blue : AppColor.darkOrange,
                  width: 1.5,
                ),
              ),
              counterText:
                  showCounter ? null : '', // Hide counter if not needed
            ),
            keyboardType: inputType,
            onSaved: onSave,
            validator: validator,
            inputFormatters: [
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
              if (inputType == TextInputType.number)
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              if (inputType == TextInputType.number && maxLength != null)
                FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ),
    );
  }
}
