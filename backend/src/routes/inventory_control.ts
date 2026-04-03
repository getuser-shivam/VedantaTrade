import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/enhancedAuth';

const router = Router();
const prisma = new PrismaClient();

// GET /api/stockist/inventory - Get all inventory for the stockist
router.get('/inventory', authenticate, async (req: Request, res: Response) => {
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
        category: true,
        inventoryTransactions: {
          orderBy: {
            createdAt: 'desc'
          },
          take: 5
        }
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
    console.error('Error fetching inventory:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory'
    });
  }
});

// GET /api/stockist/inventory/alerts - Get inventory alerts (low stock and expiring)
router.get('/inventory/alerts', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const now = new Date();
    const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

    // Get low stock products
    const lowStockProducts = await prisma.product.findMany({
      where: {
        stockistId: stockistId,
        isActive: true,
        stock: {
          lte: prisma.product.fields.lowStockThreshold
        }
      },
      include: {
        category: true
      },
      orderBy: {
        stock: 'asc'
      }
    });

    // Get expiring products
    const expiringProducts = await prisma.product.findMany({
      where: {
        stockistId: stockistId,
        isActive: true,
        expiryDate: {
          lte: thirtyDaysFromNow,
          gte: now
        },
        stock: {
          gt: 0
        }
      },
      include: {
        category: true
      },
      orderBy: {
        expiryDate: 'asc'
      }
    });

    res.json({
      success: true,
      lowStock: lowStockProducts,
      expiring: expiringProducts
    });
  } catch (error) {
    console.error('Error fetching inventory alerts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch inventory alerts'
    });
  }
});

// POST /api/stockist/inventory/update - Update product stock
router.post('/inventory/update', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const { productId, operation, quantity, reason, batchNumber, expiryDate } = req.body;

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    if (!productId || !operation || !quantity || quantity <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Product ID, operation, and valid quantity are required'
      });
    }

    // Verify product belongs to this stockist
    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        stockistId: stockistId
      }
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Update stock in a transaction
    const updatedProduct = await prisma.$transaction(async (tx) => {
      let newStock = product.stock;
      
      if (operation === 'add') {
        newStock += quantity;
      } else if (operation === 'remove') {
        if (product.stock < quantity) {
          throw new Error('Insufficient stock for removal');
        }
        newStock -= quantity;
      } else {
        throw new Error('Invalid operation. Must be "add" or "remove"');
      }

      // Update product stock
      const updated = await tx.product.update({
        where: { id: productId },
        data: {
          stock: newStock,
          updatedAt: new Date(),
          // Update batch number and expiry date if provided
          ...(batchNumber && { batchNumber }),
          ...(expiryDate && { expiryDate: new Date(expiryDate) })
        },
        include: {
          category: true
        }
      });

      // Create inventory transaction record
      await tx.inventoryTransaction.create({
        data: {
          productId: productId,
          stockistId: stockistId,
          transactionType: operation.toUpperCase(),
          quantity: quantity,
          previousStock: product.stock,
          newStock: newStock,
          reason: reason || `${operation.toUpperCase()} operation`,
          batchNumber: batchNumber || null,
          expiryDate: expiryDate ? new Date(expiryDate) : null
        }
      });

      return updated;
    });

    res.json({
      success: true,
      data: updatedProduct,
      message: `Stock ${operation}ed successfully`
    });
  } catch (error) {
    console.error('Error updating stock:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Failed to update stock'
    });
  }
});

// GET /api/stockist/categories - Get all product categories
router.get('/categories', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const categories = await prisma.category.findMany({
      where: {
        products: {
          some: {
            stockistId: stockistId,
            isActive: true
          }
        }
      },
      include: {
        _count: {
          select: {
            products: {
              where: {
                stockistId: stockistId,
                isActive: true
              }
            }
          }
        }
      },
      orderBy: {
        name: 'asc'
      }
    });

    res.json({
      success: true,
      data: categories
    });
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories'
    });
  }
});

