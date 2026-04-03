import WebSocket from 'ws';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'vedanta_secret_key';

interface WebSocketClient {
  ws: WebSocket;
  userId: number;
  role: string;
  subscriptions: Set<string>;
  lastPing: Date;
}

interface InventoryUpdate {
  type: 'inventory_update' | 'stock_alert' | 'route_update' | 'campaign_update';
  data: any;
  timestamp: Date;
  userId?: number;
  centerId?: number;
  productId?: number;
}

class WebSocketService {
  private wss: WebSocket.Server;
  private clients: Map<WebSocket, WebSocketClient> = new Map();
  private heartbeatInterval: NodeJS.Timeout;

  constructor(server: any) {
    this.wss = new WebSocket.Server({ 
      server,
      path: '/ws'
    });

    this.setupWebSocketServer();
    this.startHeartbeat();
  }

  private setupWebSocketServer() {
    this.wss.on('connection', (ws: WebSocket, request) => {
      this.handleConnection(ws, request);
    });

    console.log('WebSocket server initialized on /ws');
  }

  private async handleConnection(ws: WebSocket, request: any) {
    try {
      // Extract token from query parameters
      const url = new URL(request.url || '', `http://${request.headers.host}`);
      const token = url.searchParams.get('token');

      if (!token) {
        ws.close(1008, 'Authentication token required');
        return;
      }

      // Verify JWT token
      const decoded = jwt.verify(token, JWT_SECRET) as any;
      
      // Verify session exists
      const session = await prisma.session.findFirst({
        where: { 
          token,
          user_id: decoded.id,
          expiresAt: { gt: new Date() }
        }
      });

      if (!session) {
        ws.close(1008, 'Invalid or expired session');
        return;
      }

      // Get user info
      const user = await prisma.users.findUnique({
        where: { user_id: decoded.id },
        select: { user_id: true, role: true, username: true }
      });

      if (!user) {
        ws.close(1008, 'User not found');
        return;
      }

      // Create client
      const client: WebSocketClient = {
        ws,
        userId: user.user_id,
        role: user.role,
        subscriptions: new Set(),
        lastPing: new Date()
      };

      this.clients.set(ws, client);

      // Setup event handlers
      this.setupClientEventHandlers(ws, client);

      // Send welcome message
      this.sendToClient(ws, {
        type: 'connection',
        message: 'Connected successfully',
        userId: user.user_id,
        timestamp: new Date()
      });

      console.log(`WebSocket client connected: ${user.username} (${user.role})`);
    } catch (error) {
      console.error('WebSocket connection error:', error);
      ws.close(1008, 'Authentication failed');
    }
  }

  private setupClientEventHandlers(ws: WebSocket, client: WebSocketClient) {
    ws.on('message', (data: WebSocket.Data) => {
      this.handleMessage(ws, client, data.toString());
    });

    ws.on('close', (code: number, reason: string) => {
      this.clients.delete(ws);
      console.log(`WebSocket client disconnected: ${client.userId}`);
    });

    ws.on('error', (error: Error) => {
      console.error(`WebSocket error for client ${client.userId}:`, error);
      this.clients.delete(ws);
    });

    ws.on('pong', () => {
      client.lastPing = new Date();
    });
  }

  private handleMessage(ws: WebSocket, client: WebSocketClient, message: string) {
    try {
      const data = JSON.parse(message);

      switch (data.type) {
        case 'subscribe':
          this.handleSubscription(ws, client, data.channels);
          break;
        case 'unsubscribe':
          this.handleUnsubscription(ws, client, data.channels);
          break;
        case 'ping':
          this.sendToClient(ws, { type: 'pong', timestamp: new Date() });
          break;
        default:
          console.warn(`Unknown message type: ${data.type}`);
      }
    } catch (error) {
      console.error('Error handling WebSocket message:', error);
      this.sendToClient(ws, {
        type: 'error',
        message: 'Invalid message format',
        timestamp: new Date()
      });
    }
  }

  private handleSubscription(ws: WebSocket, client: WebSocketClient, channels: string[]) {
    if (!Array.isArray(channels)) {
      return;
    }

    channels.forEach(channel => {
      // Validate channel permissions
      if (this.canSubscribeToChannel(client.role, channel)) {
        client.subscriptions.add(channel);
      }
    });

    this.sendToClient(ws, {
      type: 'subscription_confirmed',
      channels: Array.from(client.subscriptions),
      timestamp: new Date()
    });
  }

