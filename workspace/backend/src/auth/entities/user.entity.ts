export interface User {
  id: string;
  email: string;
  username: string;
  passwordHash: string;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
}

export interface UserSafe {
  id: string;
  email: string;
  username: string;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
} 