// POST /api/stockist/products - Add new product
router.post('/products', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const { 
      name, 
      sku, 
      categoryId, 
      price, 
      stock, 
      lowStockThreshold, 
      description, 
      batchNumber, 
      expiryDate 
    } = req.body;

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    if (!name || !sku || !categoryId || !price || stock === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Name, SKU, category, price, and stock are required'
      });
    }

    // Check if SKU already exists for this stockist
    const existingProduct = await prisma.product.findFirst({
      where: {
        sku: sku,
        stockistId: stockistId
      }
    });

    if (existingProduct) {
      return res.status(400).json({
        success: false,
        message: 'Product with this SKU already exists'
      });
    }

    // Create new product
    const newProduct = await prisma.product.create({
      data: {
        name,
        sku,
        categoryId,
        price: parseFloat(price),
        stock: parseInt(stock),
        lowStockThreshold: lowStockThreshold ? parseInt(lowStockThreshold) : 10,
        description: description || null,
        batchNumber: batchNumber || null,
        expiryDate: expiryDate ? new Date(expiryDate) : null,
        stockistId: stockistId,
        isActive: true
      },
      include: {
        category: true
      }
    });

    // Create initial inventory transaction
    await prisma.inventoryTransaction.create({
      data: {
        productId: newProduct.id,
        stockistId: stockistId,
        transactionType: 'INITIAL',
        quantity: parseInt(stock),
        previousStock: 0,
        newStock: parseInt(stock),
        reason: 'Initial stock entry',
        batchNumber: batchNumber || null,
        expiryDate: expiryDate ? new Date(expiryDate) : null
      }
    });

    res.status(201).json({
      success: true,
      data: newProduct,
      message: 'Product created successfully'
    });
  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create product'
    });
  }
});

// PUT /api/stockist/products/:id - Update product
router.put('/products/:id', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const productId = parseInt(req.params.id);
    const { name, categoryId, price, lowStockThreshold, description } = req.body;

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    // Verify product belongs to this stockist
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: productId,
        stockistId: stockistId
      }
    });

    if (!existingProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Update product
    const updatedProduct = await prisma.product.update({
      where: { id: productId },
      data: {
        ...(name && { name }),
        ...(categoryId && { categoryId }),
        ...(price && { price: parseFloat(price) }),
        ...(lowStockThreshold && { lowStockThreshold: parseInt(lowStockThreshold) }),
        ...(description !== undefined && { description }),
        updatedAt: new Date()
      },
      include: {
        category: true
      }
    });

    res.json({
      success: true,
      data: updatedProduct,
      message: 'Product updated successfully'
    });
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update product'
    });
  }
});

// DELETE /api/stockist/products/:id - Deactivate product
router.delete('/products/:id', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const productId = parseInt(req.params.id);

    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    // Verify product belongs to this stockist
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: productId,
        stockistId: stockistId
      }
    });

    if (!existingProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Deactivate product (soft delete)
    await prisma.product.update({
      where: { id: productId },
      data: {
        isActive: false,
        updatedAt: new Date()
      }
    });

    res.json({
      success: true,
      message: 'Product deactivated successfully'
    });
  } catch (error) {
    console.error('Error deactivating product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to deactivate product'
    });
  }
});

// GET /api/stockist/inventory/transactions - Get inventory transaction history
router.get('/inventory/transactions', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    const { productId, startDate, endDate, limit = 50, offset = 0 } = req.query;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const whereClause: any = {
      stockistId: stockistId
    };

    if (productId) {
      whereClause.productId = parseInt(productId as string);
    }

    if (startDate || endDate) {
      whereClause.createdAt = {};
      if (startDate) {
        whereClause.createdAt.gte = new Date(startDate as string);
      }
      if (endDate) {
        whereClause.createdAt.lte = new Date(endDate as string);
      }
    }

    const transactions = await prisma.inventoryTransaction.findMany({
      where: whereClause,
      include: {
        product: {
          include: {
            category: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: parseInt(limit as string),
      skip: parseInt(offset as string)
    });

    const total = await prisma.inventoryTransaction.count({
      where: whereClause
    });

    res.json({
      success: true,
      data: transactions,
      pagination: {
        total,
        limit: parseInt(limit as string),
        offset: parseInt(offset as string)
      }
    });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch transactions'
    });
  }
});

