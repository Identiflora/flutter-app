import 'package:flutter/material.dart';

class DisabledButton extends StatelessWidget {
  final bool enableCondition;
  final String labelText;
  final void Function()? onPressed;

  /// Creates a [DisabledButton]
  ///
  /// Elevated button that is disabled based on the value of enableCondition.
  /// * [enableCondition] button is active when true, inactive when false.
  /// * [labelText] is the text displayed on the button.
  /// * [onPressed] function to execute when button is active and pressed.
  const DisabledButton({
    super.key,
    required this.enableCondition,
    required this.labelText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enableCondition ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide(
          color: enableCondition
              ? Theme.of(context).colorScheme.onSurface
              : Colors.transparent,
          width: 4.0,
        ),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 18,
          color: enableCondition
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
