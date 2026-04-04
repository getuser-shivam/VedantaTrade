import 'package:flutter/material.dart';
import '../screens/product_catalog_screen.dart';
import '../screens/product_detail_screen.dart';

class ProductCatalogRoutes {
  static const String catalog = '/catalog';
  static const String productDetail = '/catalog/product';
  static const String addProduct = '/catalog/add';
  static const String editProduct = '/catalog/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      catalog: (context) => const ProductCatalogScreen(),
      productDetail: (context) {
        final productId = ModalRoute.of(context)?.settings.arguments as String?;
        return ProductDetailScreen(productId: productId);
      },
      addProduct: (context) => const ProductDetailScreen(),
      editProduct: (context) {
        final productId = ModalRoute.of(context)?.settings.arguments as String?;
        return ProductDetailScreen(productId: productId, isEditing: true);
      },
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case catalog:
        return MaterialPageRoute(
          builder: (context) => const ProductCatalogScreen(),
          settings: settings,
        );
      case productDetail:
        final productId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: productId),
          settings: settings,
        );
      case addProduct:
        return MaterialPageRoute(
          builder: (context) => const ProductDetailScreen(),
          settings: settings,
        );
      case editProduct:
        final productId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: productId, isEditing: true),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static void navigateToCatalog(BuildContext context) {
    Navigator.pushNamed(context, catalog);
  }

  static void navigateToProductDetail(BuildContext context, String productId) {
    Navigator.pushNamed(context, productDetail, arguments: productId);
  }

  static void navigateToAddProduct(BuildContext context) {
    Navigator.pushNamed(context, addProduct);
  }

  static void navigateToEditProduct(BuildContext context, String productId) {
    Navigator.pushNamed(context, editProduct, arguments: productId);
  }
}
