import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../models/variant_option.dart';

/// Categories where buyers commonly expect to pick a size and/or color,
/// mirroring which mock products in the marketplace carry variants today.
const _kVariantCategories = {'Clothing', 'Beauty', 'Food & Bev'};

const _kSizePresets = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

/// Beauty/skin care sells by volume, not garment size.
const _kAmountPresets = [
  '15 ml',
  '30 ml',
  '50 ml',
  '100 ml',
  '200 ml',
  '500 ml',
];

/// Food & Bev sells by pack weight/volume, and has no color option.
const _kPackSizePresets = ['250 g', '500 g', '1 kg', '5 kg', '25 kg', '50 kg'];

/// A color the seller can offer, with the `#RRGGBB` hex the backend stores.
class VariantColor {
  const VariantColor(this.name, this.color, this.hex);

  final String name;
  final Color color;
  final String hex;
}

const _kColorPalette = [
  VariantColor('White', Color(0xFFFFFFFF), '#FFFFFF'),
  VariantColor('Black', Color(0xFF1A1A1A), '#1A1A1A'),
  VariantColor('Gray', Color(0xFF9E9E9E), '#9E9E9E'),
  VariantColor('Navy', Color(0xFF243B55), '#243B55'),
  VariantColor('Blue', Color(0xFF2F6FED), '#2F6FED'),
  VariantColor('Red', Color(0xFFB3261E), '#B3261E'),
  VariantColor('Green', Color(0xFF2F5233), '#2F5233'),
  VariantColor('Yellow', Color(0xFFF2C438), '#F2C438'),
  VariantColor('Beige', Color(0xFFE8DCC8), '#E8DCC8'),
  VariantColor('Brown', Color(0xFF6F4E37), '#6F4E37'),
  VariantColor('Pink', Color(0xFFEBA3B3), '#EBA3B3'),
  VariantColor('Sky Blue', Color(0xFF7EC8E3), '#7EC8E3'),
];

