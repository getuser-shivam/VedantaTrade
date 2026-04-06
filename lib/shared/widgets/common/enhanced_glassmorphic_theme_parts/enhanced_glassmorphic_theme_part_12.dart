    required this.children,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.enableHover = true,
    this.enableSeparators = true,
    this.separatorHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? Colors.white).withOpacity(0.05),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
        border: Border.all(
          color: (widget.borderColor ?? Colors.white).withOpacity(0.1),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.children.length,
        separatorBuilder: (context, index) {
          if (!widget.enableSeparators || index == widget.children.length - 1) {
            return const SizedBox.shrink();
          }
          return Container(
            height: widget.separatorHeight ?? 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          );
        },
        itemBuilder: (context, index) {
          Widget item = widget.children[index];
          
          if (widget.enableHover) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item,
              ),
            );
          }
          
          return item;
        },
      ),
    );
  }
}

class _GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String)? validator;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableFocusAnimation;
  final Duration? animationDuration;

  const _GlassInput({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableFocusAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_GlassInput> createState() => _GlassInputState();
}
