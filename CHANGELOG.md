# Changelog

All significant changes to this project will be documented in this file.  
The project format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and uses semantic version management [Semver](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased](https://github.com/windagency/dice/compare/v0.1.0..HEAD)

### Added

- **Containerised Development Environment**
  - Docker Compose orchestration with PostgreSQL 17, Redis 7, Traefik v3.0, and LocalStack 4.0
  - Automated SSL certificate generation for local development domains
  - Service startup dependency management with health checks
  - Persistent data storage for PostgreSQL and Redis

- **Database Layer**
  - PostgreSQL 17 database with D&D character management schema
  - Automated database seeding with sample users and characters
  - Support for character creation with races (Human, Elf, Dwarf, Halfling) and classes (Fighter, Wizard, Rogue, Cleric)
  - User authentication system with development test accounts

- **Development Tools**
  - Makefile with service management commands (`make start-all`, `make logs`, `make health`)
  - Infrastructure validation scripts for environment testing
  - Automated development environment setup script
  - VS Code DevContainer configurations for backend, frontend, and shared workspaces

- **Service Infrastructure**
  - Traefik reverse proxy with automatic HTTPS for local development
  - LocalStack for AWS service simulation (S3, RDS, DynamoDB)
  - Backend service foundation with Node.js 22 and debugging support
  - PWA frontend foundation with Astro.js and hot reload capability