String _hexOf(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

enum _SizeKind { size, amount, packSize }

/// Holds the seller's size/color picks for a category, shared by the
/// Add Listing and Co-Buy Create/Edit forms.
class VariantOptionsController extends ChangeNotifier {
  String? _category;
  final Set<String> _selectedSizes = {};
  final List<String> _customSizes = [];
  final Set<String> _selectedColorNames = {};
  final List<VariantColor> _customColors = [];

  bool get showVariants => _kVariantCategories.contains(_category);
  bool get _usesAmounts => _category == 'Beauty';
  bool get _usesPackSizes => _category == 'Food & Bev';
  bool get showColors => !_usesPackSizes;

  _SizeKind get _sizeKind => _usesPackSizes
      ? _SizeKind.packSize
      : _usesAmounts
      ? _SizeKind.amount
      : _SizeKind.size;

  List<String> get _sizePresets => _usesPackSizes
      ? _kPackSizePresets
      : _usesAmounts
      ? _kAmountPresets
      : _kSizePresets;

  List<String> get _availableSizes => [
    ..._sizePresets,
    for (final size in _customSizes)
      if (!_sizePresets.contains(size)) size,
  ];

  List<VariantColor> get _availableColors => [
    ..._kColorPalette,
    ..._customColors,
  ];

  /// Selected sizes, in the order they're shown.
  List<String> get sizes => [
    for (final size in _availableSizes)
      if (_selectedSizes.contains(size)) size,
  ];

  /// Selected colors, in the order they're shown.
  List<VariantColor> get colors => [
    for (final color in _availableColors)
      if (_selectedColorNames.contains(color.name)) color,
  ];

  void setCategory(String? value) {
    final previousPresets = _sizePresets;
    _category = value;
    // Clothing sizes, Beauty amounts and Food pack sizes aren't
    // interchangeable, so drop any picks when switching between them.
    if (!identical(previousPresets, _sizePresets)) {
      _selectedSizes.clear();
      _customSizes.clear();
    }
    if (!showColors) {
      _selectedColorNames.clear();
      _customColors.clear();
    }
    if (!showVariants) {
      _selectedSizes.clear();
      _customSizes.clear();
      _selectedColorNames.clear();
      _customColors.clear();
    }
    notifyListeners();
  }

  /// Pre-selects an existing item's variants (e.g. when editing), adding any
  /// that aren't presets as custom options.
  void load({
    required String? category,
    required List<String> sizes,
    required List<ProductColorOption> colors,
  }) {
    _category = category;
    _selectedSizes
      ..clear()
      ..addAll(sizes);
    _customSizes
      ..clear()
      ..addAll(sizes.where((s) => !_sizePresets.contains(s)));
    _selectedColorNames.clear();
    _customColors.clear();
    for (final option in colors) {
      final hex = _hexOf(option.color);
      final match = _kColorPalette.where(
        (c) => c.name == option.name || c.hex == hex,
      );
      if (match.isNotEmpty) {
        _selectedColorNames.add(match.first.name);
      } else {
        _customColors.add(VariantColor(option.name, option.color, hex));
        _selectedColorNames.add(option.name);
      }
    }
    notifyListeners();
  }

  void _toggleSize(String size) {
    if (!_selectedSizes.remove(size)) _selectedSizes.add(size);
    notifyListeners();
  }

  void _toggleColor(String name) {
    if (!_selectedColorNames.remove(name)) _selectedColorNames.add(name);
    notifyListeners();
  }

  void _addSize(String size) {
    if (!_availableSizes.contains(size)) _customSizes.add(size);
    _selectedSizes.add(size);
    notifyListeners();
  }

  void _addColor(Color picked) {
    final hex = _hexOf(picked);
    final existing = _availableColors.where((c) => c.hex == hex);
    if (existing.isEmpty) {
      _customColors.add(VariantColor(hex, picked, hex));
      _selectedColorNames.add(hex);
    } else {
      _selectedColorNames.add(existing.first.name);
    }
    notifyListeners();
  }
}

/// The category-aware size/color picker section: clothing sizes, beauty
/// amounts or food pack sizes, plus colors where they apply. Renders
/// nothing for categories without variants.
class VariantOptionsEditor extends StatefulWidget {
  const VariantOptionsEditor({
    super.key,
    required this.controller,
    this.topSpacing = 24,
  });

  final VariantOptionsController controller;

  /// Gap above the section, only applied when it's shown.
  final double topSpacing;

  @override
  State<VariantOptionsEditor> createState() => _VariantOptionsEditorState();
}

class _VariantOptionsEditorState extends State<VariantOptionsEditor> {
  bool _isSizeDialogOpen = false;
  bool _isColorDialogOpen = false;

  VariantOptionsController get _controller => widget.controller;

  Future<void> _showAddSizeDialog() async {
    // Guards against a second dialog stacking on top of the first — e.g. a
    // fast double-tap on the "+" chip — which otherwise makes Cancel look
    // stuck: it only pops the top dialog, leaving an identical one behind.
    if (_isSizeDialogOpen) return;
    _isSizeDialogOpen = true;

    try {
      final added = await showDialog<String>(
        context: context,
        builder: (dialogContext) =>
            _AddSizeDialog(kind: _controller._sizeKind),
      );
      if (added == null || added.isEmpty) return;
      _controller._addSize(added);
    } finally {
      _isSizeDialogOpen = false;
    }
  }

  Future<void> _showAddColorDialog() async {
    if (_isColorDialogOpen) return;
    _isColorDialogOpen = true;

    try {
      final picked = await showDialog<Color>(
        context: context,
        builder: (dialogContext) => const _AddColorDialog(),
      );
      if (picked == null) return;
      _controller._addColor(picked);
    } finally {
      _isColorDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (!_controller.showVariants) return const SizedBox.shrink();
        final kind = _controller._sizeKind;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: widget.topSpacing),
            Text(
              switch (kind) {
                _SizeKind.packSize => l10n.addListingVariantsLabelFood,
                _SizeKind.amount => l10n.addListingVariantsLabelBeauty,
                _SizeKind.size => l10n.addListingVariantsLabel,
              },
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.warmBlack,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.addListingVariantsHelper,
              style: textTheme.bodySmall?.copyWith(color: AppColors.roseMist),
            ),
            const SizedBox(height: 12),
            Text(
              switch (kind) {
                _SizeKind.packSize => l10n.addListingPackSizeLabel,
                _SizeKind.amount => l10n.addListingAmountLabel,
                _SizeKind.size => l10n.variantSizeLabel,
              },
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warmBlack,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final size in _controller._availableSizes)
                  _SizeToggleChip(
                    label: size,
                    selected: _controller._selectedSizes.contains(size),
                    onTap: () => _controller._toggleSize(size),
                  ),
                _AddSizeChip(
                  label: switch (kind) {
                    _SizeKind.packSize => l10n.addListingAddPackSizeChip,
                    _SizeKind.amount => l10n.addListingAddAmountChip,
                    _SizeKind.size => l10n.addListingAddSizeChip,
                  },
                  onTap: _showAddSizeDialog,
                ),
              ],
            ),
            if (_controller.showColors) ...[
              const SizedBox(height: 24),
              Text(
                l10n.variantColorLabel,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warmBlack,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final palette in _controller._availableColors)
                    _ColorToggleSwatch(
                      name: palette.name,
                      color: palette.color,
                      selected: _controller._selectedColorNames.contains(
                        palette.name,
                      ),
                      onTap: () => _controller._toggleColor(palette.name),
                    ),
                  _AddColorSwatch(onTap: _showAddColorDialog),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SizeToggleChip extends StatelessWidget {
  const _SizeToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.brandCrimson : Colors.white,
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
              color: selected ? AppColors.brandCrimson : AppColors.roseDivider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: selected ? Colors.white : AppColors.warmBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddSizeChip extends StatelessWidget {
  const _AddSizeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.brandCrimson),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.brandCrimson),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.brandCrimson,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorToggleSwatch extends StatelessWidget {
  const _ColorToggleSwatch({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = color.computeLuminance() > 0.6;
    final checkColor = isLight ? Colors.black87 : Colors.white;

    return Tooltip(
      message: name,
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
              color: selected ? AppColors.brandCrimson : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isLight ? AppColors.roseDivider : Colors.transparent,
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

class _AddColorSwatch extends StatelessWidget {
  const _AddColorSwatch({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandCrimson, width: 1.5),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, size: 18, color: AppColors.brandCrimson),
      ),
    );
  }
}

class _AddColorDialog extends StatefulWidget {
  const _AddColorDialog();

  @override
  State<_AddColorDialog> createState() => _AddColorDialogState();
}

class _AddColorDialogState extends State<_AddColorDialog> {
  Color _color = AppColors.brandCrimson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addListingAddColorDialogTitle),
      content: SingleChildScrollView(
        child: ColorPicker(
          color: _color,
          onColorChanged: (color) => setState(() => _color = color),
          pickersEnabled: const {
            ColorPickerType.wheel: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
          },
          enableShadesSelection: false,
          showColorCode: true,
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            longPressMenu: true,
          ),
          width: 36,
          height: 36,
          borderRadius: 18,
          wheelDiameter: 220,
          wheelWidth: 18,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_color),
          child: Text(l10n.addListingAddSizeConfirm),
        ),
      ],
    );
  }
}

class _AddSizeDialog extends StatefulWidget {
  const _AddSizeDialog({this.kind = _SizeKind.size});

  final _SizeKind kind;

  @override
  State<_AddSizeDialog> createState() => _AddSizeDialogState();
}

class _AddSizeDialogState extends State<_AddSizeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(switch (widget.kind) {
        _SizeKind.size => l10n.addListingAddSizeDialogTitle,
        _SizeKind.amount => l10n.addListingAddAmountDialogTitle,
        _SizeKind.packSize => l10n.addListingAddPackSizeDialogTitle,
      }),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: switch (widget.kind) {
            _SizeKind.size => l10n.addListingAddSizeDialogHint,
            _SizeKind.amount => l10n.addListingAddAmountDialogHint,
            _SizeKind.packSize => l10n.addListingAddPackSizeDialogHint,
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.addListingAddSizeConfirm),
        ),
      ],
    );
  }
}
