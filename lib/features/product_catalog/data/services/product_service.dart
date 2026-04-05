import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String _baseUrl = 'https://api.vedantatrade.com';
  static const String _apiKey = 'your-api-key-here';

  Future<List<Product>> getProducts({
    String? category,
    String? search,
    String? sortBy,
    bool? inStock,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (inStock != null) queryParams['inStock'] = inStock.toString();

      final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockProducts();
    }
  }

  Future<Product> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      final mockProducts = _getMockProducts();
      return mockProducts.firstWhere(
        (product) => product.id == productId,
        orElse: () => mockProducts.first,
      );
    }
  }

  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['categories'];
        return categoriesJson.map((json) => ProductCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockCategories();
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return getProducts(category: category);
  }

  Future<List<Product>> getLowStockProducts() async {
    return getProducts(inStock: true).then((products) {
      return products.where((product) => product.isLowStock).toList();
    });
  }

  Future<List<Product>> getExpiringSoonProducts() async {
    return getProducts().then((products) {
      return products.where((product) => product.isExpiringSoon).toList();
    });
  }

  Future<List<Product>> getFeaturedProducts() async {
    return getProducts(sortBy: 'rating', limit: 10);
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/products/${product.id}'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(product.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      // Mock update for development
// print('Mock update product: ${product.name}'); // Removed for production
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      // Mock delete for development
// print('Mock delete product: $productId'); // Removed for production
    }
  }

  // Mock data for development
  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Paracetamol 500mg',
        genericName: 'Acetaminophen',
        manufacturer: 'Nepal Pharmaceutical Ltd',
        category: 'Analgesics',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 25.50,
        stockQuantity: 150,
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        description: 'Paracetamol is a common pain reliever and fever reducer.',
        indications: ['Fever', 'Headache', 'Muscle pain', 'Menstrual pain'],
        contraindications: ['Liver disease', 'Allergy to paracetamol'],
        sideEffects: ['Nausea', 'Rash', 'Liver toxicity (high dose)'],
        prescriptionRequired: 'No',
        storageConditions: 'Store at room temperature, away from moisture',
        imageUrl: 'https://example.com/paracetamol.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        regulatoryStatus: 'Approved',
        ndcNumber: 'NP-001-001',
        irdNumber: 'IRD/PHARM/2023/001',
        discountPercentage: 10.0,
        taxRate: 13.0,
        tags: ['pain relief', 'fever', 'otc'],
        rating: 4.5,
        reviewCount: 128,
      ),
      Product(
        id: '2',
        name: 'Amoxicillin 250mg',
        genericName: 'Amoxicillin',
        manufacturer: 'Biosphere Nepal',
        category: 'Antibiotics',
        dosageForm: 'Capsule',
        strength: '250mg',
        price: 85.75,
        stockQuantity: 8,
        batchNumber: 'BATCH002',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        description: 'Amoxicillin is a broad-spectrum antibiotic.',
        indications: ['Bacterial infections', 'Respiratory infections', 'UTI'],
        contraindications: ['Penicillin allergy', 'Mononucleosis'],
        sideEffects: ['Diarrhea', 'Nausea', 'Allergic reaction'],
        prescriptionRequired: 'Yes',
        storageConditions: 'Store below 25°C, protect from light',
        imageUrl: 'https://example.com/amoxicillin.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        regulatoryStatus: 'Approved',
        ndcNumber: 'NP-001-002',
        irdNumber: 'IRD/PHARM/2023/002',
        discountPercentage: 5.0,
        taxRate: 13.0,
        tags: ['antibiotic', 'infection', 'prescription'],
        rating: 4.2,
        reviewCount: 89,
      ),
      Product(
        id: '3',
        name: 'Omeprazole 20mg',
        genericName: 'Omeprazole',
        manufacturer: 'Deurali-Janta Pharmaceuticals',
        category: 'Gastrointestinal',
        dosageForm: 'Capsule',
        strength: '20mg',
        price: 120.00,
        stockQuantity: 75,
        batchNumber: 'BATCH003',
        expiryDate: DateTime.now().add(const Duration(days: 120)),
        description: 'Omeprazole reduces stomach acid production.',
        indications: ['GERD', 'Stomach ulcers', 'Acid reflux'],
        contraindications: ['Liver disease', 'Osteoporosis'],
        sideEffects: ['Headache', 'Diarrhea', 'Abdominal pain'],
        prescriptionRequired: 'Yes',
        storageConditions: 'Store at room temperature',
        imageUrl: 'https://example.com/omeprazole.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        regulatoryStatus: 'Approved',
        ndcNumber: 'NP-001-003',
        irdNumber: 'IRD/PHARM/2023/003',
        discountPercentage: 15.0,
        taxRate: 13.0,
        tags: ['stomach', 'acid reflux', 'ulcer'],
        rating: 4.7,
        reviewCount: 156,
      ),
      Product(
        id: '4',
        name: 'Salbutamol Inhaler 100mcg',
        genericName: 'Albuterol',
        manufacturer: 'Lomus Pharmaceutical',
        category: 'Respiratory',
        dosageForm: 'Inhaler',
        strength: '100mcg/dose',
        price: 350.00,
        stockQuantity: 5,
        batchNumber: 'BATCH004',
        expiryDate: DateTime.now().add(const Duration(days: 25)),
        description: 'Salbutamol is a bronchodilator for asthma relief.',
        indications: ['Asthma', 'COPD', 'Bronchospasm'],
        contraindications: ['Severe heart disease', 'Arrhythmias'],
        sideEffects: ['Tremor', 'Headache', 'Tachycardia'],
        prescriptionRequired: 'Yes',
        storageConditions: 'Store below 30°C, protect from direct sunlight',
        imageUrl: 'https://example.com/salbutamol.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        regulatoryStatus: 'Approved',
        ndcNumber: 'NP-001-004',
        irdNumber: 'IRD/PHARM/2023/004',
        discountPercentage: 0.0,
        taxRate: 13.0,
        tags: ['asthma', 'respiratory', 'inhaler'],
        rating: 4.8,
        reviewCount: 203,
      ),
      Product(
        id: '5',
        name: 'Metformin 500mg',
        genericName: 'Metformin',
        manufacturer: 'Nepal Pharmaceutical Ltd',
        category: 'Antidiabetic',
        dosageForm: 'Tablet',
        strength: '500mg',
        price: 45.25,
        stockQuantity: 200,
        batchNumber: 'BATCH005',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        description: 'Metformin is used to treat type 2 diabetes.',
        indications: ['Type 2 diabetes', 'PCOS'],
        contraindications: ['Kidney disease', 'Metabolic acidosis'],
        sideEffects: ['GI upset', 'Lactic acidosis (rare)', 'B12 deficiency'],
        prescriptionRequired: 'Yes',
        storageConditions: 'Store at room temperature',
        imageUrl: 'https://example.com/metformin.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        regulatoryStatus: 'Approved',
        ndcNumber: 'NP-001-005',
        irdNumber: 'IRD/PHARM/2023/005',
        discountPercentage: 20.0,
        taxRate: 13.0,
        tags: ['diabetes', 'blood sugar', 'metformin'],
        rating: 4.3,
        reviewCount: 167,
      ),
    ];
  }

  List<ProductCategory> _getMockCategories() {
    return [
      ProductCategory(
        id: '1',
        name: 'Analgesics',
        description: 'Pain relievers and fever reducers',
        iconUrl: 'https://example.com/analgesics.png',
        productCount: 45,
        subcategories: ['NSAIDs', 'Opioids', 'Acetaminophen'],
      ),
      ProductCategory(
        id: '2',
        name: 'Antibiotics',
        description: 'Antibacterial medications',
        iconUrl: 'https://example.com/antibiotics.png',
        productCount: 78,
        subcategories: ['Penicillins', 'Cephalosporins', 'Macrolides'],
      ),
      ProductCategory(
        id: '3',
        name: 'Gastrointestinal',
        description: 'Stomach and digestive system medications',
        iconUrl: 'https://example.com/gi.png',
        productCount: 32,
        subcategories: ['Antacids', 'PPIs', 'Antiemetics'],
      ),
      ProductCategory(
        id: '4',
        name: 'Respiratory',
        description: 'Asthma and respiratory medications',
        iconUrl: 'https://example.com/respiratory.png',
        productCount: 28,
        subcategories: ['Bronchodilators', 'Inhaled steroids', 'Antihistamines'],
      ),
      ProductCategory(
        id: '5',
        name: 'Antidiabetic',
        description: 'Diabetes management medications',
        iconUrl: 'https://example.com/diabetes.png',
        productCount: 41,
        subcategories: ['Insulin', 'Oral hypoglycemics', 'GLP-1 agonists'],
      ),
      ProductCategory(
        id: '6',
        name: 'Cardiovascular',
        description: 'Heart and blood pressure medications',
        iconUrl: 'https://example.com/cardio.png',
        productCount: 56,
        subcategories: ['Beta blockers', 'ACE inhibitors', 'Statins'],
      ),
    ];
  }
}
