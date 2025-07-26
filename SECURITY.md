# DICE Security Guide

## 🔒 Security Overview

This document outlines security best practices and requirements for the DICE D&D Character Manager development and production environments.

## ⚠️ CRITICAL: Environment Configuration

### Development Environment Setup

1. **Copy the environment template:**
   ```bash
   cp .env.sample .env.development
   ```

2. **Generate secure secrets:**
   ```bash
   # Generate a 32-character secret
   openssl rand -hex 32
   
   # Generate multiple secrets at once
   for i in {1..4}; do echo "Secret $i: $(openssl rand -hex 32)"; done
   ```

3. **Replace ALL placeholder values** in `.env.development`:
   - `YOUR_SECURE_PASSWORD_HERE` → Strong database password
   - `REPLACE_WITH_STRONG_SECRET_32_CHARS_MIN` → Generated secrets

### 🔧 LocalStack Development Credentials

**Important**: LocalStack uses `test` credentials that are **SAFE for local development**:

| **Credential**          | **Value**   | **Security Notes**                      |
| ----------------------- | ----------- | --------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | `test`      | ✅ Standard LocalStack development value |
| `AWS_SECRET_ACCESS_KEY` | `test`      | ✅ Standard LocalStack development value |
| `AWS_DEFAULT_REGION`    | `eu-west-3` | ✅ Paris region (closest to France)      |

**Why These Are Safe:**
- LocalStack intercepts all AWS API calls locally
- No real AWS services are accessed
- These credentials cannot access actual AWS resources
- They are documented as standard LocalStack development values

**Security Principle**: Even safe credentials should be configurable via environment variables rather than hardcoded in Dockerfiles.

### 🚫 Security Violations to Avoid

| **NEVER DO**                      | **REASON**               | **INSTEAD**                    |
| --------------------------------- | ------------------------ | ------------------------------ |
| Commit `.env.development`         | Exposes secrets          | Use `.env.sample` template     |
| Use default/weak passwords        | Easy to guess            | Generate strong random secrets |
| Reuse secrets across environments | Security isolation       | Unique secrets per environment |
| Hardcode secrets in code          | Version control exposure | Environment variables only     |

## 🛡️ Security Measures Implemented

### Development Environment

- **Environment File Protection**: `.env*` files ignored by git except `.env.sample`
- **Required Environment Variables**: Docker Compose fails if secrets not provided
- **LocalStack Isolation**: Uses standard `test` credentials for AWS simulation
- **Strong Secret Requirements**: Minimum 32-character secrets mandated

### Container Security

- **Non-Root User**: Services run as dedicated users where possible
- **Limited Privileges**: Containers have minimal required permissions
- **Network Isolation**: Services communicate via dedicated Docker network
- **Health Checks**: All services monitored for availability and security

### Access Control

- **Service Isolation**: Each service has dedicated credentials
- **Internal Communication**: Services use internal Docker network
- **External Access**: Only necessary ports exposed to host

## 🔐 Secret Management Strategy

### Development (Current)
- **Method**: `.env.development` file (git-ignored)
- **Scope**: Local development only
- **Rotation**: Manual, as needed

### Production (Planned)
- **Method**: HashiCorp Vault or AWS Secrets Manager
- **Scope**: Automated secret injection
- **Rotation**: Automatic rotation policies
- **Audit**: Full access logging and monitoring

## 🚨 Security Incident Response

### If Secrets Are Compromised

1. **Immediate Actions:**
   ```bash
   # Generate new secrets
   openssl rand -hex 32
   
   # Update .env.development
   nano .env.development
   
   # Restart services
   docker compose down && docker compose up -d
   ```

2. **Rotate All Affected Secrets:**
   - Database passwords
   - JWT secrets
   - API keys
   - Internal service tokens

3. **Review Access Logs:**
   - Check who had access to compromised secrets
   - Review recent authentication attempts
   - Monitor for unusual service activity

## 📋 Security Checklist

### Before Development

- [ ] Created `.env.development` from template
- [ ] Generated strong, unique secrets
- [ ] Verified no secrets in version control
- [ ] Confirmed Docker services start successfully

### During Development

- [ ] Never commit actual secrets
- [ ] Use environment variables for all sensitive data
- [ ] Test with production-like security settings
- [ ] Regularly rotate development secrets

### Before Production

- [ ] Implement Vault or external secret management
- [ ] Set up secret rotation policies
- [ ] Configure monitoring and alerting
- [ ] Perform security audit and penetration testing

## 🔧 Security Commands

```bash
# Check for accidentally committed secrets
git log --grep="password\|secret\|key" --oneline

# Scan for hardcoded secrets in code
grep -r "password\|secret\|key" . --exclude-dir=.git --exclude="*.md"

# Generate secure environment file
cp .env.sample .env.development
sed -i 's/YOUR_SECURE_PASSWORD_HERE/'$(openssl rand -hex 16)'/g' .env.development

# Verify no secrets in git history
git log --all --full-history --oneline | grep -i "secret\|password\|key"
```

## 📚 Additional Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)

## 🆘 Security Contact

For security concerns or incident reporting:
- **Development Issues**: Create GitHub issue with `security` label
- **Production Incidents**: Follow incident response procedures
- **Sensitive Disclosures**: Contact project maintainers directly

---

**Remember**: Security is everyone's responsibility. When in doubt, err on the side of caution and ask for guidance. 