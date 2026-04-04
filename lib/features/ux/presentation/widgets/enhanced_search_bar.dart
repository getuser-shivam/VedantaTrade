import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class EnhancedSearchBar extends StatefulWidget {
  final String placeholder;
  final Function(String) onSearch;
  final VoidCallback? onFilter;
  final String? initialValue;
  final bool autofocus;
  final List<String>? suggestions;
  final bool showVoiceSearch;
  final bool showCameraSearch;

  const EnhancedSearchBar({
    Key? key,
    required this.placeholder,
    required this.onSearch,
    this.onFilter,
    this.initialValue,
    this.autofocus = false,
    this.suggestions,
    this.showVoiceSearch = false,
    this.showCameraSearch = false,
  }) : super(key: key);

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isFocused = false;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text;
    widget.onSearch(query);
    
    if (widget.suggestions != null) {
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _onFocusChanged() {
    final isFocused = _focusNode.hasFocus;
    
    if (isFocused != _isFocused) {
      setState(() {
        _isFocused = isFocused;
        _showSuggestions = isFocused && _filteredSuggestions.isNotEmpty;
      });
      
      if (isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: PremiumGlassmorphicTheme.glassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumGlassmorphicTheme.spacingMd,
                vertical: PremiumGlassmorphicTheme.spacingSm,
              ),
              child: Column(
                children: [
                  // Main Search Row
                  Row(
                    children: [
                      // Search Icon
                      Icon(
                        Icons.search,
                        color: _isFocused
                            ? PremiumGlassmorphicTheme.indigo500
                            : PremiumGlassmorphicTheme.textTertiary,
                        size: 24,
                      ),
                      
                      const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
                      
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: PremiumGlassmorphicTheme.textTertiary,
                              fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                            ),
                            hintText: widget.placeholder,
                          ),
                          style: const TextStyle(
                            color: PremiumGlassmorphicTheme.textPrimary,
                            fontSize: PremiumGlassmorphicTheme.fontSizeMd,
                          ),
                          onSubmitted: (value) => _handleSearchSubmitted(value),
                        ),
                      ),
                      
                      // Action Buttons
                      if (_controller.text.isNotEmpty) ...[
                        // Clear Button
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXs),
                            decoration: BoxDecoration(
                              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                            ),
                            child: Icon(
                              Icons.clear,
                              color: PremiumGlassmorphicTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                      ],
                      
                      // Voice Search
                      if (widget.showVoiceSearch)
                        GestureDetector(
                          onTap: _startVoiceSearch,
                          child: Container(
                            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXs),
                            decoration: BoxDecoration(
                              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                            ),
                            child: Icon(
                              Icons.mic,
                              color: _isFocused
                                  ? PremiumGlassmorphicTheme.indigo500
                                  : PremiumGlassmorphicTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      
                      if (widget.showVoiceSearch && widget.showCameraSearch)
                        const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                      
                      // Camera Search
                      if (widget.showCameraSearch)
                        GestureDetector(
                          onTap: _startCameraSearch,
                          child: Container(
                            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXs),
                            decoration: BoxDecoration(
                              color: PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: _isFocused
                                  ? PremiumGlassmorphicTheme.indigo500
                                  : PremiumGlassmorphicTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      
                      // Filter Button
                      const SizedBox(width: PremiumGlassmorphicTheme.spacingXs),
                      GestureDetector(
                        onTap: widget.onFilter,
                        child: Container(
                          padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingXs),
                          decoration: BoxDecoration(
                            color: _isFocused
                                ? PremiumGlassmorphicTheme.indigo600.withOpacity(0.2)
                                : PremiumGlassmorphicTheme.surfaceLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: _isFocused
                                ? PremiumGlassmorphicTheme.indigo500
                                : PremiumGlassmorphicTheme.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Search History/Suggestions
                  if (_showSuggestions && _filteredSuggestions.isNotEmpty)
                    _buildSuggestions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: PremiumGlassmorphicTheme.spacingSm),
      decoration: BoxDecoration(
        color: PremiumGlassmorphicTheme.slate800.withOpacity(0.95),
        borderRadius: BorderRadius.circular(PremiumGlassmorphicTheme.radiusMd),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggestions Header
          Container(
            padding: const EdgeInsets.all(PremiumGlassmorphicTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PremiumGlassmorphicTheme.borderMedium,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.textSecondary,
                    fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearSuggestions,
                  child: Icon(
                    Icons.close,
                    color: PremiumGlassmorphicTheme.textTertiary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Suggestions List
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return _buildSuggestionItem(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return GestureDetector(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumGlassmorphicTheme.spacingMd,
          vertical: PremiumGlassmorphicTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: PremiumGlassmorphicTheme.borderLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: PremiumGlassmorphicTheme.textTertiary,
              size: 16,
            ),
            const SizedBox(width: PremiumGlassmorphicTheme.spacingSm),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  color: PremiumGlassmorphicTheme.textPrimary,
                  fontSize: PremiumGlassmorphicTheme.fontSizeSm,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: PremiumGlassmorphicTheme.textTertiary,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchSubmitted(String value) {
    widget.onSearch(value);
    _clearSuggestions();
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    _clearSuggestions();
  }

  void _clearSuggestions() {
    setState(() {
      _showSuggestions = false;
      _filteredSuggestions.clear();
    });
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    widget.onSearch(suggestion);
    _clearSuggestions();
    _focusNode.unfocus();
  }

  void _startVoiceSearch() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon!'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }

  void _startCameraSearch() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera search coming soon!'),
        backgroundColor: PremiumGlassmorphicTheme.success,
      ),
    );
  }
}
