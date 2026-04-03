import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/stockist/orders - Get all orders for the stockist
router.get('/orders', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const orders = await prisma.order.findMany({
      where: {
        stockistId: stockistId
      },
      include: {
        retailer: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                email: true
              }
            }
          }
        },
        items: {
          include: {
            product: true
          }
        },
        payments: true
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({
      success: true,
      data: orders
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders'
    });
  }
});

// POST /api/stockist/orders - Create new order
router.post('/orders', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const { retailerId, items, notes } = req.body;

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    if (!retailerId || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Retailer ID and items are required'
      });
    }

    // Validate retailer exists and belongs to this stockist's territory
    const retailer = await prisma.retailer.findFirst({
      where: {
        id: retailerId,
        stockistId: stockistId
      }
    });

    if (!retailer) {
      return res.status(404).json({
        success: false,
        message: 'Retailer not found or not in your territory'
      });
    }

    // Validate products and calculate total
    let totalAmount = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await prisma.product.findFirst({
        where: {
          id: item.productId,
          stockistId: stockistId
        }
      });

      if (!product) {
        return res.status(404).json({
          success: false,
          message: `Product with ID ${item.productId} not found`
        });
      }

      if (product.stock < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for ${product.name}. Available: ${product.stock}, Requested: ${item.quantity}`
        });
      }

      const itemTotal = product.price * item.quantity;
      totalAmount += itemTotal;

      orderItems.push({
        productId: product.id,
        quantity: item.quantity,
        unitPrice: product.price,
        totalPrice: itemTotal
      });
    }

    // Create order with items in a transaction
    const order = await prisma.$transaction(async (tx) => {
      const newOrder = await tx.order.create({
        data: {
          retailerId: retailerId,
          stockistId: stockistId,
          totalAmount: totalAmount,
          status: 'PENDING',
          notes: notes || null,
          items: {
            create: orderItems
          }
        },
        include: {
          retailer: true,
          items: {
            include: {
              product: true
            }
          }
        }
      });

      // Update product stock
      for (const item of orderItems) {
        await tx.product.update({
          where: { id: item.productId },
          data: {
            stock: {
              decrement: item.quantity
            }
          }
        });
      }

      return newOrder;
    });

    res.status(201).json({
      success: true,
      data: order,
      message: 'Order created successfully'
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order'
    });
  }
});

// PUT /api/stockist/orders/:id/status - Update order status
router.put('/orders/:id/status', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const orderId = parseInt(req.params.id);
    const { status } = req.body;

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const validStatuses = ['PENDING', 'APPROVED', 'DISPATCHED', 'DELIVERED', 'PAID', 'CANCELLED'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    // Verify order belongs to this stockist
    const existingOrder = await prisma.order.findFirst({
      where: {
        id: orderId,
        stockistId: stockistId
      }
    });

    if (!existingOrder) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Validate status transitions
    const currentStatus = existingOrder.status;
    const validTransitions: Record<string, string[]> = {
      'PENDING': ['APPROVED', 'CANCELLED'],
      'APPROVED': ['DISPATCHED', 'CANCELLED'],
      'DISPATCHED': ['DELIVERED'],
      'DELIVERED': ['PAID'],
      'PAID': [], // Final state
      'CANCELLED': [] // Final state
    };

    if (!validTransitions[currentStatus]?.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status transition from ${currentStatus} to ${status}`
      });
    }

    // Update order status
    const updatedOrder = await prisma.order.update({
      where: { id: orderId },
      data: {
        status: status,
        updatedAt: new Date()
      },
      include: {
        retailer: true,
        items: {
          include: {
            product: true
          }
        }
      }
    });

    // If order is cancelled, restore stock
    if (status === 'CANCELLED') {
      await prisma.$transaction(async (tx) => {
        for (const item of updatedOrder.items) {
          await tx.product.update({
            where: { id: item.productId },
            data: {
              stock: {
                increment: item.quantity
              }
            }
          });
        }
      });
    }

    res.json({
      success: true,
      data: updatedOrder,
      message: `Order status updated to ${status}`
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update order status'
    });
  }
});

