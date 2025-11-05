import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget to display meal instructions in a formatted way
class MealInstructions extends StatelessWidget {
  final String? instructions;

  const MealInstructions({
    super.key,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    if (instructions == null || instructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Split instructions by newlines and numbers to create steps
    final steps = _parseInstructions(instructions!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _InstructionStep(
            stepNumber: index + 1,
            instruction: step,
          );
        }),
      ],
    );
  }

  /// Parse instructions into steps
  /// Handles both numbered and paragraph formats
  List<String> _parseInstructions(String instructions) {
    // Try to split by numbered list (1., 2., etc.)
    final numberedPattern = RegExp(r'^\d+[\.\)]\s*', multiLine: true);
    if (numberedPattern.hasMatch(instructions)) {
      return instructions
          .split(numberedPattern)
          .where((step) => step.trim().isNotEmpty)
          .map((step) => step.trim())
          .toList();
    }

    // Try to split by double newlines (paragraphs)
    final paragraphs = instructions
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .map((p) => p.trim())
        .toList();

    if (paragraphs.length > 1) {
      return paragraphs;
    }

    // Fallback: split by single newlines
    return instructions
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
  }
}

class _InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _InstructionStep({
    required this.stepNumber,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number badge
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Instruction text
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
