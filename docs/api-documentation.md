# VedantaTrade API Documentation

## Overview

This document provides comprehensive API documentation for the VedantaTrade pharmaceutical distribution platform, including endpoints, authentication, data models, and integration guidelines.

## Base URL

```
Development: https://dev-api.vedantatrade.com
Staging: https://staging-api.vedantatrade.com
Production: https://api.vedantatrade.com
```

## Authentication

### OAuth 2.0 / JWT Authentication

The API uses OAuth 2.0 with JWT tokens for authentication.

#### Endpoints

```http
POST /auth/login
POST /auth/register
POST /auth/refresh
POST /auth/logout
POST /auth/forgot-password
POST /auth/reset-password
```

#### Request Headers

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
```

#### Response Format

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "admin"
    }
  },
  "message": "Login successful"
}
```

## API Endpoints

### Authentication

#### Login

```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "rememberMe": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "refreshToken": "refresh_token_here",
    "expiresIn": 3600,
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "admin",
      "permissions": ["read", "write", "delete"]
    }
  }
}
```

#### Register

```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "Jane Doe",
  "phone": "+9771234567890",
  "role": "stockist"
}
```

#### Refresh Token

```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

### Users

#### Get User Profile

```http
GET /users/profile
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+9771234567890",
    "role": "admin",
    "avatar": "https://example.com/avatar.jpg",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### Update User Profile

```http
PUT /users/profile
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "name": "John Smith",
  "phone": "+9771234567890",
  "avatar": "base64_encoded_image"
}
```

### Products

#### Get Products

