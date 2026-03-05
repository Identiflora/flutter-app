import 'package:flutter/material.dart';
import 'package:identiflora/theme/neon_theme.dart';

class NeonIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  // The IconData is required, but size and color are optional
  const NeonIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    // 1. Grab the theme extension internally
    final neonTheme = Theme.of(context).extension<NeonTheme>();

    // 2. Fall back to your secondary color if no specific color is provided
    final iconColor = color ?? Theme.of(context).colorScheme.secondary;

    // 3. Return the standard Flutter Icon with the styling applied
    return Icon(
      icon,
      size: size ?? 24.0, // Default Flutter icon size
      color: iconColor,
      shadows: neonTheme?.iconGlow,
    );
  }
}

class NeonContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const NeonContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Grab the theme extension
    final neonTheme = Theme.of(context).extension<NeonTheme>();

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        border:
            border ??
            Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 1.5,
            ),

        // 5. Apply the neon glow from the theme
        boxShadow: neonTheme?.containerGlow,
      ),
      child: child,
    );
  }
}

class NeonInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  /// Creates a [NeonInputField]
  ///
  /// Standard input field Neon to match Identiflora theme.
  /// * [controller] is the text controller used to read and manipulate the input.
  /// * [labelText] is the text displayed indicating what the input field is for.
  const NeonInputField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    // Grab the theme extension for the glow
    final neonTheme = Theme.of(context).extension<NeonTheme>();

    // Removed the hardcoded Padding wrapper!
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        // Apply the uniform glow behind the input field
        boxShadow: neonTheme?.containerGlow,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText),
      ),
    );
  }
}

class NeonOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String labelText;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderWidth;

  const NeonOutlinedButton({
    super.key,
    required this.onPressed,
    required this.labelText,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.0);
    final effectiveFontSize = fontSize ?? 12.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.normal;
    final effectiveBorderWidth = borderWidth ?? 1.5;

    return Container(
      // 1. The Container now handles BOTH the shadow and the border
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface, // Blocks inner shadow bleed
        borderRadius: effectiveRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary, // Green border
          width: effectiveBorderWidth,
        ),
        boxShadow: neonTheme?.buttonGlow,
      ),

      // 2. TextButton provides the text and the click ripple effect without bringing its own borders
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          // 3. This forces Flutter to remove the invisible thumb padding!
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
          textStyle: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
          ),
        ),
        child: Text(labelText),
      ),
    );
  }
}

class NeonDropdownMenu extends StatelessWidget {
  final void Function(String selection)? onSelected;
  final String labelText;
  final List<String> options;

  /// Creates a [NeonDropdownMenu]
  ///
  /// Standard dropdown menu decorated to match Identiflora theme.
  /// * [onSelected] is the function to be executed upon selection.
  /// * [labelText] is the text displayed indicating what the dropdown menu is for.
  /// * [options] are the options for the dropdown menu.
  const NeonDropdownMenu({
    super.key,
    required this.onSelected,
    required this.labelText,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final sortedOptions = List<String>.from(options)..sort();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: neonTheme?.dropdownGlow,
          ),

          child: DropdownMenu<String>(
            width: constraints.maxWidth,
            label: Text(labelText),
            onSelected: (String? value) {
              if (value != null) {
                onSelected?.call(value);
              }
            },
            dropdownMenuEntries: sortedOptions.map<DropdownMenuEntry<String>>((
              String option,
            ) {
              return DropdownMenuEntry<String>(value: option, label: option);
            }).toList(),
          ),
        );
      },
    );
  }
}

class NeonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const NeonSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return NeonContainer(
      backgroundColor: Colors.transparent,
      border: Border.all(color: Colors.transparent, width: 0),
      borderRadius: BorderRadius.circular(30.0),
      child: Switch(
        value: value,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        activeThumbColor: Theme.of(context).colorScheme.primary,
        activeTrackColor: Theme.of(context).colorScheme.secondary,
        onChanged: (value) {
          onChanged?.call(value);
        },
      ),
    );
  }
}
