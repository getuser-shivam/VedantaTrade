import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vedanta_trade/features/reviews/domain/models/review.dart';
import 'package:vedanta_trade/features/authentication/domain/models/user.dart';

class ReviewProvider extends ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  ReviewProvider() {
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsData = prefs.getString('reviews');
      
      if (reviewsData != null) {
        final List<dynamic> decoded = json.decode(reviewsData);
        _reviews = decoded.map((review) => Review.fromJson(review)).toList();
        notifyListeners();
      } else {
        // Add some sample reviews for demo
        _addSampleReviews();
      }
    } catch (e) {
      
    }
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsData = json.encode(_reviews.map((review) => review.toJson()).toList());
      await prefs.setString('reviews', reviewsData);
    } catch (e) {
      
    }
  }

  void _addSampleReviews() {
    final sampleReviews = [
      Review(
        id: '1',
        productId: '1',
        userId: 'user1',
        userName: 'Ramesh Sharma',
        rating: 5,
        comment: 'Excellent product! Very effective during pregnancy. Highly recommend.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        verifiedPurchase: true,
      ),
      Review(
        id: '2',
        productId: '1',
        userId: 'user2',
        userName: 'Priya Patel',
        rating: 4,
        comment: 'Good quality supplements. Noticed improvement in energy levels.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        verifiedPurchase: true,
      ),
      Review(
        id: '3',
        productId: '2',
        userId: 'user3',
        userName: 'Amit Kumar',
        rating: 5,
        comment: 'Best omega-3 supplement in the market. No fishy aftertaste.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        verifiedPurchase: true,
      ),
      Review(
        id: '4',
        productId: '3',
        userId: 'user4',
        userName: 'Sunita Devi',
        rating: 4,
        comment: 'Helped with my PCOS condition. Good quality product.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        verifiedPurchase: true,
      ),
      Review(
        id: '5',
        productId: '5',
        userId: 'user5',
        userName: 'Anjali Singh',
        rating: 5,
        comment: 'Amazing product for urinary health. Works wonders!',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        verifiedPurchase: true,
      ),
    ];

    _reviews = sampleReviews;
    _saveReviews();
    notifyListeners();
  }

  List<Review> getReviewsForProduct(String productId) {
    return _reviews.where((review) => review.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ProductRating getProductRating(String productId) {
    final productReviews = getReviewsForProduct(productId);
    return ProductRating.fromReviews(productReviews);
  }

  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    bool verifiedPurchase = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already reviewed this product
      final existingReview = _reviews.firstWhere(
        (review) => review.productId == productId && review.userId == userId,
        orElse: () => Review(
          id: '',
          productId: '',
          userId: '',
          userName: '',
          rating: 0,
          comment: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existingReview.id.isNotEmpty) {
        // Update existing review
        final updatedReview = existingReview.copyWith(
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
          verifiedPurchase: verifiedPurchase,
        );

        final index = _reviews.indexWhere((review) => review.id == existingReview.id);
        _reviews[index] = updatedReview;
      } else {
        // Add new review
        final newReview = Review(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: productId,
          userId: userId,
          userName: userName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
          verifiedPurchase: verifiedPurchase,
        );

        _reviews.add(newReview);
      }

      await _saveReviews();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markHelpful(String reviewId, String userId) async {
    try {
      final reviewIndex = _reviews.indexWhere((review) => review.id == reviewId);
      if (reviewIndex != -1) {
        final review = _reviews[reviewIndex];
        final updatedVotes = List<String>.from(review.helpfulVotes);
        
        if (updatedVotes.contains(userId)) {
          updatedVotes.remove(userId);
        } else {
          updatedVotes.add(userId);
        }

        _reviews[reviewIndex] = review.copyWith(helpfulVotes: updatedVotes);
        await _saveReviews();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      
      return false;
    }
  }

  bool hasUserReviewed(String productId, String userId) {
    return _reviews.any((review) => 
        review.productId == productId && review.userId == userId);
  }

  Review? getUserReview(String productId, String userId) {
    try {
      return _reviews.firstWhere((review) => 
          review.productId == productId && review.userId == userId);
    } catch (e) {
      return null;
    }
  }

  void clearReviews() {
    _reviews.clear();
    _saveReviews();
    notifyListeners();
  }
}
