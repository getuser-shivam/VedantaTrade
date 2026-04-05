      }
    }
  }

  void _validateText(String value) {
    if (!widget.enableValidation) return;
    
    final error = widget.validator(value);
    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.validator(widget.controller.text);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            border: Border.all(
              color: _errorText != null
                  ? (widget.errorColor ?? Colors.red)
                  : _borderColorAnimation.value,
              width: _isFocused ? _borderAnimation.value : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (widget.focusColor ?? Colors.blue).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: _labelAnimation.value,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: Colors.black54)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon, color: Colors.black54),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              labelStyle: TextStyle(
                fontSize: _labelAnimation.value,
                color: _isFocused ? (widget.focusColor ?? Colors.blue) : Colors.black54,
              ),
              hintStyle: const TextStyle(color: Colors.black38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              _validateText(value);
              widget.onChanged?.call(value);
            },
            onEditingComplete: widget.onEditingComplete,
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for other enhanced form widgets
class _AnimatedDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isSearchable;
  final String Function(T)? searchFilter;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;

  const _AnimatedDropdown({
    Key? key,
    required this.value,