import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { User, UserSafe } from './entities/user.entity';
import { RegisterDto, LoginDto, AuthResponseDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  private users: User[] = [];
  private readonly jwtSecret: string;
  private readonly jwtExpiresIn: string = '24h';

  constructor() {
    this.jwtSecret = process.env.JWT_SECRET || 'dice_development_jwt_secret_fallback';
    
    if (!process.env.JWT_SECRET) {
      console.warn('⚠️  JWT_SECRET not set in environment variables. Using fallback secret for development only.');
    }
  }

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { email, password, username } = registerDto;

    // Check if user already exists
    const existingUser = this.users.find(u => u.email === email || u.username === username);
    if (existingUser) {
      throw new ConflictException('User with this email or username already exists');
    }

    // Hash password
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const user: User = {
      id: uuidv4(),
      email,
      username,
      passwordHash,
      createdAt: new Date(),
      updatedAt: new Date(),
      isActive: true,
    };

    this.users.push(user);

    // Generate JWT token
    const accessToken = this.generateJwtToken(user);

    return {
      accessToken,
      user: this.sanitizeUser(user),
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    // Find user by email
    const user = this.users.find(u => u.email === email && u.isActive);
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Generate JWT token
    const accessToken = this.generateJwtToken(user);

    return {
      accessToken,
      user: this.sanitizeUser(user),
    };
  }

  async validateUser(userId: string): Promise<UserSafe | null> {
    const user = this.users.find(u => u.id === userId && u.isActive);
    return user ? this.sanitizeUser(user) : null;
  }

  validateJwtToken(token: string): { userId: string; email: string } | null {
    try {
      const payload = jwt.verify(token, this.jwtSecret) as any;
      return {
        userId: payload.sub,
        email: payload.email,
      };
    } catch (error) {
      return null;
    }
  }

  private generateJwtToken(user: User): string {
    const payload = {
      sub: user.id,
      email: user.email,
      username: user.username,
    };

    return jwt.sign(payload, this.jwtSecret, { 
      expiresIn: '24h',
      issuer: 'dice-backend',
      audience: 'dice-app',
    });
  }

  private sanitizeUser(user: User): UserSafe {
    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  // Development helper method
  getAllUsers(): UserSafe[] {
    return this.users.map(user => this.sanitizeUser(user));
  }

  // Development helper method
  clearAllUsers(): void {
    this.users = [];
  }
} 