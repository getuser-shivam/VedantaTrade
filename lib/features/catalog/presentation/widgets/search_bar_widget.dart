import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isVisible;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.isVisible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? MediaQuery.of(context).size.width * 0.9 : 0,
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isVisible
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppTheme.textSecondaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      onPressed: controller.clear,
                      icon: Icon(
                        Icons.clear,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
