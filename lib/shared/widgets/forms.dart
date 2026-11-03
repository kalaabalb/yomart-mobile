import 'package:flutter/material.dart';
import '../../utility/app_color.dart';
import '../../utility/marketplace_design.dart';
import '../../utility/extensions.dart';
import '../../widget/custom_text_field.dart';
import 'cards.dart';

class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool marketStyle;

  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: marketStyle ? MarketPalette.blueDeep : AppColor.darkOrange,
            ),
          ),
        ),
        CustomCard(
          marketStyle: marketStyle,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class AddressFormFields extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final String? Function(String?)? validator;
  final VoidCallback? onMapPick;
  final bool marketStyle;

  const AddressFormFields({
    super.key,
    required this.phoneController,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.postalCodeController,
    required this.countryController,
    this.validator,
    this.onMapPick,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map picker button
        if (onMapPick != null) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onMapPick,
              icon: Icon(Icons.map_outlined,
                  color:
                      marketStyle ? MarketPalette.blue : AppColor.darkOrange),
              label: Text(
                context.l10n.choose_on_map,
                style: TextStyle(
                    color: marketStyle
                        ? MarketPalette.blueDeep
                        : AppColor.darkOrange),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                    color:
                        marketStyle ? MarketPalette.blue : AppColor.darkOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: phoneController,
          marketStyle: marketStyle,
          labelText: context.l10n.phone,
          inputType: TextInputType.phone,
          validator: validator ??
              (value) =>
                  value!.isEmpty ? context.l10n.please_enter_phone : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: streetController,
          marketStyle: marketStyle,
          labelText: context.l10n.street,
          validator: validator ??
              (value) =>
                  value!.isEmpty ? context.l10n.please_enter_street : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: cityController,
          marketStyle: marketStyle,
          labelText: context.l10n.city,
          validator: validator ??
              (value) => value!.isEmpty ? context.l10n.please_enter_city : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: stateController,
          marketStyle: marketStyle,
          labelText: context.l10n.state,
          validator: validator ??
              (value) =>
                  value!.isEmpty ? context.l10n.please_enter_state : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: postalCodeController,
                marketStyle: marketStyle,
                labelText: context.l10n.postal_code,
                inputType: TextInputType.number,
                validator: validator ??
                    (value) {
                      // Postal code is optional - allow null or empty
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      return null;
                    },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: countryController,
                marketStyle: marketStyle,
                labelText: context.l10n.country,
                validator: validator ??
                    (value) => value!.isEmpty
                        ? context.l10n.please_enter_country
                        : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
