import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthService } from '../auth.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException('Access token is required');
    }

    const tokenPayload = this.authService.validateJwtToken(token);
    if (!tokenPayload) {
      throw new UnauthorizedException('Invalid or expired token');
    }

    // Validate user still exists and is active
    const user = await this.authService.validateUser(tokenPayload.userId);
    if (!user) {
      throw new UnauthorizedException('User not found or inactive');
    }

    // Attach user to request object for use in controllers
    request.user = user;
    return true;
  }

  private extractTokenFromHeader(request: any): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
} 