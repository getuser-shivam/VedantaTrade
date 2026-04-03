import { User as PrismaUser } from '@prisma/client';

declare global {
  namespace Express {
    interface User extends PrismaUser {
      permissions?: string[];
      lastLogin?: string;
    }
    
    interface Request {
      user?: User;
    }
  }
}

export {};
