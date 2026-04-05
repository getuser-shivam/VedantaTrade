  final String? labelText;
  final String? hintText;
  final List<String>? allowedExtensions;
  final double? maxFileSize;
  final bool isRequired;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
  final String Function(String?)? validator;

  const _AnimatedFilePicker({
    Key? key,
    this.filePath,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.allowedExtensions,
    this.maxFileSize,
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
  State<_AnimatedFilePicker> createState() => _AnimatedFilePickerState();
}

class _AnimatedFilePickerState extends State<_AnimatedFilePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  Future<void> _pickFile() async {
    // File picker implementation would go here
    // This is a placeholder for the actual file picker logic
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.black54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.filePath ?? widget.hintText ?? 'Select file',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],