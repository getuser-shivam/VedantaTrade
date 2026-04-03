import 'package:flutter/material.dart';

class AppSpacing {
  // Base spacing unit (4px)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Custom spacing values
  static const double spacing_2 = 2.0;
  static const double spacing_3 = 3.0;
  static const double spacing_6 = 6.0;
  static const double spacing_10 = 10.0;
  static const double spacing_12 = 12.0;
  static const double spacing_14 = 14.0;
  static const double spacing_18 = 18.0;
  static const double spacing_20 = 20.0;
  static const double spacing_28 = 28.0;
  static const double spacing_36 = 36.0;
  static const double spacing_40 = 40.0;
  static const double spacing_44 = 44.0;
  static const double spacing_56 = 56.0;
  static const double spacing_72 = 72.0;
  static const double spacing_80 = 80.0;
  static const double spacing_96 = 96.0;

  // Padding and Margin shortcuts
  static const EdgeInsets paddingAllXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMD = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(xl);

  static const EdgeInsets marginAllXS = EdgeInsets.all(xs);
  static const EdgeInsets marginAllSM = EdgeInsets.all(sm);
  static const EdgeInsets marginAllMD = EdgeInsets.all(md);
  static const EdgeInsets marginAllLG = EdgeInsets.all(lg);
  static const EdgeInsets marginAllXL = EdgeInsets.all(xl);

  // Symmetric padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Symmetric margin
  static const EdgeInsets marginHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets marginHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets marginHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets marginHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets marginVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets marginVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets marginVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets marginVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Custom padding combinations
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
  static const EdgeInsets paddingCardSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingCardLG = EdgeInsets.all(lg);

  static const EdgeInsets paddingScreen = EdgeInsets.all(lg);
  static const EdgeInsets paddingScreenSM = EdgeInsets.all(md);
  static const EdgeInsets paddingScreenLG = EdgeInsets.all(xl);

  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingButtonLG = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets paddingButtonSM = EdgeInsets.symmetric(horizontal: sm, vertical: xs);

  static const EdgeInsets paddingInput = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingInputLG = EdgeInsets.symmetric(horizontal: md, vertical: md);

  // Custom margin combinations
  static const EdgeInsets marginCard = EdgeInsets.all(md);
  static const EdgeInsets marginCardSM = EdgeInsets.all(sm);
  static const EdgeInsets marginCardLG = EdgeInsets.all(lg);

  static const EdgeInsets marginBetweenCards = EdgeInsets.only(bottom: md);
  static const EdgeInsets marginBetweenCardsSM = EdgeInsets.only(bottom: sm);
  static const EdgeInsets marginBetweenCardsLG = EdgeInsets.only(bottom: lg);

  static const EdgeInsets marginBetweenSections = EdgeInsets.only(bottom: xl);
  static const EdgeInsets marginBetweenSectionsSM = EdgeInsets.only(bottom: lg);
  static const EdgeInsets marginBetweenSectionsLG = EdgeInsets.only(bottom: xxl);

  // Edge insets for specific use cases
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(lg);
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: md, vertical: xs);

  // Responsive spacing helpers
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return paddingAllMD;
    } else if (width < 1200) {
      return paddingAllLG;
    } else {
      return EdgeInsets.symmetric(horizontal: xxxl, vertical: lg);
    }
  }

  static EdgeInsets responsiveCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return paddingCardSM;
    } else {
      return paddingCard;
    }
  }

  // Utility methods
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets only({double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }
}

class AppBorderRadius {
  // Border radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double round = 999.0;

  // Common border radius
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusXXXL = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius radiusRound = BorderRadius.all(Radius.circular(round));

  // Component-specific border radius
  static const BorderRadius radiusCard = radiusLG;
  static const BorderRadius radiusCardSM = radiusMD;
  static const BorderRadius radiusCardLG = radiusXL;

  static const BorderRadius radiusButton = radiusMD;
  static const BorderRadius radiusButtonSM = radiusSM;
  static const BorderRadius radiusButtonLG = radiusLG;

  static const BorderRadius radiusInput = radiusMD;
  static const BorderRadius radiusChip = radiusSM;
  static const BorderRadius radiusDialog = radiusXL;
  static const BorderRadius radiusBottomSheet = BorderRadius.vertical(top: Radius.circular(xxl));

  // Utility methods
  static BorderRadius circular(double radius) => BorderRadius.all(Radius.circular(radius));
  static BorderRadius only({double topLeft = 0, double topRight = 0, double bottomLeft = 0, double bottomRight = 0}) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}

class AppSizes {
  // Common sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // Button sizes
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;

  // Input field sizes
  static const double inputHeightSM = 36.0;
  static const double inputHeightMD = 44.0;
  static const double inputHeightLG = 52.0;

  // Card sizes
  static const double cardHeightSM = 120.0;
  static const double cardHeightMD = 160.0;
  static const double cardHeightLG = 200.0;

  // Avatar sizes
  static const double avatarXS = 24.0;
  static const double avatarSM = 32.0;
  static const double avatarMD = 40.0;
  static const double avatarLG = 48.0;
  static const double avatarXL = 56.0;
  static const double avatarXXL = 64.0;

  // Image sizes
  static const double imageThumbnail = 60.0;
  static const double imageSmall = 120.0;
  static const double imageMedium = 240.0;
  static const double imageLarge = 480.0;

  // Breakpoints
  static const double mobile = 600.0;
  static const double tablet = 1200.0;
  static const double desktop = 1920.0;

  // Utility methods
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= mobile && MediaQuery.of(context).size.width < tablet;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= tablet;

  static double getWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getHeight(BuildContext context) => MediaQuery.of(context).size.height;
}
