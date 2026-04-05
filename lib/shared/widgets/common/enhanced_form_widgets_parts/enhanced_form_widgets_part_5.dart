  final Color? borderColor;
  final Color? errorColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
  final String Function(String)? onChanged;
  final VoidCallback? onEditingComplete;

  const _AnimatedTextField({
    Key? key,
    required this.controller,
    required this.validator,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.focusNode,
    this.backgroundColor,
    this.borderColor,
    this.errorColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
    this.onChanged,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<double> _labelAnimation;
  late Animation<Color> _borderColorAnimation;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _labelAnimation = Tween<double>(
      begin: 12.0,
      end: 14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? Colors.grey,
      end: widget.focusColor ?? Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused != _isFocused) {
      setState(() {
        _isFocused = isFocused;
      });
      
      if (isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();