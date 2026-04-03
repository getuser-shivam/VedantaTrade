# Database Schema Design - VedantaTrade App

## 📊 **Database Overview**

**Database:** PostgreSQL  
**ORM:** Prisma (for Node.js)  
**Migration Strategy:** Database migrations  

---

## 🗂️ **Core Tables**

### **1. Users Table**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### **2. Addresses Table**
```sql
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) DEFAULT 'home', -- home, work, other
    name VARCHAR(255), -- Address nickname
    street_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_user_default ON addresses(user_id, is_default);
```

### **3. Categories Table**
```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    parent_id INTEGER REFERENCES categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);
```

### **4. Products Table**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description TEXT,
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    category_id INTEGER REFERENCES categories(id),
    brand VARCHAR(100),
    weight DECIMAL(8,3), -- in grams
    dimensions JSONB, -- {"length": 10, "width": 5, "height": 2}
    ingredients TEXT,
    dosage_instructions TEXT,
    side_effects TEXT,
    contraindications TEXT,
    images JSONB, -- Array of image URLs
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    tags TEXT[], -- Array of tags
    average_rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_is_featured ON products(is_featured);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_average_rating ON products(average_rating);
CREATE INDEX idx_products_tags ON products USING GIN(tags);
CREATE INDEX idx_products_search ON products USING GIN(to_tsvector('english', name || ' ' || description));
```

### **5. Product_Variants Table**
```sql
CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g., "500mg", "1000mg", "60 capsules"
    sku VARCHAR(100) UNIQUE,
    price_modifier DECIMAL(10,2) DEFAULT 0,
    stock_quantity INTEGER DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_product_variants_product_id ON product_variants(product_id);
```

### **6. Orders Table**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'pending',
    -- Status: pending, confirmed, processing, shipped, delivered, cancelled, refunded
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    -- Payment status: pending, paid, failed, refunded
    shipping_address_id INTEGER REFERENCES addresses(id),
    billing_address_id INTEGER REFERENCES addresses(id),
    promo_code VARCHAR(50),
    notes TEXT,
    estimated_delivery TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE UNIQUE INDEX idx_orders_order_number ON orders(order_number);
```

### **7. Order_Items Table**
```sql
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    variant_id INTEGER REFERENCES product_variants(id),
    product_name VARCHAR(255) NOT NULL, -- Snapshot for historical accuracy
    product_sku VARCHAR(100),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    product_image TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### **8. Reviews Table**
```sql
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    order_id INTEGER REFERENCES orders(id), -- To ensure only purchased products can be reviewed
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified BOOLEAN DEFAULT FALSE, -- Verified purchase
    helpful_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE UNIQUE INDEX idx_reviews_unique_user_product ON reviews(user_id, product_id);
```

### **9. Review_Helpful Table**
```sql
CREATE TABLE review_helpful (
    id SERIAL PRIMARY KEY,
    review_id INTEGER REFERENCES reviews(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(review_id, user_id)
);

-- Indexes
CREATE INDEX idx_review_helpful_review_id ON review_helpful(review_id);
CREATE INDEX idx_review_helpful_user_id ON review_helpful(user_id);
```

### **10. Cart_Items Table**
```sql
CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    variant_id INTEGER REFERENCES product_variants(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id, variant_id)
);

-- Indexes
CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);
```

### **11. Wishlist_Items Table**
```sql
CREATE TABLE wishlist_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Indexes
CREATE INDEX idx_wishlist_items_user_id ON wishlist_items(user_id);
CREATE INDEX idx_wishlist_items_product_id ON wishlist_items(product_id);
```

### **12. Notifications Table**
```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- order_status, promotion, new_product, price_drop, etc.
    is_read BOOLEAN DEFAULT FALSE,
    data JSONB, -- Additional data for the notification
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

### **13. Promo_Codes Table**
```sql
CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL, -- percentage, fixed_amount
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    max_discount_amount DECIMAL(10,2),
    usage_limit INTEGER, -- NULL for unlimited
    usage_count INTEGER DEFAULT 0,
    user_limit INTEGER DEFAULT 1, -- Uses per user
    is_active BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP,
    applicable_products INTEGER[], -- Product IDs, empty for all
    applicable_categories INTEGER[], -- Category IDs, empty for all
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_promo_codes_code ON promo_codes(code);
CREATE INDEX idx_promo_codes_is_active ON promo_codes(is_active);
CREATE INDEX idx_promo_codes_valid_until ON promo_codes(valid_until);
```

### **14. Product_Views Table (Analytics)**
```sql
CREATE TABLE product_views (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id), -- NULL for anonymous users
    session_id VARCHAR(255), -- For anonymous tracking
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(50) DEFAULT 'app' -- app, web, etc.
);

-- Indexes
CREATE INDEX idx_product_views_product_id ON product_views(product_id);
CREATE INDEX idx_product_views_user_id ON product_views(user_id);
CREATE INDEX idx_product_views_viewed_at ON product_views(viewed_at);
```

---

## 🔗 **Relationships & Constraints**

### **Foreign Key Relationships**
- `addresses.user_id` → `users.id`
- `products.category_id` → `categories.id`
- `product_variants.product_id` → `products.id`
- `orders.user_id` → `users.id`
- `orders.shipping_address_id` → `addresses.id`
- `orders.billing_address_id` → `addresses.id`
- `order_items.order_id` → `orders.id`
- `order_items.product_id` → `products.id`
- `reviews.product_id` → `products.id`
- `reviews.user_id` → `users.id`
- `reviews.order_id` → `orders.id`
- `cart_items.user_id` → `users.id`
- `cart_items.product_id` → `products.id`
- `wishlist_items.user_id` → `users.id`
- `wishlist_items.product_id` → `products.id`
- `notifications.user_id` → `users.id`
- `product_views.product_id` → `products.id`
- `product_views.user_id` → `users.id`

### **Triggers & Functions**

```sql
-- Function to update product rating when reviews are added/updated
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET average_rating = (
        SELECT COALESCE(AVG(rating), 0)
        FROM reviews
        WHERE product_id = NEW.product_id AND is_active = TRUE
    ),
    review_count = (
        SELECT COUNT(*)
        FROM reviews
        WHERE product_id = NEW.product_id AND is_active = TRUE
    )
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_rating_trigger
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'ORD' || TO_CHAR(NEW.created_at, 'YYYYMMDD') || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_order_number_trigger
    AFTER INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();
```

---

## 📈 **Indexes Strategy**

### **Performance Indexes**
- Primary keys (automatically indexed)
- Foreign keys (automatically indexed)
- Frequently queried columns
- Composite indexes for common query patterns
- Partial indexes for active records
- GIN indexes for array and JSONB columns
- Full-text search indexes

### **Maintenance**
- Regular index analysis and optimization
- Monitor query performance
- Update statistics regularly

---

## 🔒 **Security Considerations**

### **Row Level Security (RLS)**
```sql
-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policies for users table
CREATE POLICY users_own_data ON users FOR ALL USING (id = current_user_id());
```

### **Data Validation**
- Input sanitization at API level
- Database constraints and triggers
- Data encryption for sensitive fields
- Audit logging for critical operations

---

## 📊 **Data Migration Strategy**

### **Initial Data Population**
1. Categories and subcategories
2. Products with variants
3. Sample users for testing
4. Sample orders and reviews

### **Migration Scripts**
- Version-controlled migration files
- Rollback capabilities
- Data integrity checks
- Performance impact assessment

This schema provides a robust foundation for the VedantaTrade e-commerce platform with proper relationships, constraints, and performance optimizations.
