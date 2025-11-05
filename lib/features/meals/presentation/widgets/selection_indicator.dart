import 'package:flutter/material.dart';

class SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const SelectionIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // A simple checkmark icon to indicate selection.
    // This can be customized to be an overlay or other visual feedback.
    return isSelected
        ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
        : const SizedBox.shrink();
  }
}
