import 'package:flutter/material.dart';
import 'package:identiflora/theme/neon_theme.dart';

class NeonIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const NeonIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();
    final iconColor = color ?? Theme.of(context).colorScheme.secondary;

    return Icon(
      icon,
      size: size ?? 24.0,
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
  final bool isGlowing;
  final List<BoxShadow>? boxShadow;

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
    this.isGlowing = true,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
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
        boxShadow: isGlowing ? (boxShadow ?? neonTheme?.containerGlow) : null,
      ),
      child: child,
    );
  }
}

class NeonInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool? obscureText;
  final Widget? suffixIcon;

  /// Creates a [NeonInputField]
  ///
  /// Standard input field Neon to match Identiflora theme.
  /// * [controller] is the text controller used to read and manipulate the input.
  /// * [labelText] is the text displayed indicating what the input field is for.
  const NeonInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: neonTheme?.containerGlow,
      ),
      child: TextField(
        obscureText: obscureText != null ? obscureText! : false,
        controller: controller,
        decoration: InputDecoration(
          hintText: labelText,
          suffixIcon: suffixIcon,
        ),
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
  final Widget? icon;

  /// Creates a [NeonOutlinedButton]
  ///
  /// Standard outlined button styled Neon to match Identiflora theme.
  const NeonOutlinedButton({
    super.key,
    required this.onPressed,
    required this.labelText,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.borderWidth,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.0);
    final effectiveFontSize = fontSize ?? 15.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.normal;
    final effectiveBorderWidth = borderWidth ?? 1.5;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: effectiveBorderWidth,
        ),
        boxShadow: neonTheme?.buttonGlow,
      ),

      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          // padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
          textStyle: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
          ),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: icon as Widget,
                  ),
                  Text(labelText),
                ],
              )
            : Text(labelText),
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

  /// Creates a [NeonSwitch]
  ///
  /// Standard Switch decorated to match Identiflora theme.
  /// * [value] is initial state of the switch.
  /// * [onChanged] is the function to execute when switch is pressed.
  const NeonSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final neonTheme = Theme.of(context).extension<NeonTheme>();
    final double padding = neonTheme?.containerPadding?.toDouble() ?? 3.0;

    final List<BoxShadow>? switchGlow =
        neonTheme?.containerGlow != null &&
            neonTheme!.containerGlow!.length >= 2
        ? [
            // Secondary color shadow
            BoxShadow(
              color: neonTheme.containerGlow![0].color,
              offset: neonTheme.containerGlow![0].offset,
              blurRadius: neonTheme.containerGlow![0].blurRadius * 5,
              spreadRadius: neonTheme.containerGlow![0].spreadRadius * 12,
            ),
            // Primary color shadow
            BoxShadow(
              color: neonTheme.containerGlow![1].color,
              offset: neonTheme.containerGlow![1].offset,
              blurRadius: neonTheme.containerGlow![1].blurRadius * 4,
              spreadRadius: neonTheme.containerGlow![1].spreadRadius * 10,
            ),
          ]
        : neonTheme?.containerGlow;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Stack(
        alignment: Alignment.center,
        children: [
          NeonContainer(
            isGlowing: value,
            boxShadow: switchGlow,
            width: 30,
            height: 12,
            backgroundColor: Colors.transparent,
            border: Border.all(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          Switch(
            value: value,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            activeTrackColor: Theme.of(context).colorScheme.secondary,
            onChanged: (value) {
              onChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
