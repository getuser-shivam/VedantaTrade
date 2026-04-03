-- Distribution and Marketing Management Schema for VedantaTrade
-- Extends existing schema with distribution and marketing capabilities

-- Distribution Centers Table
CREATE TABLE distribution_centers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    phone VARCHAR(50),
    email VARCHAR(255),
    manager_name VARCHAR(255),
    capacity DECIMAL(15,2) DEFAULT 0, -- Storage capacity in units
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory Allocations Table (tracks product distribution to centers)
CREATE TABLE inventory_allocations (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    center_id INTEGER REFERENCES distribution_centers(id) ON DELETE CASCADE,
    quantity_allocated INTEGER NOT NULL DEFAULT 0,
    quantity_available INTEGER NOT NULL DEFAULT 0,
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, center_id)
);

-- Marketing Campaigns Table
CREATE TABLE marketing_campaigns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    campaign_type VARCHAR(50) NOT NULL, -- PRODUCT_LAUNCH, SEASONAL, PROMOTION, AWARENESS
    status VARCHAR(50) DEFAULT 'DRAFT', -- DRAFT, ACTIVE, PAUSED, COMPLETED
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2) DEFAULT 0,
    actual_cost DECIMAL(12,2) DEFAULT 0,
    target_audience TEXT, -- JSON array of target demographics
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Campaign Products Table (products featured in campaigns)
CREATE TABLE campaign_products (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES marketing_campaigns(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    special_pricing DECIMAL(10,2),
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(campaign_id, product_id)
);

-- Sales Analytics Table
CREATE TABLE sales_analytics (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    center_id INTEGER REFERENCES distribution_centers(id) ON DELETE CASCADE,
    campaign_id INTEGER REFERENCES marketing_campaigns(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    units_sold INTEGER DEFAULT 0,
    revenue DECIMAL(12,2) DEFAULT 0,
    cost DECIMAL(12,2) DEFAULT 0,
    profit DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory Movements Table (tracks stock movements)
CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    center_id INTEGER REFERENCES distribution_centers(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL, -- IN, OUT, TRANSFER, ADJUSTMENT, RETURN
    quantity INTEGER NOT NULL, -- Positive for IN, negative for OUT
    reference_type VARCHAR(50), -- ORDER, PURCHASE, TRANSFER, ADJUSTMENT
    reference_id INTEGER, -- ID of the reference document/order
    reason TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Distribution Routes Table (optimal delivery routes)
CREATE TABLE distribution_routes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    center_id INTEGER REFERENCES distribution_centers(id) ON DELETE CASCADE,
    route_type VARCHAR(50) DEFAULT 'DELIVERY', -- DELIVERY, PICKUP, TRANSFER
    areas_covered TEXT, -- JSON array of areas/regions
    estimated_time_hours DECIMAL(4,2) DEFAULT 0,
    vehicle_type VARCHAR(100),
    driver_id INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Route Orders Table (orders assigned to routes)
CREATE TABLE route_orders (
    id SERIAL PRIMARY KEY,
    route_id INTEGER REFERENCES distribution_routes(id) ON DELETE CASCADE,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    sequence_number INTEGER DEFAULT 0, -- Order in which to deliver
    status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, ASSIGNED, IN_PROGRESS, COMPLETED
    assigned_at TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Marketing Metrics Table
CREATE TABLE marketing_metrics (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES marketing_campaigns(id) ON DELETE CASCADE,
    metric_type VARCHAR(50) NOT NULL, -- VIEWS, CLICKS, CONVERSIONS, ENGAGEMENT
    metric_value DECIMAL(15,2) DEFAULT 0,
    recorded_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Returns Processing Table
CREATE TABLE returns_processing (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    return_reason VARCHAR(100) NOT NULL, -- DAMAGED, EXPIRED, WRONG_ITEM, CUSTOMER_RETURN
    return_condition VARCHAR(100), -- EXCELLENT, GOOD, ACCEPTABLE, POOR
    quantity_returned INTEGER NOT NULL,
    refund_amount DECIMAL(10,2) DEFAULT 0,
    restock_fee DECIMAL(10,2) DEFAULT 0,
    processed_by INTEGER REFERENCES users(id),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Indexes for performance
CREATE INDEX idx_distribution_centers_active ON distribution_centers(is_active);
CREATE INDEX idx_inventory_allocations_product ON inventory_allocations(product_id);
CREATE INDEX idx_inventory_allocations_center ON inventory_allocations(center_id);
CREATE INDEX idx_marketing_campaigns_status ON marketing_campaigns(status);
CREATE INDEX idx_marketing_campaigns_dates ON marketing_campaigns(start_date, end_date);
CREATE INDEX idx_sales_analytics_date ON sales_analytics(date);
CREATE INDEX idx_sales_analytics_product ON sales_analytics(product_id);
CREATE INDEX idx_sales_analytics_center ON sales_analytics(center_id);
CREATE INDEX idx_inventory_movements_date ON inventory_movements(created_at);
CREATE INDEX idx_inventory_movements_product ON inventory_movements(product_id);
CREATE INDEX idx_distribution_routes_center ON distribution_routes(center_id);
CREATE INDEX idx_returns_processing_date ON returns_processing(processed_at);
