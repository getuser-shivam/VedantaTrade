
class _GlassInputState extends State<_GlassInput> {
  bool _isFocused = false;
  late AnimationController _focusController;
  late Animation<double> _borderAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderColor = widget.borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveFocusColor = widget.focusColor ?? Theme.of(context).primaryColor;
    final effectiveBorderRadius = widget.borderRadius ?? 12.0;
    
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: Border.all(
              color: _isFocused ? effectiveFocusColor : effectiveBorderColor,
              width: _isFocused ? _borderAnimation.value : 1.0,
            ),
            boxShadow: _isFocused && widget.enableFocusAnimation ? [
              BoxShadow(
                color: effectiveFocusColor.withOpacity(_glowAnimation.value),
                blurRadius: 10.0,
                offset: const Offset(0, 0),
                spreadRadius: 2.0,
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: Colors.white70) : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon, color: Colors.white70),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onTap: () {
              setState(() {
                _isFocused = true;
              });
              if (widget.enableFocusAnimation) {
                _focusController.forward();
              }
            },
            onFieldSubmitted: (_) {
              setState(() {
                _isFocused = false;
              });
              if (widget.enableFocusAnimation) {
                _focusController.reverse();