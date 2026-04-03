export interface DistributionCenter {
  id: number;
  name: string;
  code: string;
  address: string;
  city: string;
  state: string;
  postal_code: string;
  country: string;
  phone?: string;
  email?: string;
  manager_name?: string;
  capacity: number;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface InventoryAllocation {
  id: number;
  product_id: number;
  center_id: number;
  quantity_allocated: number;
  quantity_available: number;
  allocated_at: Date;
  last_updated: Date;
}

export interface MarketingCampaign {
  id: number;
  name: string;
  description?: string;
  campaign_type: 'PRODUCT_LAUNCH' | 'SEASONAL' | 'PROMOTION' | 'AWARENESS';
  status: 'DRAFT' | 'ACTIVE' | 'PAUSED' | 'COMPLETED';
  start_date: Date;
  end_date: Date;
  budget: number;
  actual_cost: number;
  target_audience: string;
  created_by: number;
  created_at: Date;
  updated_at: Date;
}

export interface CampaignProduct {
  id: number;
  campaign_id: number;
  product_id: number;
  discount_percentage: number;
  special_pricing?: number;
  is_featured: boolean;
  created_at: Date;
}

export interface SalesAnalytics {
  id: number;
  product_id: number;
  center_id?: number;
  campaign_id?: number;
  date: Date;
  units_sold: number;
  revenue: number;
  cost: number;
  profit: number;
  created_at: Date;
}

export interface InventoryMovement {
  id: number;
  product_id: number;
  center_id: number;
  movement_type: 'IN' | 'OUT' | 'TRANSFER' | 'ADJUSTMENT' | 'RETURN';
  quantity: number;
  reference_type: 'ORDER' | 'PURCHASE' | 'TRANSFER' | 'ADJUSTMENT';
  reference_id?: number;
  reason?: string;
  created_by: number;
  created_at: Date;
}

export interface DistributionRoute {
  id: number;
  name: string;
  center_id: number;
  route_type: 'DELIVERY' | 'PICKUP' | 'TRANSFER';
  areas_covered: string;
  estimated_time_hours: number;
  vehicle_type?: string;
  driver_id?: number;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface RouteOrder {
  id: number;
  route_id: number;
  order_id: number;
  sequence_number: number;
  status: 'PENDING' | 'ASSIGNED' | 'IN_PROGRESS' | 'COMPLETED';
  assigned_at?: Date;
  completed_at?: Date;
  notes?: string;
  created_at: Date;
}

export interface MarketingMetric {
  id: number;
  campaign_id: number;
  metric_type: 'VIEWS' | 'CLICKS' | 'CONVERSIONS' | 'ENGAGEMENT';
  metric_value: number;
  recorded_date: Date;
  created_at: Date;
}

export interface ReturnProcessing {
  id: number;
  order_id: number;
  product_id: number;
  return_reason: 'DAMAGED' | 'EXPIRED' | 'WRONG_ITEM' | 'CUSTOMER_RETURN';
  return_condition: 'EXCELLENT' | 'GOOD' | 'ACCEPTABLE' | 'POOR';
  quantity_returned: number;
  refund_amount: number;
  restock_fee: number;
  processed_by: number;
  processed_at: Date;
  notes?: string;
}
