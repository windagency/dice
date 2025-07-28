import { Controller, Post, Get, Body, UseGuards, Request, ValidationPipe, HttpCode, HttpStatus, UseInterceptors } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, AuthResponseDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { UserSafe } from './entities/user.entity';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body(ValidationPipe) registerDto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body(ValidationPipe) loginDto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(loginDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req: any): Promise<UserSafe> {
    return req.user;
  }

  @Get('validate')
  @UseGuards(JwtAuthGuard)
  async validateToken(@Request() req: any): Promise<{ valid: boolean; user: UserSafe }> {
    return {
      valid: true,
      user: req.user,
    };
  }

  // Development endpoint - remove in production
  @Get('dev/users')
  async getAllUsers(): Promise<UserSafe[]> {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Development endpoint not available in production');
    }
    return this.authService.getAllUsers();
  }

  // Development endpoint - remove in production
  @Post('dev/clear')
  async clearAllUsers(): Promise<{ message: string }> {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Development endpoint not available in production');
    }
    this.authService.clearAllUsers();
    return { message: 'All users cleared' };
  }
} 