// GET /api/stockist/retailers - Get all retailers for the stockist
router.get('/retailers', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const retailers = await prisma.retailer.findMany({
      where: {
        stockistId: stockistId
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            email: true
          }
        }
      },
      orderBy: {
        businessName: 'asc'
      }
    });

    res.json({
      success: true,
      data: retailers
    });
  } catch (error) {
    console.error('Error fetching retailers:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch retailers'
    });
  }
});

// GET /api/stockist/products - Get all products for the stockist
router.get('/products', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const products = await prisma.product.findMany({
      where: {
        stockistId: stockistId,
        isActive: true
      },
      include: {
        category: true
      },
      orderBy: {
        name: 'asc'
      }
    });

    res.json({
      success: true,
      data: products
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products'
    });
  }
});

// GET /api/stockist/orders/:id - Get specific order details
router.get('/orders/:id', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const orderId = parseInt(req.params.id);
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const order = await prisma.order.findFirst({
      where: {
        id: orderId,
        stockistId: stockistId
      },
      include: {
        retailer: {
          include: {
            user: true
          }
        },
        items: {
          include: {
            product: true
          }
        },
        payments: true
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    res.json({
      success: true,
      data: order
    });
  } catch (error) {
    console.error('Error fetching order details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order details'
    });
  }
});

// POST /api/stockist/orders/:id/payment - Record payment for order
router.post('/orders/:id/payment', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const orderId = parseInt(req.params.id);
    const { amount, paymentMethod, reference } = req.body;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    // Verify order exists and is delivered
    const order = await prisma.order.findFirst({
      where: {
        id: orderId,
        stockistId: stockistId,
        status: 'DELIVERED'
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or not ready for payment'
      });
    }

    // Create payment record
    const payment = await prisma.payment.create({
      data: {
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        reference: reference || null,
        status: 'COMPLETED',
        paidAt: new Date()
      }
    });

    // Update order status to PAID
    await prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'PAID',
        updatedAt: new Date()
      }
    });

    res.status(201).json({
      success: true,
      data: payment,
      message: 'Payment recorded successfully'
    });
  } catch (error) {
    console.error('Error recording payment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record payment'
    });
  }
});

// GET /api/stockist/analytics - Get order analytics
router.get('/analytics', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const [
      totalOrders,
      pendingOrders,
      completedOrders,
      totalRevenue,
      ordersByStatus,
      topProducts
    ] = await Promise.all([
      // Total orders count
      prisma.order.count({
        where: { stockistId: stockistId }
      }),
      
      // Pending orders count
      prisma.order.count({
        where: { 
          stockistId: stockistId,
          status: 'PENDING'
        }
      }),
      
      // Completed orders count
      prisma.order.count({
        where: { 
          stockistId: stockistId,
          status: 'PAID'
        }
      }),
      
      // Total revenue
      prisma.order.aggregate({
        where: { 
          stockistId: stockistId,
          status: 'PAID'
        },
        _sum: {
          totalAmount: true
        }
      }),
      
      // Orders by status
      prisma.order.groupBy({
        by: ['status'],
        where: { stockistId: stockistId },
        _count: {
          id: true
        }
      }),
      
      // Top selling products
      prisma.orderItem.groupBy({
        by: ['productId'],
        where: {
          order: {
            stockistId: stockistId,
            status: 'PAID'
          }
        },
        _sum: {
          quantity: true
        },
        orderBy: {
          _sum: {
            quantity: 'desc'
          }
        },
        take: 10
      })
    ]);

    // Get product details for top products
    const topProductIds = topProducts.map(p => p.productId);
    const topProductDetails = await prisma.product.findMany({
      where: {
        id: { in: topProductIds }
      },
      select: {
        id: true,
        name: true,
        price: true
      }
    });

    const analytics = {
      totalOrders,
      pendingOrders,
      completedOrders,
      totalRevenue: totalRevenue._sum.totalAmount || 0,
      ordersByStatus: ordersByStatus.map(item => ({
        status: item.status,
        count: item._count.id
      })),
      topProducts: topProducts.map(item => {
        const product = topProductDetails.find(p => p.id === item.productId);
        return {
          productId: item.productId,
          productName: product?.name || 'Unknown',
          totalQuantity: item._sum.quantity
        };
      })
    };

    res.json({
      success: true,
      data: analytics
    });
  } catch (error) {
    console.error('Error fetching analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch analytics'
    });
  }
});

export default router;