  private handleUnsubscription(ws: WebSocket, client: WebSocketClient, channels: string[]) {
    if (!Array.isArray(channels)) {
      return;
    }

    channels.forEach(channel => {
      client.subscriptions.delete(channel);
    });

    this.sendToClient(ws, {
      type: 'unsubscription_confirmed',
      channels: Array.from(client.subscriptions),
      timestamp: new Date()
    });
  }

  private canSubscribeToChannel(role: string, channel: string): boolean {
    const channelPermissions: { [key: string]: string[] } = {
      'ADMIN': ['inventory', 'routes', 'campaigns', 'analytics', 'all'],
      'MEDICAL_REP': ['inventory', 'routes'],
      'DOCTOR': ['inventory'],
      'ACCOUNTANT': ['analytics'],
      'STOCKIST': ['inventory', 'routes'],
      'RETAILER': ['inventory']
    };

    return channelPermissions[role]?.includes(channel) || false;
  }

  public broadcastInventoryUpdate(update: InventoryUpdate) {
    const message = {
      type: update.type,
      data: update.data,
      timestamp: update.timestamp
    };

    this.clients.forEach((client) => {
      if (client.subscriptions.has('inventory') || client.subscriptions.has('all')) {
        // Filter by center if specified
        if (update.centerId && update.centerId !== client.userId) {
          return;
        }

        this.sendToClient(client.ws, message);
      }
    });
  }

  public broadcastStockAlert(alert: any) {
    const message = {
      type: 'stock_alert',
      data: alert,
      timestamp: new Date()
    };

    this.clients.forEach((client) => {
      if (client.subscriptions.has('inventory') || client.subscriptions.has('all')) {
        this.sendToClient(client.ws, message);
      }
    });
  }

  public broadcastRouteUpdate(routeUpdate: any) {
    const message = {
      type: 'route_update',
      data: routeUpdate,
      timestamp: new Date()
    };

    this.clients.forEach((client) => {
      if (client.subscriptions.has('routes') || client.subscriptions.has('all')) {
        this.sendToClient(client.ws, message);
      }
    });
  }

  public broadcastCampaignUpdate(campaignUpdate: any) {
    const message = {
      type: 'campaign_update',
      data: campaignUpdate,
      timestamp: new Date()
    };

    this.clients.forEach((client) => {
      if (client.subscriptions.has('campaigns') || client.subscriptions.has('all')) {
        this.sendToClient(client.ws, message);
      }
    });
  }

  public broadcastAnalyticsUpdate(analyticsUpdate: any) {
    const message = {
      type: 'analytics_update',
      data: analyticsUpdate,
      timestamp: new Date()
    };

    this.clients.forEach((client) => {
      if (client.subscriptions.has('analytics') || client.subscriptions.has('all')) {
        this.sendToClient(client.ws, message);
      }
    });
  }

  private sendToClient(ws: WebSocket, message: any) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  private startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      const now = new Date();
      
      this.clients.forEach((client, ws) => {
        // Remove clients that haven't responded to ping
        if (now.getTime() - client.lastPing.getTime() > 30000) {
          ws.terminate();
          this.clients.delete(ws);
          console.log(`Removed inactive client: ${client.userId}`);
          return;
        }

        // Send ping
        if (ws.readyState === WebSocket.OPEN) {
          ws.ping();
        }
      });
    }, 15000); // Every 15 seconds
  }

  public getConnectedClients(): number {
    return this.clients.size;
  }

  public getClientStats(): any {
    const stats = {
      totalClients: this.clients.size,
      byRole: {} as { [key: string]: number },
      bySubscription: {} as { [key: string]: number }
    };

    this.clients.forEach((client) => {
      // Count by role
      stats.byRole[client.role] = (stats.byRole[client.role] || 0) + 1;

      // Count by subscription
      client.subscriptions.forEach((subscription) => {
        stats.bySubscription[subscription] = (stats.bySubscription[subscription] || 0) + 1;
      });
    });

    return stats;
  }

  public close() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }

    this.clients.forEach((client, ws) => {
      ws.close(1000, 'Server shutting down');
    });

    this.wss.close();
  }
}

export default WebSocketService;
