import { IsEmail, IsString, MinLength, MaxLength, Matches } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(12, { message: 'Password must be at least 12 characters long' })
  @MaxLength(128, { message: 'Password must not exceed 128 characters' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message: 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character (@$!%*?&)'
  })
  password: string;

  @IsString()
  @MinLength(2, { message: 'Username must be at least 2 characters long' })
  @MaxLength(50, { message: 'Username must not exceed 50 characters' })
  username: string;
}

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(12)
  password: string;
}

export class AuthResponseDto {
  accessToken: string;
  user: {
    id: string;
    email: string;
    username: string;
  };
} 