// GET /api/stockist/inventory/analytics - Get inventory analytics
router.get('/inventory/analytics', authenticate, async (req: Request, res: Response) => {
  try {
    const stockistId = (req as any).user?.stockistProfile?.id;
    
    if (!stockistId) {
      return res.status(403).json({
        success: false,
        message: 'Stockist profile not found'
      });
    }

    const [
      totalProducts,
      lowStockCount,
      expiringCount,
      totalValue,
      totalStock,
      categoryDistribution,
      topMovingProducts,
      recentTransactions
    ] = await Promise.all([
      // Total products count
      prisma.product.count({
        where: { 
          stockistId: stockistId,
          isActive: true
        }
      }),
      
      // Low stock count
      prisma.product.count({
        where: { 
          stockistId: stockistId,
          isActive: true,
          stock: {
            lte: prisma.product.fields.lowStockThreshold
          }
        }
      }),
      
      // Expiring count (next 30 days)
      prisma.product.count({
        where: {
          stockistId: stockistId,
          isActive: true,
          expiryDate: {
            lte: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
            gte: new Date()
          },
          stock: { gt: 0 }
        }
      }),
      
      // Total inventory value
      prisma.product.aggregate({
        where: { 
          stockistId: stockistId,
          isActive: true
        },
        _sum: {
          stock: true
        }
      }),
      
      // Total stock units
      prisma.product.aggregate({
        where: { 
          stockistId: stockistId,
          isActive: true
        },
        _sum: {
          stock: true
        }
      }),
      
      // Category distribution
      prisma.product.groupBy({
        by: ['categoryId'],
        where: {
          stockistId: stockistId,
          isActive: true
        },
        _count: {
          id: true
        },
        _sum: {
          stock: true
        }
      }),
      
      // Top moving products (most transactions)
      prisma.inventoryTransaction.groupBy({
        by: ['productId'],
        where: {
          stockistId: stockistId,
          createdAt: {
            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
          }
        },
        _sum: {
          quantity: true
        },
        _count: {
          id: true
        },
        orderBy: {
          _sum: {
            quantity: 'desc'
          }
        },
        take: 10
      }),
      
      // Recent transactions
      prisma.inventoryTransaction.findMany({
        where: {
          stockistId: stockistId
        },
        include: {
          product: {
            select: {
              id: true,
              name: true,
              sku: true
            }
          }
        },
        orderBy: {
          createdAt: 'desc'
        },
        take: 10
      })
    ]);

    // Get category details
    const categoryIds = categoryDistribution.map(c => c.categoryId);
    const categoryDetails = await prisma.category.findMany({
      where: {
        id: { in: categoryIds }
      },
      select: {
        id: true,
        name: true
      }
    });

    // Get product details for top moving products
    const topProductIds = topMovingProducts.map(p => p.productId);
    const topProductDetails = await prisma.product.findMany({
      where: {
        id: { in: topProductIds }
      },
      select: {
        id: true,
        name: true,
        sku: true,
        price: true
      }
    });

    // Calculate total value
    const productsForValue = await prisma.product.findMany({
      where: {
        stockistId: stockistId,
        isActive: true
      },
      select: {
        stock: true,
        price: true
      }
    });

    const calculatedTotalValue = productsForValue.reduce((sum, product) => {
      return sum + (product.stock * product.price);
    }, 0);

    const analytics = {
      totalProducts,
      lowStockCount,
      expiringCount,
      totalValue: calculatedTotalValue,
      totalStock: totalStock._sum.stock || 0,
      categoryDistribution: categoryDistribution.map(item => {
        const category = categoryDetails.find(c => c.id === item.categoryId);
        return {
          categoryId: item.categoryId,
          categoryName: category?.name || 'Unknown',
          productCount: item._count.id,
          totalStock: item._sum.stock || 0
        };
      }),
      topMovingProducts: topMovingProducts.map(item => {
        const product = topProductDetails.find(p => p.id === item.productId);
        return {
          productId: item.productId,
          productName: product?.name || 'Unknown',
          productSku: product?.sku || '',
          totalQuantity: item._sum.quantity || 0,
          transactionCount: item._count.id
        };
      }),
      recentTransactions
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
