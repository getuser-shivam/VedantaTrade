import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;

  ProductProvider() {
    _loadProducts();
  }

  void _loadProducts() {
    _products = [
      Product(
        id: '1',
        name: 'ARGIVIT',
        category: 'Prenatal Care',
        form: 'Sachets',
        ingredients: ['Folic Acid 200 mcg', 'L-Arginine 3gm', 'Zinc 10mg/5gm'],
        description: 'Essential nutrients for maternal health and fetal development',
        imageUrl: 'assets/images/argivit.png',
        price: 299.00,
        featured: true,
        dosage: 'One sachet daily',
        packaging: '30 sachets per box',
      ),
      Product(
        id: '2',
        name: 'MEGA-O',
        category: 'Omega Supplements',
        form: 'Softgel Capsules',
        ingredients: ['Omega-3 Fatty Acid', 'Fish Oil', 'Vitamin & Minerals'],
        description: 'Premium omega-3 supplement for heart and brain health',
        imageUrl: 'assets/images/mega_o.png',
        price: 450.00,
        featured: true,
        dosage: 'One capsule twice daily',
        packaging: '60 softgels per bottle',
      ),
      Product(
        id: '3',
        name: 'MYOBOOST',
        category: 'Women\'s Health',
        form: 'Sachets',
        ingredients: ['Myo-Inositol 2 gm', 'Folic Acid 400 mcg', 'Vitamin D3 1000 I.U.'],
        description: 'Supports ovarian health and hormonal balance',
        imageUrl: 'assets/images/myoboost.png',
        price: 350.00,
        featured: true,
        dosage: 'One sachet daily',
        packaging: '30 sachets per box',
      ),
      Product(
        id: '4',
        name: 'OFFER-XT',
        category: 'Iron Supplements',
        form: 'Tablets',
        ingredients: ['Ferrous Ascorbate 100mg', 'Folic Acid 1000mcg', 'Zinc Sulphate 22.5mg'],
        description: 'Comprehensive iron supplement for anemia management',
        imageUrl: 'assets/images/offer_xt.png',
        price: 180.00,
        featured: false,
        dosage: 'One tablet daily',
        packaging: '30 tablets per strip',
      ),
      Product(
        id: '5',
        name: 'UTIVA-BV PLUS',
        category: 'Urinary Health',
        form: 'Capsules',
        ingredients: [
          'Cranberry (Vaccinium Macrocarpon) 300mg',
          'D-Mannose 250mg',
          'Polydextrose 150mg',
          'Probiotic Blend 56mg',
          'Proprietary Probiotic Blend 10 Billion CFU'
        ],
        description: 'Advanced urinary tract health support with probiotics',
        imageUrl: 'assets/images/utiva_bv_plus.png',
        price: 550.00,
        featured: true,
        dosage: 'One capsule twice daily',
        packaging: '30 capsules per bottle',
      ),
      Product(
        id: '6',
        name: 'Vferty',
        category: 'Fertility Support',
        form: 'Softgel Capsules',
        ingredients: [
          'Omega 3 Fatty Acids 150mg',
          'L-Arginine 100mg',
          'Co-Q10 50mg',
          'Chastberry Ext. 50mg',
          'Wheat Germ Oil 25mg',
          'Vitamin E 15mg',
          'Mixed Carotenoids 10mg',
          'Piperine 5mg',
          'Lycopene 5000mcg',
          'Sodium Selenite 65mcg'
        ],
        description: 'Comprehensive fertility support for women',
        imageUrl: 'assets/images/vferty.png',
        price: 750.00,
        featured: false,
        dosage: 'One capsule twice daily',
        packaging: '60 softgels per bottle',
      ),
      Product(
        id: '7',
        name: 'Vfertil-M',
        category: 'Men\'s Health',
        form: 'Tablets',
        ingredients: [
          'L-Carnitine L-Tartrate 250mg',
          'Acetyl-L-Carnitine 200mg',
          'L-Arginine 125mg',
          'Coenzyme Q10 100mg',
          'Citric Acid 50mg',
          'Zinc Sulphate 20mg',
          'Glutathione 12.5mg',
          'Vit. E 200mg',
          'Lycopene 5000mcg',
          'Folic Acid 200mcg',
          'Selenium 200mcg',
          'Omega 3 Fatty Acid 150mg'
        ],
        description: 'Male fertility and reproductive health support',
        imageUrl: 'assets/images/vfertil_m.png',
        price: 680.00,
        featured: false,
        dosage: 'One tablet twice daily',
        packaging: '60 tablets per bottle',
      ),
      Product(
        id: '8',
        name: 'Zeo Plus',
        category: 'Bone Health',
        form: 'Softgel Capsules',
        ingredients: [
          'Calcium Carbonate 500mg',
          'Cholecalciferol 1000 IU',
          'Vitamin K2-7 45mcg',
          'Folic Acid 400 mcg',
          'Boron 1.5mg'
        ],
        description: 'Advanced bone health formula with essential vitamins',
        imageUrl: 'assets/images/zeo_plus.png',
        price: 420.00,
        featured: true,
        dosage: 'One capsule twice daily',
        packaging: '60 softgels per bottle',
      ),
      Product(
        id: '9',
        name: 'ZEOCAL-500',
        category: 'Calcium Supplements',
        form: 'Tablets',
        ingredients: ['Calcium Carbonate 1250mg', 'Vitamin D3 6.25mcg'],
        description: 'High potency calcium supplement for bone strength',
        imageUrl: 'assets/images/zeocal_500.png',
        price: 250.00,
        featured: false,
        dosage: 'One tablet twice daily',
        packaging: '30 tablets per strip',
      ),
    ];

    _featuredProducts = _products.where((product) => product.featured).toList();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<String> getCategories() {
    return _products.map((product) => product.category).toSet().toList();
  }
}
