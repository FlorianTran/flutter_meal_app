import 'package:flutter/material.dart';

/// Search bar widget with debouncing
class MealSearchBar extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const MealSearchBar({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search meals...',
  });

  @override
  State<MealSearchBar> createState() => _MealSearchBarState();
}

class _MealSearchBarState extends State<MealSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      setState(() {}); // Update UI when text changes
    });
  }

  @override
  void didUpdateWidget(MealSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller when initialValue changes externally (e.g., when filter clears search)
    // Don't update while user is typing to preserve focus
    if (widget.initialValue != oldWidget.initialValue &&
        !_focusNode.hasFocus &&
        widget.initialValue != _controller.text) {
      if (widget.initialValue == null || widget.initialValue!.isEmpty) {
        _controller.clear();
      } else {
        _controller.text = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          widget.onChanged?.call(value);
        },
      ),
    );
  }
}
