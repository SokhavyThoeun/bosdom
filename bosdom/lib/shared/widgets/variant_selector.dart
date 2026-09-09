import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/variant_option.dart';

/// Size/color variant picker shown between the product info card and the
/// specifications card on both the product detail and co-buy detail screens.
/// Renders nothing when the product has neither sizes nor colors to choose.
class ProductVariantSelector extends StatelessWidget {
  const ProductVariantSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.colorOptions,
    required this.selectedColor,
    required this.onColorSelected,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;
  final List<ProductColorOption> colorOptions;
  final ProductColorOption? selectedColor;
  final ValueChanged<ProductColorOption> onColorSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  bool get hasSizes => sizes.isNotEmpty;
  bool get hasColors => colorOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasSizes && !hasColors) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.variantSelectOptionsTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasColors) ...[
            const SizedBox(height: 16),
            _VariantGroupLabel(
              label: l10n.variantColorLabel,
              value: selectedColor?.name,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final option in colorOptions)
                  _ColorSwatch(
                    option: option,
                    selected: option.name == selectedColor?.name,
                    onTap: () => onColorSelected(option),
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ],
          if (hasSizes) ...[
            SizedBox(height: hasColors ? 20 : 16),
            _VariantGroupLabel(
              label: l10n.variantSizeLabel,
              value: selectedSize,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final size in sizes)
                  _SizeChip(
                    label: size,
                    selected: size == selectedSize,
                    onTap: () => onSizeSelected(size),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VariantGroupLabel extends StatelessWidget {
  const _VariantGroupLabel({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final String? value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (value != null) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colorScheme.primary : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  final ProductColorOption option;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isLight = option.color.computeLuminance() > 0.6;
    final checkColor = isLight ? Colors.black87 : Colors.white;

    return Tooltip(
      message: option.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: option.color,
              border: Border.all(
                color: isLight ? colorScheme.outline : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Icon(Icons.check, size: 16, color: checkColor)
                : null,
          ),
        ),
      ),
    );
  }
}
