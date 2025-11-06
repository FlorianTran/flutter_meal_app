import 'package:flutter/material.dart';

class SelectionSummaryBar extends StatelessWidget {
  final int selectionCount;
  final int mealCount;
  final VoidCallback onActionPressed;

  const SelectionSummaryBar({
    super.key,
    required this.selectionCount,
    required this.mealCount,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // This bar is displayed at the bottom of the ingredients selection page.
    // It shows the number of selected ingredients and matching meals.
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selectionCount ingredients selected', style: const TextStyle(color: Colors.white)),
              Text('$mealCount meals available', style: const TextStyle(color: Colors.white)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: selectionCount > 0 ? onActionPressed : null,
          ),
        ],
      ),
    );
  }
}
