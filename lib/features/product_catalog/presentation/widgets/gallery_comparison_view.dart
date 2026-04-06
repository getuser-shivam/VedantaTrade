import 'package:flutter/material.dart';
import 'package:vedanta_trade/shared/widgets/premium_glassmorphic_theme.dart';

class GalleryComparisonView extends StatefulWidget {
  final String beforeScreenshot;
  final String afterScreenshot;
  final String beforeVersion;
  final String afterVersion;
  final List<String> improvements;

  const GalleryComparisonView({
    Key? key,
    required this.beforeScreenshot,
    required this.afterScreenshot,
    required this.beforeVersion,
    required this.afterVersion,
    required this.improvements,
  }) : super(key: key);

  @override
  _GalleryComparisonViewState createState() => _GalleryComparisonViewState();
}

class _GalleryComparisonViewState extends State<GalleryComparisonView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSideBySide = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumGlassmorphicTheme.backgroundGradient,
      appBar: AppBar(
        title: Text(
          'Version Comparison',
          style: TextStyle(
            color: PremiumGlassmorphicTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: PremiumGlassmorphicTheme.backgroundGradient,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PremiumGlassmorphicTheme.primaryColor,
          labelColor: PremiumGlassmorphicTheme.primaryColor,
          unselectedLabelColor: PremiumGlassmorphicTheme.secondaryTextColor,
          tabs: const [
            Tab(text: 'Before'),
            Tab(text: 'After'),
            Tab(text: 'Comparison'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSideBySide = !_showSideBySide;
              });
            },
            icon: Icon(
              _showSideBySide ? Icons.view_agenda : Icons.compare,
              color: PremiumGlassmorphicTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: _showSideBySide ? _buildSideBySideView() : _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildScreenshotView(widget.beforeScreenshot, widget.beforeVersion, 'Before'),
        _buildScreenshotView(widget.afterScreenshot, widget.afterVersion, 'After'),
        _buildComparisonView(),
      ],
    );
  }

  Widget _buildSideBySideView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildScreenshotView(widget.beforeScreenshot, widget.beforeVersion, 'Before'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScreenshotView(widget.afterScreenshot, widget.afterVersion, 'After'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildImprovementsList(),
        ],
      ),
    );
  }

  Widget _buildScreenshotView(String screenshotPath, String version, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
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
                  label == 'Before' ? Icons.history : Icons.new_releases,
                  color: PremiumGlassmorphicTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: PremiumGlassmorphicTheme.primaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        version,
                        style: TextStyle(
                          color: PremiumGlassmorphicTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                            size: 80,
                            color: PremiumGlassmorphicTheme.primaryColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$label Screenshot',
                            style: TextStyle(
                              color: PremiumGlassmorphicTheme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            screenshotPath.split('/').last,
                            style: TextStyle(
                              color: PremiumGlassmorphicTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonHeader(),
          const SizedBox(height: 24),
          _buildImprovementsList(),
          const SizedBox(height: 24),
          _buildSideBySideComparison(),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                      PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.compare,
                  color: PremiumGlassmorphicTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version Comparison',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.beforeVersion} → ${widget.afterVersion}',
                      style: TextStyle(
                        color: PremiumGlassmorphicTheme.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVersionChip(widget.beforeVersion, 'Before', Colors.orange),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: PremiumGlassmorphicTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVersionChip(widget.afterVersion, 'After', Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionChip(String version, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            version,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.8),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Improvements',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.improvements.map((improvement) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumGlassmorphicTheme.successColor.withOpacity(0.2),
                        PremiumGlassmorphicTheme.successColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: PremiumGlassmorphicTheme.successColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    improvement,
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSideBySideComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.8),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visual Comparison',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
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
            child: Row(
              children: [
                Expanded(
                  child: _buildComparisonHalf(
                    widget.beforeScreenshot,
                    widget.beforeVersion,
                    'Before',
                    Colors.orange,
                  ),
                ),
                Container(
                  width: 2,
                  height: double.infinity,
                  color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildComparisonHalf(
                    widget.afterScreenshot,
                    widget.afterVersion,
                    'After',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonHalf(String screenshotPath, String version, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Text(
              '$label - $version',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                    size: 60,
                    color: color.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$label View',
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
