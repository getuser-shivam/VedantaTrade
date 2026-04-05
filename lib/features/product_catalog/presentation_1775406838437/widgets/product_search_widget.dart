import 'package:flutter/material.dart';

/// Product Search Widget
class ProductSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onClear;

  const ProductSearchWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.onClear,
  }) : super(key: key);

  @override
  State<ProductSearchWidget> createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends State<ProductSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Search icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Search input
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Search products by name, SKU, or manufacturer...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch(value);
                }
              },
              onSubmitted: (value) {
                widget.onSearch(value);
              },
            ),
          ),
          
          // Clear button
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                widget.controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                }
              },
            ),
        ],
      ),
    );
  }
}
