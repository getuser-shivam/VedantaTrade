  final String Function(DateTime)? validator;

  const _AnimatedDatePicker({
    Key? key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
    this.validator,
  }) : super(key: key);

  @override
  State<_AnimatedDatePicker> createState() => _AnimatedDatePickerState();
}

class _AnimatedDatePickerState extends State<_AnimatedDatePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: TextEditingController(text: widget.value.toString().split(' ')[0]),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: widget.value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                );
                
                if (picked != null) {
                  widget.onChanged(picked!);
                }
              },
              decoration: InputDecoration(
                labelText: widget.labelText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedFilePicker extends StatefulWidget {
  final String? filePath;
  final ValueChanged<String?> onChanged;