```http
GET /products?page=1&limit=20&category=medicine&search=paracetamol
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `category` (string): Filter by category
- `search` (string): Search term
- `sortBy` (string): Sort field (name, price, created_at)
- `sortOrder` (string): Sort order (asc, desc)

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product_123",
        "name": "Paracetamol 500mg",
        "description": "Pain relief medication",
        "category": "medicine",
        "price": 25.50,
        "currency": "NPR",
        "stock": 1000,
        "unit": "tablets",
        "manufacturer": "Pharma Corp",
        "imageUrl": "https://example.com/product.jpg",
        "isActive": true,
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

#### Get Product Details

```http
GET /products/{productId}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "product_123",
    "name": "Paracetamol 500mg",
    "description": "Pain relief medication for adults and children",
    "category": "medicine",
    "subcategory": "analgesic",
    "price": 25.50,
    "currency": "NPR",
    "stock": 1000,
    "unit": "tablets",
    "manufacturer": {
      "id": "manufacturer_123",
      "name": "Pharma Corp",
      "address": "Kathmandu, Nepal"
    },
    "images": [
      "https://example.com/product1.jpg",
      "https://example.com/product2.jpg"
    ],
    "specifications": {
      "dosage": "500mg",
      "form": "tablet",
      "packaging": "10 tablets per strip"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### Create Product

```http
POST /products
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "name": "New Medicine",
  "description": "Description here",
  "category": "medicine",
  "price": 30.00,
  "currency": "NPR",
  "stock": 500,
  "unit": "tablets",
  "manufacturerId": "manufacturer_123",
  "images": ["base64_encoded_image"],
  "specifications": {
    "dosage": "500mg",
    "form": "tablet"
  }
}
```

### Distribution

#### Get Distributions

```http
GET /distributions?page=1&limit=20&status=pending
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "distributions": [
      {
        "id": "dist_123",
        "orderId": "order_123",
        "distributorId": "user_456",
        "status": "in_transit",
        "estimatedDelivery": "2024-01-05T00:00:00Z",
        "trackingNumber": "TRK123456",
        "products": [
          {
            "productId": "product_123",
            "quantity": 100,
            "unit": "tablets"
          }
        ],
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3
    }
  }
}
```

#### Create Distribution

```http
POST /distributions
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "orderId": "order_123",
  "distributorId": "user_456",
  "products": [
    {
      "productId": "product_123",
      "quantity": 100,
      "unit": "tablets"
    }
  ],
  "deliveryAddress": {
    "street": "123 Main St",
    "city": "Kathmandu",
    "country": "Nepal",
    "postalCode": "12345"
  }
}
```

#### Track Shipment

```http
GET /distributions/{distributionId}/tracking
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "trackingNumber": "TRK123456",
    "status": "in_transit",
    "estimatedDelivery": "2024-01-05T00:00:00Z",
    "currentLocation": "Kathmandu, Nepal",
    "trackingHistory": [
      {
        "timestamp": "2024-01-01T10:00:00Z",
        "status": "picked_up",
        "location": "Warehouse, Kathmandu",
        "description": "Package picked up by courier"
      },
      {
        "timestamp": "2024-01-02T14:00:00Z",
        "status": "in_transit",
        "location": "Transit Hub, Pokhara",
        "description": "Package in transit to destination"
      }
    ]
  }
}
```

### Inventory

#### Get Inventory

```http
GET /inventory?page=1&limit=20&lowStock=true
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "inventory": [
      {
        "id": "inv_123",
        "productId": "product_123",
        "productName": "Paracetamol 500mg",
        "currentStock": 150,
        "minimumStock": 50,
        "maximumStock": 1000,
        "unit": "tablets",
        "lastUpdated": "2024-01-01T00:00:00Z",
        "isLowStock": false,
        "needsReorder": false
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

#### Update Inventory

```http
PUT /inventory/{inventoryId}
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "currentStock": 200,
  "minimumStock": 75,
  "maximumStock": 1200
}
```

### Orders

#### Get Orders

```http
GET /orders?page=1&limit=20&status=pending
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order_123",
        "customerId": "user_789",
        "status": "pending",
        "totalAmount": 2550.00,
        "currency": "NPR",
        "items": [
          {
            "productId": "product_123",
            "quantity": 100,
            "unitPrice": 25.50,
            "totalPrice": 2550.00
          }
        ],
        "shippingAddress": {
          "street": "123 Main St",
          "city": "Kathmandu",
          "country": "Nepal",
          "postalCode": "12345"
        },
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 25,
      "totalPages": 2
    }
  }
}
```

#### Create Order

```http
POST /orders
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "customerId": "user_789",
  "items": [
    {
      "productId": "product_123",
      "quantity": 100
    }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Kathmandu",
    "country": "Nepal",
    "postalCode": "12345"
  },
  "paymentMethod": "cash_on_delivery"
}
```

### Campaigns

#### Get Campaigns

```http
GET /campaigns?page=1&limit=20&status=active
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "campaigns": [
      {
        "id": "campaign_123",
        "name": "Winter Medicine Sale",
        "description": "Special discount on winter medicines",
        "status": "active",
        "startDate": "2024-01-01T00:00:00Z",
        "endDate": "2024-01-31T23:59:59Z",
        "discount": {
          "type": "percentage",
          "value": 20
        },
        "targetProducts": ["product_123", "product_456"],
        "targetRegions": ["kathmandu", "pokhara"],
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 10,
      "totalPages": 1
    }
  }
}
```

### Analytics

#### Get Dashboard Analytics

```http
GET /analytics/dashboard?period=monthly
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "monthly",
    "sales": {
      "totalRevenue": 125000.00,
      "totalOrders": 500,
      "averageOrderValue": 250.00,
      "growth": 15.5
    },
    "inventory": {
      "totalProducts": 150,
      "lowStockItems": 12,
      "outOfStockItems": 3,
      "totalValue": 500000.00
    },
    "customers": {
      "totalCustomers": 1200,
      "newCustomers": 45,
      "activeCustomers": 890,
      "retentionRate": 74.2
    },
    "distributions": {
      "totalDistributions": 250,
      "onTimeDeliveries": 235,
      "averageDeliveryTime": 2.5,
      "deliverySuccessRate": 94.0
    }
  }
}
```

## Error Responses

### Standard Error Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `UNAUTHORIZED` | 401 | Authentication required |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

## Rate Limiting

- **Standard Endpoints**: 100 requests per minute
- **Upload Endpoints**: 10 requests per minute
- **Analytics Endpoints**: 50 requests per minute

Rate limit headers are included in responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1640995200
```

