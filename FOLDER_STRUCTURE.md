lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_sizes.dart
│   │   └── api_endpoints.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── product.dart
│   │   ├── user.dart
│   │   ├── cart_item.dart
│   │   ├── order.dart
│   │   ├── review.dart
│   │   └── notification.dart
│   ├── providers/
│   │   ├── product_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── wishlist_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── order_provider.dart
│   │   ├── review_provider.dart
│   │   └── notification_provider.dart
│   └── repositories/
│       └── local_storage_repository.dart
├── ui/
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── search_screen.dart
│   │   ├── auth/
│   │   │   ├── auth_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── cart/
│   │   │   ├── cart_screen.dart
│   │   │   └── checkout_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── order_history_screen.dart
│   │   │   └── notifications_screen.dart
│   │   └── reviews/
│       │   ├── add_review_screen.dart
│       │   └── reviews_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_message.dart
│   │   ├── products/
│   │   │   ├── product_card.dart
│   │   │   ├── product_grid.dart
│   │   │   ├── category_chip.dart
│   │   │   └── product_image_carousel.dart
│   │   ├── cart/
│   │   │   ├── cart_item_widget.dart
│   │   │   └── cart_summary.dart
│   │   ├── reviews/
│   │   │   ├── review_widget.dart
│   │   │   ├── rating_bar.dart
│   │   │   └── rating_summary_widget.dart
│   │   ├── navigation/
│   │   │   ├── bottom_navigation_bar.dart
│   │   │   ├── app_drawer.dart
│   │   │   └── custom_app_bar.dart
│   │   └── dialogs/
│       │   ├── confirmation_dialog.dart
│       │   ├── filter_dialog.dart
│       │   └── sort_dialog.dart
│   ├── views/
│       └── splash_view.dart
├── services/
│   ├── notification_service.dart
│   ├── analytics_service.dart
│   └── api_service.dart
└── main.dart
