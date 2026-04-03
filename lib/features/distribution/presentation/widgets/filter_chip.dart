import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  const FilterChip({
    Key? key,
    required this.label,
    this.selected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.blue[800] : Colors.grey[300],
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