## Pagination

All list endpoints support pagination with these parameters:

- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20, max: 100)

Response includes pagination metadata:

```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

## Search and Filtering

### Search Parameters

- `search` (string): General search term
- `category` (string): Filter by category
- `status` (string): Filter by status
- `dateFrom` (string): Filter by date range (ISO 8601)
- `dateTo` (string): Filter by date range (ISO 8601)

### Sorting

- `sortBy` (string): Field to sort by
- `sortOrder` (string): `asc` or `desc`

## Webhooks

### Configure Webhooks

```http
POST /webhooks
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "url": "https://your-app.com/webhook",
  "events": ["order.created", "inventory.low_stock"],
  "secret": "webhook_secret_here"
}
```

### Webhook Events

- `order.created`: New order created
- `order.updated`: Order status updated
- `inventory.low_stock`: Product stock below minimum
- `distribution.delivered`: Shipment delivered
- `user.registered`: New user registered

## SDK Integration

### Flutter SDK Example

```dart
import 'package:vedantatrade_sdk/vedantatrade_sdk.dart';

// Initialize SDK
final vedantaTrade = VedantaTrade(
  apiKey: 'your_api_key',
  baseUrl: 'https://api.vedantatrade.com',
);

// Authentication
final user = await vedantaTrade.auth.login(
  email: 'user@example.com',
  password: 'password123',
);

// Get products
final products = await vedantaTrade.products.getProducts(
  page: 1,
  limit: 20,
  category: 'medicine',
);

// Create order
final order = await vedantaTrade.orders.createOrder(
  customerId: 'user_123',
  items: [
    OrderItem(
      productId: 'product_123',
      quantity: 100,
    ),
  ],
  shippingAddress: ShippingAddress(
    street: '123 Main St',
    city: 'Kathmandu',
    country: 'Nepal',
  ),
);
```

### JavaScript SDK Example

```javascript
import { VedantaTrade } from '@vedantatrade/sdk';

// Initialize SDK
const vedantaTrade = new VedantaTrade({
  apiKey: 'your_api_key',
  baseUrl: 'https://api.vedantatrade.com',
});

// Authentication
const user = await vedantaTrade.auth.login({
  email: 'user@example.com',
  password: 'password123',
});

// Get products
const products = await vedantaTrade.products.getProducts({
  page: 1,
  limit: 20,
  category: 'medicine',
});
```

## Testing

### Test Environment

Use the test environment for development and testing:

```
Base URL: https://test-api.vedantatrade.com
Test API Key: test_api_key_here
```

### Test Data

The test environment includes sample data for testing all endpoints without affecting production data.

## Support

For API support and questions:

- **Documentation**: https://docs.vedantatrade.com
- **Support Email**: api-support@vedantatrade.com
- **Status Page**: https://status.vedantatrade.com
- **Developer Community**: https://community.vedantatrade.com

## Changelog

### Version 1.0.0 (2024-01-01)

- Initial API release
- Authentication endpoints
- Product catalog endpoints
- Order management endpoints
- Distribution tracking endpoints
- Inventory management endpoints
- Analytics endpoints
- Webhook support

### Version 1.1.0 (2024-02-01)

- Added campaign management endpoints
- Enhanced search capabilities
- Improved error handling
- Added bulk operations
- Performance optimizations

### Version 1.2.0 (2024-03-01)

- Added multi-currency support
- Enhanced analytics endpoints
- Added real-time notifications
- Improved rate limiting
- Added API versioning
