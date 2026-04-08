import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/product_catalog_provider.dart';
import '../../../shared/theme/enhanced_app_theme.dart';

/// Smart Search Bar with AI-powered suggestions
class SmartSearchBar extends StatefulWidget {
  final String? initialValue;
  final Function(String)? onSearch;
  final Function(String)? onSuggestionSelected;
  final Function()? onVoiceSearch;
  final Function()? onBarcodeSearch;
  final bool enableVoiceSearch;
  final bool enableBarcodeSearch;
  final bool enableSuggestions;
  final String? placeholder;
  final EdgeInsets? padding;
  final bool autofocus;
  final int maxSuggestions;

  const SmartSearchBar({
    Key? key,
    this.initialValue,
    this.onSearch,
    this.onSuggestionSelected,
    this.onVoiceSearch,
    this.onBarcodeSearch,
    this.enableVoiceSearch = false,
    this.enableBarcodeSearch = false,
    this.enableSuggestions = true,
    this.placeholder,
    this.padding,
    this.autofocus = false,
    this.maxSuggestions = 8,
  }) : super(key: key);

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late AnimationController _suggestionController;
  late Animation<double> _suggestionAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final SpeechToText _speechToText = SpeechToText();

  List<String> _suggestions = [];
  List<String> _recentSearches = [];
  bool _isListening = false;
  bool _isScanning = false;
  bool _showSuggestions = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _loadRecentSearches();
    _initSpeechRecognition();
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _initSpeechRecognition() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _suggestionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadRecentSearches() async {
    // Load recent searches from secure storage
    // This would be implemented with secure storage service
    setState(() {
      _recentSearches = [
        'Paracetamol 500mg',
        'Amoxicillin',
        'Vitamin C',
        'Blood Pressure Monitor',
        'Surgical Gloves',
      ];
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    if (widget.enableSuggestions) {
      _fetchSuggestions(query);
    }
  }

  void _fetchSuggestions(String query) {
    final provider = context.read<ProductCatalogProvider>();
    
    // Get suggestions from provider (would include AI-powered suggestions)
    final suggestions = provider.getSearchSuggestions(query, widget.maxSuggestions);
    
    setState(() {
      _suggestions = suggestions;
      _showSuggestions = true;
    });

    _suggestionController.forward();
  }

  void _hideSuggestions() {
    _suggestionController.reverse();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _addToRecentSearches(query);
    _hideSuggestions();
    _focusNode.unfocus();
    
    widget.onSearch?.call(query);
  }

  void _addToRecentSearches(String query) {
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    });
    
    // Save to secure storage
    // This would be implemented with secure storage service
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _hideSuggestions();
    _focusNode.unfocus();
    
    widget.onSuggestionSelected?.call(suggestion);
  }

  void _startVoiceSearch() async {
    if (!widget.enableVoiceSearch || !_speechEnabled) {
      if (!_speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
      }
      return;
    }
    
    setState(() {
      _isListening = true;
    });
    
    _pulseController.repeat(reverse: true);
    
    try {
      HapticFeedback.lightImpact();
      
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        onSoundLevelChange: (level) {
          // Can be used for visual feedback
        },
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      // Handle voice recognition error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice recognition error: ${e.toString()}')),
      );
    } finally {
      _pulseController.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _startBarcodeSearch() async {
    if (!widget.enableBarcodeSearch) return;
    
    setState(() {
      _isScanning = true;
    });
    
    try {
      HapticFeedback.lightImpact();
      
      // Navigate to barcode scanner screen
      // This would integrate with mobile_scanner package
      // For now, we'll use a placeholder that can be enhanced later
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(
            onBarcodeDetected: (barcode) {
              // Return the barcode to the search bar
              Navigator.of(context).pop(barcode);
            },
          ),
        ),
      );
    } catch (e) {
      // Handle barcode scanning error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode scanning error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Search Bar
        Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: (_isListening || _isScanning) ? _pulseAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: _focusNode.hasFocus 
                          ? theme.primaryColor.withOpacity(0.3)
                          : theme.dividerColor.withOpacity(0.1),
                      width: _focusNode.hasFocus ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          _isListening ? Icons.mic : _isScanning ? Icons.qr_code_scanner : Icons.search,
                          color: _isListening || _isScanning 
                              ? theme.primaryColor 
                              : theme.iconTheme.color?.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                      
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          onSubmitted: (_) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: widget.placeholder ?? 'Search products...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // Action Buttons
                      if (widget.enableVoiceSearch || widget.enableBarcodeSearch)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.enableVoiceSearch)
                                IconButton(
                                  onPressed: _isListening ? null : _startVoiceSearch,
                                  icon: Icon(
                                    _isListening ? Icons.stop : Icons.mic,
                                    color: _isListening 
                                        ? theme.primaryColor 
                                        : theme.iconTheme.color?.withOpacity(0.6),
                                  ),
                                ),
                              if (widget.enableBarcodeSearch)
                                IconButton(
                                  onPressed: _isScanning ? null : _startBarcodeSearch,
                                  icon: Icon(
                                    _isScanning ? Icons.stop : Icons.qr_code_scanner,
                                    color: _isScanning 
                                        ? theme.primaryColor 
                                        : theme.iconTheme.color?.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Suggestions Panel
        if (_showSuggestions && _suggestions.isNotEmpty)
          AnimatedBuilder(
            animation: _suggestionAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _suggestionAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Suggestions Header
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Suggestions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      
                      // Suggestions List
                      ..._suggestions.take(widget.maxSuggestions).map((suggestion) {
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.search,
                            size: 16,
                            color: theme.iconTheme.color?.withOpacity(0.6),
                          ),
                          title: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        
        // Recent Searches
        if (_showSuggestions && _suggestions.isEmpty && _recentSearches.isNotEmpty)
          AnimatedBuilder(
            animation: _suggestionAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _suggestionAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Searches Header
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _recentSearches.clear();
                                });
                              },
                              child: const Text('Clear', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      
                      // Recent Searches List
                      ..._recentSearches.take(5).map((search) {
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.history,
                            size: 16,
                            color: theme.iconTheme.color?.withOpacity(0.6),
                          ),
                          title: Text(
                            search,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _recentSearches.remove(search);
                              });
                            },
                          ),
                          onTap: () => _selectSuggestion(search),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
