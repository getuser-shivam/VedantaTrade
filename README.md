# Neutralitical App

A modern Flutter e-commerce application for Neutralitical health supplements, marketed by Vedanta TradeLink.

## Features

- 🏪 **Product Catalog**: Browse comprehensive health supplement catalog
- 🎯 **Featured Products**: Highlighted premium products with carousel
- 🔍 **Search & Filter**: Find products by name or category
- 📱 **Product Details**: Detailed product information with ingredients
- 🛒 **Shopping Cart**: Add to cart functionality
- 🎨 **Modern UI**: Clean, professional design with Material 3

## Products Included

### Featured Products
- **ARGIVIT** (Sachets) - Prenatal Care
- **MEGA-O** (Softgel) - Omega Supplements  
- **MYOBOOST** (Sachets) - Women's Health
- **UTIVA-BV PLUS** (Capsules) - Urinary Health
- **Zeo Plus** (Softgel) - Bone Health

### Additional Products
- **OFFER-XT** (Tablets) - Iron Supplements
- **Vferty** (Softgel) - Fertility Support
- **Vfertil-M** (Tablets) - Men's Health
- **ZEOCAL-500** (Tablets) - Calcium Supplements

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/getuser-shivam/VedantaTrade.git
cd VedantaTrade/neutralitical_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── product.dart         # Product data model
├── providers/
│   └── product_provider.dart # State management
├── screens/
│   ├── home_screen.dart     # Main catalog screen
│   └── product_detail_screen.dart # Product details
└── widgets/
    ├── product_card.dart    # Product grid item
    └── category_chip.dart   # Category filter chip
```

## Dependencies

- `flutter` - Flutter framework
- `google_fonts` - Custom typography
- `provider` - State management
- `go_router` - Navigation and routing
- `cached_network_image` - Image caching
- `card_swiper` - Featured products carousel
- `flutter_svg` - SVG support

## Design System

### Colors
- **Primary**: #2E7D32 (Green)
- **Secondary**: #1976D2 (Blue)
- **Surface**: White
- **Background**: #F5F5F5 (Light Grey)

### Typography
- **Font Family**: Poppins (via Google Fonts)
- **Headings**: Bold weights
- **Body**: Regular weights

## Features Implementation

### State Management
Uses Provider pattern for reactive state management with `ProductProvider` handling product data and operations.

### Navigation
Implements Go Router for declarative routing with support for deep linking and browser navigation.

### Responsive Design
- Adaptive layouts for different screen sizes
- Grid layout for product catalog
- Scrollable content areas

### Product Data
Products include:
- Basic info (name, category, form)
- Detailed ingredients list
- Pricing information
- Dosage and packaging details
- Featured product flags

## Future Enhancements

- [ ] User authentication
- [ ] Shopping cart persistence
- [ ] Order management
- [ ] Payment integration
- [ ] Product reviews and ratings
- [ ] Wishlist functionality
- [ ] Push notifications
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

**Vedanta TradeLink**
- Marketing and Distribution
- Health Supplements Division
