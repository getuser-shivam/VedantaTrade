-- Distribution and Marketing Management System Schema
-- This file contains all tables needed for distribution centers, inventory tracking, 
-- marketing campaigns, and sales analytics

-- Distribution Centers Table
CREATE TABLE IF NOT EXISTS distribution_centers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    code NVARCHAR(50) UNIQUE NOT NULL,
    address NVARCHAR(MAX) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    state NVARCHAR(100) NOT NULL,
    postal_code NVARCHAR(20) NOT NULL,
    country NVARCHAR(100) DEFAULT 'India',
    phone NVARCHAR(50),
    email NVARCHAR(255),
    manager_name NVARCHAR(255),
    capacity FLOAT DEFAULT 0,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Inventory Allocations Table
CREATE TABLE IF NOT EXISTS inventory_allocations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    center_id INT NOT NULL,
    quantity_allocated FLOAT NOT NULL,
    quantity_available FLOAT NOT NULL,
    allocated_at DATETIME DEFAULT GETDATE(),
    last_updated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(id)
);

-- Marketing Campaigns Table
CREATE TABLE IF NOT EXISTS marketing_campaigns (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    start_date DATETIME DEFAULT GETDATE(),
    end_date DATETIME,
    budget FLOAT DEFAULT 0,
    status NVARCHAR(20) DEFAULT 'ACTIVE',
    target_audience NVARCHAR(MAX),
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Campaign Products Table
CREATE TABLE IF NOT EXISTS campaign_products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT NOT NULL,
    product_id INT NOT NULL,
    discount_percentage FLOAT DEFAULT 0,
    special_price FLOAT,
    start_date DATETIME DEFAULT GETDATE(),
    end_date DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id),
    FOREIGN KEY (product_id) REFERENCES inventory_items(item_id)
);

-- Sales Analytics Table
CREATE TABLE IF NOT EXISTS sales_analytics (
    id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT,
    product_id INT NOT NULL,
    center_id INT,
    sales_quantity FLOAT DEFAULT 0,
    revenue FLOAT DEFAULT 0,
    cost FLOAT DEFAULT 0,
    profit FLOAT DEFAULT 0,
    analytics_date DATETIME DEFAULT GETDATE(),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id),
    FOREIGN KEY (product_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(id)
);

-- Inventory Movements Table
CREATE TABLE IF NOT EXISTS inventory_movements (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    from_center_id INT,
    to_center_id INT,
    movement_type NVARCHAR(50) NOT NULL, -- 'TRANSFER', 'SALE', 'RETURN', 'ADJUSTMENT'
    quantity FLOAT NOT NULL,
    reference_id INT, -- Order ID or other reference
    movement_date DATETIME DEFAULT GETDATE(),
    created_by INT,
    notes NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (from_center_id) REFERENCES distribution_centers(id),
    FOREIGN KEY (to_center_id) REFERENCES distribution_centers(id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Distribution Routes Table
CREATE TABLE IF NOT EXISTS distribution_routes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    center_id INT NOT NULL,
    driver_id INT,
    route_type NVARCHAR(20) DEFAULT 'DAILY',
    distance FLOAT DEFAULT 0,
    estimated_time FLOAT DEFAULT 0,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(id),
    FOREIGN KEY (driver_id) REFERENCES users(user_id)
);

-- Route Orders Table
CREATE TABLE IF NOT EXISTS route_orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT NOT NULL,
    order_id INT NOT NULL,
    sequence_number INT NOT NULL,
    status NVARCHAR(20) DEFAULT 'PENDING',
    estimated_time FLOAT DEFAULT 0,
    actual_time FLOAT,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (route_id) REFERENCES distribution_routes(id),
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id)
);

-- Marketing Metrics Table
CREATE TABLE IF NOT EXISTS marketing_metrics (
    id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT NOT NULL,
    metric_type NVARCHAR(50) NOT NULL, -- 'IMPRESSIONS', 'CLICKS', 'CONVERSIONS', 'ROI'
    metric_value FLOAT NOT NULL,
    metric_date DATETIME DEFAULT GETDATE(),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id)
);

-- Returns Processing Table
CREATE TABLE IF NOT EXISTS returns_processing (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    center_id INT,
    return_reason NVARCHAR(255),
    return_quantity FLOAT NOT NULL,
    refund_amount FLOAT DEFAULT 0,
    return_status NVARCHAR(20) DEFAULT 'PENDING',
    processed_by INT,
    return_date DATETIME DEFAULT GETDATE(),
    processed_date DATETIME,
    notes NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(id),
    FOREIGN KEY (processed_by) REFERENCES users(user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_distribution_centers_code ON distribution_centers(code);
CREATE INDEX IF NOT EXISTS idx_distribution_centers_active ON distribution_centers(is_active);
CREATE INDEX IF NOT EXISTS idx_inventory_allocations_product ON inventory_allocations(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_allocations_center ON inventory_allocations(center_id);
CREATE INDEX IF NOT EXISTS idx_marketing_campaigns_status ON marketing_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_campaign_products_campaign ON campaign_products(campaign_id);
CREATE INDEX IF NOT EXISTS idx_sales_analytics_date ON sales_analytics(analytics_date);
CREATE INDEX IF NOT EXISTS idx_sales_analytics_campaign ON sales_analytics(campaign_id);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_product ON inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_distribution_routes_center ON distribution_routes(center_id);
CREATE INDEX IF NOT EXISTS idx_route_orders_route ON route_orders(route_id);
CREATE INDEX IF NOT EXISTS idx_marketing_metrics_campaign ON marketing_metrics(campaign_id);
CREATE INDEX IF NOT EXISTS idx_returns_processing_order ON returns_processing(order_id);

-- Insert sample data for testing
INSERT INTO distribution_centers (name, code, address, city, state, postal_code, country, phone, email, manager_name, capacity)
VALUES 
    ('Mumbai Central Warehouse', 'MUM001', '123 Industrial Area, Andheri', 'Mumbai', 'Maharashtra', '400053', 'India', '+91-22-23456789', 'mumbai@vedantatrade.com', 'Rajesh Kumar', 10000),
    ('Delhi Distribution Center', 'DEL001', '456 Business Park, Gurgaon', 'Gurgaon', 'Haryana', '122001', 'India', '+91-11-34567890', 'delhi@vedantatrade.com', 'Anita Sharma', 8000),
    ('Bangalore Hub', 'BLR001', '789 Tech Park, Whitefield', 'Bangalore', 'Karnataka', '560066', 'India', '+91-80-45678901', 'bangalore@vedantatrade.com', 'Suresh Reddy', 12000);

-- Insert sample marketing campaigns
INSERT INTO marketing_campaigns (name, description, start_date, end_date, budget, status, target_audience, created_by)
VALUES 
    ('Summer Health Special', 'Special discounts on health supplements for summer season', '2024-06-01', '2024-08-31', 50000, 'ACTIVE', 'Health-conscious adults 25-45', 1),
    ('Monsoon Wellness Drive', 'Focus on immunity-boosting products during monsoon', '2024-07-15', '2024-09-30', 75000, 'ACTIVE', 'General public', 1),
    ('Festive Season Offers', 'Special pricing for Diwali and other festivals', '2024-10-01', '2024-11-30', 100000, 'PLANNED', 'All customers', 1);

-- Insert sample inventory allocations
INSERT INTO inventory_allocations (product_id, center_id, quantity_allocated, quantity_available)
SELECT 
    item_id, 
    1, -- Mumbai Central Warehouse
    stock_quantity * 0.4, -- Allocate 40% to Mumbai
    stock_quantity * 0.4
FROM inventory_items 
WHERE is_active = 1;
