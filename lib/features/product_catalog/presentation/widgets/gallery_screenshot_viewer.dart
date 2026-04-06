import 'package:flutter/material.dart';
import 'package:vedanta_trade/shared/widgets/premium_glassmorphic_theme.dart';

class GalleryScreenshotViewer extends StatefulWidget {
  final String screenshotPath;
  final String title;
  final String description;

  const GalleryScreenshotViewer({
    Key? key,
    required this.screenshotPath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _GalleryScreenshotViewerState createState() => _GalleryScreenshotViewerState();
}

class _GalleryScreenshotViewerState extends State<GalleryScreenshotViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PremiumGlassmorphicTheme.cardColor.withOpacity(0.95),
                      PremiumGlassmorphicTheme.cardColor.withOpacity(0.85),
                    ],
                  ),
                  border: Border.all(
                    color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumGlassmorphicTheme.shadowColor,
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildScreenshot(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
            PremiumGlassmorphicTheme.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image,
            color: PremiumGlassmorphicTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.errorColor.withOpacity(0.2),
                    PremiumGlassmorphicTheme.errorColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                color: PremiumGlassmorphicTheme.errorColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshot() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
              PremiumGlassmorphicTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Placeholder for screenshot
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PremiumGlassmorphicTheme.cardColor.withOpacity(0.3),
                      PremiumGlassmorphicTheme.cardColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 120,
                      color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.4),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Screenshot Preview',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.screenshotPath.split('/').last,
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                            PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download,
                            color: PremiumGlassmorphicTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Download Full Resolution',
                            style: TextStyle(
                              color: PremiumGlassmorphicTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Zoom controls overlay
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
                        PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Zoom out functionality
                        },
                        child: Icon(
                          Icons.zoom_out,
                          color: PremiumGlassmorphicTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Zoom in functionality
                        },
                        child: Icon(
                          Icons.zoom_in,
                          color: PremiumGlassmorphicTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: PremiumGlassmorphicTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.successColor.withOpacity(0.2),
                    PremiumGlassmorphicTheme.successColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PremiumGlassmorphicTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: PremiumGlassmorphicTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Details',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.successColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryImageProvider {
  static Future<void> showScreenshotViewer(
    BuildContext context, {
    required String screenshotPath,
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GalleryScreenshotViewer(
        screenshotPath: screenshotPath,
        title: title,
        description: description,
      ),
    );
  }
}
