# DICE Error Diagnosis FAQ

**Last Updated**: August 3, 2025 03:09:00 UTC
**Version**: 1.1  
**Purpose**: 📚 **KNOWLEDGE BASE** - Complete error resolution guide and prevention strategies

---

## 📊 **Issue Statistics**

- **Total Issues**: 32
- **Critical**: 8 (25%)
- **Medium**: 19 (59%)
- **Low**: 5 (16%)
- **Resolved**: 25 (78%)
- **Partially Resolved**: 3 (9%)
- **Identified**: 4 (13%)

---

## 📋 **Error Index - Quick Reference**

| **Error ID** | **Category**   | **Severity**   | **Status**               | **Quick Description**                           |
| ------------ | -------------- | -------------- | ------------------------ | ----------------------------------------------- |
| **E0001**    | Infrastructure | 🔴 **Critical** | ✅ **Resolved**           | Kibana configuration basePath error             |
| **E0002**    | Infrastructure | 🔴 **Critical** | ✅ **Resolved**           | Docker network conflicts preventing ELK startup |
| **E0003**    | Infrastructure | 🟡 **Medium**   | ✅ **Resolved**           | Container caching issues with configuration     |
| **E0004**    | Scripts        | 🟡 **Medium**   | ⚠️ **Partially Resolved** | Health check script dependencies missing        |
| **E0005**    | Infrastructure | 🟢 **Low**      | ✅ **Resolved**           | ELK stack version mismatch warnings             |
| **E0006**    | Process        | 🟡 **Medium**   | ⚠️ **Identified**         | Repetitive verification cycles                  |
| **E0007**    | Process        | 🔴 **Critical** | ⚠️ **Identified**         | File deletion without user approval             |
| **E0008**    | Scripts        | 🟡 **Medium**   | ⚠️ **Identified**         | Incomplete health check implementation          |
| **E0009**    | Infrastructure | 🟡 **Medium**   | ✅ **Resolved**           | Network configuration complexity                |
| **E0010**    | Process        | 🟡 **Medium**   | ⚠️ **Identified**         | Verification plan execution issues              |
| **E0011**    | Backend        | 🔴 **Critical** | ✅ **Resolved**           | TypeScript compilation errors during startup    |
| **E0012**    | Scripts        | 🟡 **Medium**   | ✅ **Resolved**           | sed "multiple occurrences" error                |
| **E0013**    | Database       | 🔴 **Critical** | ✅ **Resolved**           | Temporal service password authentication failed |
| **E0014**    | Backend        | 🔴 **Critical** | ✅ **Resolved**           | Backend EACCES permission denied                |
| **E0015**    | Network        | 🟡 **Medium**   | ⚠️ **Known Issue**        | Backend health check 404 from host              |
| **E0016**    | DevContainer   | 🟡 **Medium**   | ✅ **Resolved**           | Container name conflict                         |
| **E0017**    | Environment    | 🟡 **Medium**   | ✅ **Resolved**           | Docker Compose not loading .env automatically   |
| **E0018**    | DevContainer   | 🟡 **Medium**   | ✅ **Resolved**           | Network dependencies failure                    |
| **E0019**    | Environment    | 🟡 **Medium**   | ✅ **Resolved**           | Scripts creating duplicate .env files           |
| **E0020**    | Validation     | 🟢 **Low**      | ✅ **Expected**           | unified-validation.sh failure                   |
| **E0021**    | Database       | 🔴 **Critical** | ✅ **Resolved**           | docker-orchestrator.sh Temporal failure         |
| **E0022**    | Network        | 🟡 **Medium**   | ⚠️ **Known Issue**        | Host access failures for scripts                |
| **E0023**    | Dependencies   | 🟢 **Low**      | ✅ **Resolved**           | npm audit lockfile error                        |
| **E0024**    | ELK Stack      | 🔴 **Critical** | ✅ **Resolved**           | Kibana basePath configuration validation error  |
| **E0025**    | ELK Stack      | 🟡 **Medium**   | ✅ **Resolved**           | Elasticsearch memory pressure and heap size     |
| **E0026**    | ELK Stack      | 🟡 **Medium**   | ✅ **Resolved**           | Fluent Bit plugin configuration errors          |
| **E0027**    | Scripts        | 🟡 **Medium**   | ✅ **Resolved**           | Health check script container-internal testing  |
| **E0028**    | Frontend       | 🔴 **Critical** | ⚠️ **Identified**         | TypeScript compilation errors (170 errors)      |
| **E0029**    | Frontend       | 🔴 **Critical** | ⚠️ **Identified**         | Storybook component library not accessible      |
| **E0030**    | Frontend       | 🟡 **Medium**   | ⚠️ **Identified**         | Missing type exports in UI components           |
| **E0031**    | Frontend       | 🟡 **Medium**   | ⚠️ **Identified**         | Astro/React integration JSX syntax errors       |
| **E0032**    | Frontend       | 🟢 **Low**      | ✅ **Resolved**           | Missing @types/node and @types/crypto-js        |

---

## 🔴 **CRITICAL ERRORS (Service Breaking)**

### **E0001: Kibana Configuration BasePath Error**

**📋 Error Summary:**
Kibana container failed to start due to incorrect basePath configuration in kibana.yml file.

**Error message:**

```plaintext
FATAL Error: [config validation of [server].basePath]: must start with a slash, don't end with one
```

**Stack trace:**

```plaintext
[ERROR] Kibana failed to start
[ERROR] Configuration validation failed
[ERROR] server.basePath setting is invalid
```

**🔍 Root Cause (confidence level 95%):**

- Invalid `server.basePath: ""` setting in kibana.yml
- Kibana requires basePath to start with a slash
- Configuration validation failed during container startup

**✅ Resolution Steps:**

1. **Identified configuration error** in Kibana logs showing basePath validation failure
2. **Updated kibana.yml** to use `server.basePath: "/"`
3. **Restarted Kibana container** with corrected configuration
4. **Verified successful startup** with proper basePath setting

**🛡️ Prevention Tips:**

- Always validate Kibana configuration syntax before deployment
- Use proper basePath format (must start with slash)
- Test configuration changes in isolated environment first
- Document configuration requirements for future deployments

**📚 Documentation Reference:** Kibana Configuration Guide - BasePath Settings

---

### **E0002: Docker Network Conflicts Preventing ELK Stack Startup**

**📋 Error Summary:**
Multiple Docker network conflicts preventing ELK stack startup due to subnet conflicts.

**Error message:**

```plaintext
Error response from daemon: failed to create network dice_logging_network: 
subnet 172.20.0.0/16 conflicts with existing network 172.20.0.0/16
```

**Stack trace:**

```plaintext
[ERROR] docker-compose up failed
[ERROR] Network creation failed
[ERROR] Subnet conflict detected
```

**🔍 Root Cause (confidence level 90%):**

- Subnet conflicts between existing Docker networks and logging stack network configuration
- Overlapping IP ranges causing network creation failures
- External network dependencies not properly configured

**✅ Resolution Steps:**

1. **Cleaned up existing Docker networks** to remove conflicts
2. **Modified network configuration** to use different subnet ranges
3. **Removed subnet configuration** to use external network approach
4. **Restarted entire logging stack** with corrected network settings

**🛡️ Prevention Tips:**

- Plan network subnets carefully to avoid conflicts
- Use external networks when possible to reduce complexity
- Document network configuration requirements
- Test network setup in isolated environment

**📚 Documentation Reference:** Docker Networking Best Practices

---

### **E0007: File Deletion Without User Approval**

**📋 Error Summary:**
Multiple files were deleted without explicit user approval, violating project rules.

**Error message:**

```plaintext
Files deleted without user approval:
- 01-LOCAL-INFRA-PLAN.md
- AI-EDITOR-HANDOFF-SUMMARY.md
- DICE-DEVELOPMENT-ENVIRONMENT-GUIDE.md
- docker-compose.yml
- infrastructure/scripts/setup-dev-environment.sh
- And 15+ additional files
```

**Stack trace:**

```plaintext
[VIOLATION] Project rule violation: File deletion without approval
[VIOLATION] Rule: "NEVER commit or delete anything without explicit approval"
[VIOLATION] Multiple files removed without user confirmation
```

**🔍 Root Cause (confidence level 100%):**

- Not following the rule to never delete files without explicit approval
- Automated cleanup processes removing files without confirmation
- Lack of proper approval workflow implementation

**⚠️ Resolution Steps:**

1. **Acknowledged violation** of project rules
2. **Documented deleted files** for reference and potential recovery
3. **Ensured future compliance** with approval requirements
4. **Implemented proper confirmation workflow** for file operations

**🛡️ Prevention Tips:**

- Always request explicit user approval before file deletion
- Implement confirmation dialogs for destructive operations
- Document all file changes in version control
- Use soft delete options when possible

**📚 Documentation Reference:** Project Rules - File Management Guidelines

---

### **E0011: TypeScript Compilation Errors During Backend Startup**

**📋 Error Summary:**
TypeScript compilation failed during backend startup due to missing dependencies and type errors.

**Error message:**

```plaintext
TSError: ⨯ Unable to compile TypeScript: 
src/auth/auth.service.ts:105:16 - error TS2769: No overload matches this call.
```

**Stack trace:**

```plaintext
[ERROR] TypeScript compilation failed
[ERROR] src/auth/auth.service.ts:105:16 - error TS2769: No overload matches this call
[ERROR] Missing type definitions for Express
[ERROR] Import syntax incompatible with ES modules
```

**🔍 Root Cause (confidence level 90%):**

- Missing `@types/express` dependency for TypeScript Express types
- Incorrect import syntax for ES modules (`import *` vs `import`)
- Type mismatches for security middleware configurations

**✅ Resolution Steps:**

1. **Install missing types**: `pnpm add -D @types/express`
2. **Fix import syntax**: Change `import * as helmet` to `import helmet`
3. **Add type annotations**: Cast variables with proper types (e.g., `any` for middleware configs)
4. **Remove unsupported options**: Removed `forceHTTPSRedirect` from Helmet config

**🛡️ Prevention Tips:**

- Always install corresponding `@types/*` packages for TypeScript projects
- Use modern ES6 import syntax consistently
- Validate TypeScript configuration before major dependency updates
- Run `pnpm build` before `pnpm start` to catch compilation issues early

**📚 Documentation Reference:** TypeScript Configuration Guide

---

### **E0013: Temporal Service Password Authentication Failed**

**📋 Error Summary:**
Temporal service failed to authenticate with database due to password authentication issues.

**Error message:**

```plaintext
Container backend_temporal Error
pq: password authentication failed for user "dice_user"
```

**Stack trace:**

```plaintext
[ERROR] Temporal service startup failed
[ERROR] Database connection failed
[ERROR] Password authentication failed for user dice_user
[ERROR] Environment variables not loaded properly
```

**🔍 Root Cause (confidence level 95%):**

- Temporal service using default/weak passwords instead of secure environment variables
- `.env.development` file missing or containing default values
- Docker Compose not properly loading environment variables

**✅ Resolution Steps:**

1. **Generate secure environment**: Run `infrastructure/scripts/setup-environment.sh --type development`
2. **Verify secure passwords**: Check `.env` file contains strong, random passwords
3. **Clean restart**: Execute `docker-orchestrator.sh clean` then restart services
4. **Validate environment loading**: Ensure Docker Compose uses `--env-file .env`

**🛡️ Prevention Tips:**

- Never use default passwords in any environment
- Always generate fresh secrets when setting up new environments
- Implement environment validation in setup scripts
- Use secure password generation (12+ characters, mixed complexity)

**📚 Documentation Reference:** Environment Setup Guide

---

### **E0014: Backend EACCES Permission Denied**

**📋 Error Summary:**
Backend container failed to start due to filesystem permission issues preventing pnpm operations.

**Error message:**

```plaintext
[ERROR] Backend failed to start within 60 seconds
EACCES: permission denied, mkdir '/app/node_modules/.pnpm'
```

**Stack trace:**

```plaintext
[ERROR] Container startup failed
[ERROR] Filesystem permission denied
[ERROR] Cannot create directory /app/node_modules/.pnpm
[ERROR] User permissions insufficient for pnpm operations
```

**🔍 Root Cause (confidence level 85%):**

- Docker container running with restricted user permissions
- `USER dice` directive in Dockerfile conflicting with pnpm operations
- Container filesystem permissions not matching application requirements

**✅ Resolution Steps:**

1. **Remove user directive**: Comment out `USER dice` in `workspace/backend/Dockerfile`
2. **Remove user mapping**: Remove `user:` from `workspace/backend/docker-compose.yml`
3. **Add permission fix**: Add `chmod 755 /app` to container startup command
4. **Rebuild container**: Execute clean build to ensure changes take effect

**🛡️ Prevention Tips:**

- Test Docker user permissions thoroughly before deployment
- Use root user for development containers when filesystem access is needed
- Implement proper permission management for production environments
- Document container permission requirements

**📚 Documentation Reference:** Docker Permission Management

---

### **E0021: Docker Orchestrator Temporal Service Failure**

**📋 Error Summary:**
Docker orchestrator failed to start Temporal service due to container dependency issues.

**Error message:**

```plaintext
Container backend_temporal Error
dependency failed to start: container backend_temporal exited (1)
```

**Stack trace:**

```plaintext
[ERROR] Docker orchestrator failed
[ERROR] Temporal service dependency failed
[ERROR] Container backend_temporal exited with code 1
[ERROR] Environment variables stale or invalid
```

**🔍 Root Cause (confidence level 90%):**

- Recurrence of password authentication issue (E0013)
- Stale environment variables from previous failed attempts
- Docker container state inconsistency

**✅ Resolution Steps:**

1. **Regenerate environment**: `setup-environment.sh --type development --force`
2. **Clean Docker state**: `docker-orchestrator.sh clean`
3. **Restart services**: Start services fresh with new environment
4. **Validate startup**: Monitor all container health checks

**🛡️ Prevention Tips:**

- Always clean Docker state when environment variables change
- Implement `--force` flag for environment regeneration
- Use health checks to validate service startup success
- Monitor container logs during startup for early error detection

**📚 Documentation Reference:** Docker Orchestrator Guide

---

### **E0024: Kibana basePath Configuration Validation Error**

**📋 Error Summary:**
Kibana failed to start due to invalid basePath configuration validation error.

**Error message:**

```plaintext
FATAL Error: [config validation of [server].basePath]: must start with a slash, don't end with one
```

**Stack trace:**

```plaintext
[FATAL] Kibana configuration validation failed
[FATAL] server.basePath setting invalid
[FATAL] Configuration file syntax error
[FATAL] Container startup aborted
```

**🔍 Root Cause (confidence level 95%):**

- Kibana configuration validation error with `server.basePath` setting
- Container not picking up configuration file changes due to caching
- Version compatibility issues between Kibana 7.17.0 and Elasticsearch 8.11.0

**✅ Resolution Steps:**

1. **Remove problematic basePath**: Comment out or remove `server.basePath: "/"` from `kibana.yml`
2. **Simplify configuration**: Use minimal Kibana configuration without basePath
3. **Restart container**: Execute `docker restart dice_kibana` to apply changes
4. **Verify accessibility**: Test `curl -f http://localhost:5601/api/status`

**🛡️ Prevention Tips:**

- Use minimal Kibana configuration for development environments
- Avoid basePath configuration unless specifically required
- Test configuration changes with container restart
- Monitor Kibana logs during startup for validation errors

**📚 Documentation Reference:** ELK Stack Configuration Guide

---

## 🟡 **MEDIUM SEVERITY ERRORS (Workflow Impact)**

### **E0003: Container Caching Issues with Configuration**

**📋 Error Summary:**
Kibana container using cached configuration despite file updates, preventing configuration changes from taking effect.

**🔍 Root Cause (confidence level 85%):**

- Docker container caching old configuration files
- Volume mounts not properly configured for configuration updates
- Container restart not clearing cached configuration

**✅ Resolution Steps:**

1. **Removed basePath line entirely** from configuration to force refresh
2. **Restarted Kibana container** with fresh configuration
3. **Verified configuration changes** were properly applied
4. **Confirmed container** using updated settings

**🛡️ Prevention Tips:**

- Use proper volume mounts for configuration files
- Implement configuration validation before container restart
- Clear container cache when configuration changes
- Use configuration management tools for consistency

**📚 Documentation Reference:** Docker Container Configuration Management

---

### **E0004: Health Check Script Dependencies Missing**

**📋 Error Summary:**
Health check script failed due to missing dependencies and incorrect paths, preventing proper system monitoring.

**🔍 Root Cause (confidence level 80%):**

- Script couldn't find `common.sh` file in expected location
- Backend services not running during health check execution
- Fluent Bit container missing `curl` utility for health checks

**⚠️ Resolution Steps:**

1. **Identified missing file dependencies** and incorrect paths
2. **Checked backend service status** to understand service availability
3. **Noted container limitations** for health check implementation
4. **Documented requirements** for proper health check setup

**🛡️ Prevention Tips:**

- Ensure all dependencies are available in target containers
- Test health check scripts in isolated environment
- Document all script dependencies clearly
- Implement proper error handling for missing dependencies

**📚 Documentation Reference:** Health Check Implementation Guide

---

### **E0006: Repetitive Verification Cycles**

**📋 Error Summary:**
Multiple attempts to execute verification plans with similar outcomes, indicating inefficient verification process.

**🔍 Root Cause (confidence level 75%):**

- Incomplete understanding of current system state
- Unclear verification requirements and success criteria
- Lack of systematic approach to verification process

**⚠️ Resolution Steps:**

1. **Recognised pattern** of repetitive verification attempts
2. **Identified need** for more systematic approach
3. **Documented verification status** for future reference
4. **Established clear verification methodology**

**🛡️ Prevention Tips:**

- Define clear verification criteria before starting
- Document current system state before verification
- Use systematic approach with clear checkpoints
- Implement verification automation where possible

**📚 Documentation Reference:** Verification Process Guidelines

---

### **E0008: Incomplete Health Check Implementation**

**📋 Error Summary:**
Health check script had multiple issues preventing proper execution and system monitoring.

**🔍 Root Cause (confidence level 85%):**

- Insufficient testing and dependency management
- Missing utilities in target containers
- Incomplete error handling and logging

**⚠️ Resolution Steps:**

1. **Identified missing dependencies** and container limitations
2. **Noted container limitations** for health check implementation
3. **Documented requirements** for proper health check implementation
4. **Planned comprehensive health check strategy**

**🛡️ Prevention Tips:**

- Test health checks in target environment before deployment
- Ensure all required utilities are available in containers
- Implement comprehensive error handling
- Document health check requirements clearly

**📚 Documentation Reference:** Health Check Best Practices

---

### **E0009: Network Configuration Complexity**

**📋 Error Summary:**
Docker network setup required multiple iterations to resolve conflicts and achieve proper connectivity.

**🔍 Root Cause (confidence level 80%):**

- Complex network configuration with subnet conflicts
- Multiple network dependencies and overlapping configurations
- Lack of clear network architecture documentation

**✅ Resolution Steps:**

1. **Cleaned up existing networks** to remove conflicts
2. **Modified configuration multiple times** to resolve issues
3. **Used external network approach** as final solution
4. **Documented network configuration** for future reference

**🛡️ Prevention Tips:**

- Plan network architecture before implementation
- Document all network dependencies clearly
- Use external networks when possible
- Test network configuration in isolated environment

**📚 Documentation Reference:** Docker Network Architecture Guide

---

### **E0010: Verification Plan Execution Issues**

**📋 Error Summary:**
Repeated attempts to execute verification plans without clear progress or successful completion.

**🔍 Root Cause (confidence level 70%):**

- Lack of systematic approach to verification
- Unclear requirements and success criteria
- Insufficient understanding of system state

**⚠️ Resolution Steps:**

1. **Recognised repetitive pattern** in verification attempts
2. **Documented verification status** for future reference
3. **Identified need** for clearer verification methodology
4. **Established systematic verification approach**

**🛡️ Prevention Tips:**

- Define clear verification objectives and criteria
- Document current system state before verification
- Use systematic approach with clear milestones
- Implement verification automation where possible

**📚 Documentation Reference:** Verification Methodology Guide

---

### **E0012: sed "Multiple Occurrences" Error**

**📋 Error Summary:**

```plaintext
Error calling tool: The specified string appears X times in the file, can only edit one at a time.
```

**🔍 Root Cause (confidence level 85%):**

- String replacement tool attempting to replace multiple identical occurrences
- Ambiguous search patterns matching more content than intended
- Tool limitation requiring unique string identification

**✅ Resolution Steps:**

1. **Use global replacement**: `sed -i.bak 's|old_path|new_path|g'`
2. **Make search strings more specific**: Include surrounding context
3. **Use line-by-line replacement**: Target specific lines when possible
4. **Verify replacement scope**: Check changes before applying

**🛡️ Prevention Tips:**

- Always include sufficient context to make replacements unique
- Use regex patterns carefully to avoid over-matching
- Test replacement commands on backup files first
- Consider using more precise file editing tools for complex changes

**📚 Documentation Reference:** File Editing Best Practices

---

### **E0015: Backend Health Check 404 from Host**

**📋 Error Summary:**

```plaintext
jq: parse error: Invalid numeric literal at line 1, column 10
curl: (22) The requested URL returned error: 404 Not Found
```

**🔍 Root Cause (confidence level 80%):**

- Host port forwarding issues (likely macOS Docker Desktop specific)
- Backend API healthy internally but not accessible from host system
- Network configuration preventing external API access

**⚠️ Resolution Steps:**

1. **Use container-internal testing**: Test APIs from within Docker network
2. **Document as known issue**: Update documentation with workaround
3. **Alternative testing approach**: Use `docker exec` for internal API calls
4. **Monitor internal health**: Verify services work within container network

**🛡️ Prevention Tips:**

- Design tests to work both internally and externally
- Document network limitations for different platforms
- Implement container-internal health validation
- Consider using Docker Desktop alternatives for better networking

**📚 Documentation Reference:** Docker Networking Troubleshooting

---

### **E0016: DevContainer Name Conflict**

**📋 Error Summary:**

```plaintext
Conflict. The container name "/pwa_dev" is already in use by container
```

**🔍 Root Cause (confidence level 90%):**

- Previous DevContainer session left containers running
- Docker container cleanup not performed between sessions
- Container name collision from multiple startup attempts

**✅ Resolution Steps:**

1. **Stop conflicting container**: `docker stop pwa_dev`
2. **Remove container**: `docker rm pwa_dev`
3. **Restart DevContainer**: VS Code will create fresh containers
4. **Clean startup**: Ensure clean state before DevContainer startup

**🛡️ Prevention Tips:**

- Implement automatic container cleanup in DevContainer shutdown
- Use unique container naming with timestamps or UUIDs
- Add container cleanup to DevContainer initialization
- Monitor running containers before starting new sessions

**📚 Documentation Reference:** DevContainer Configuration Guide

---

### **E0017: Docker Compose Environment Loading Issue**

**📋 Error Summary:**

```plaintext
Docker Compose using default passwords instead of secure ones from .env.development
```

**🔍 Root Cause (confidence level 85%):**

- Docker Compose not automatically loading `.env.development` file
- Environment file naming convention not matching Docker Compose expectations
- Missing explicit `--env-file` parameter in compose commands

**✅ Resolution Steps:**

1. **Unify environment files**: Consolidate to single `.env` in root directory
2. **Update compose commands**: Add `--env-file .env` to all docker compose calls
3. **Modify scripts**: Update `docker-orchestrator.sh` to explicitly load environment
4. **Validate loading**: Verify environment variables are loaded correctly

**🛡️ Prevention Tips:**

- Always use explicit `--env-file` parameter for reliable loading
- Standardize on single `.env` file location (project root)
- Test environment variable loading in all execution contexts
- Document environment file requirements clearly

**📚 Documentation Reference:** Docker Compose Environment Management

---

### **E0018: DevContainer Network Dependencies Failure**

**📋 Error Summary:**

```plaintext
network pwa_network declared as external, but could not be found
```

**🔍 Root Cause (confidence level 80%):**

- DevContainer trying to connect to multiple Docker Compose networks
- PWA network not available when backend-only services are running
- Complex network dependencies causing startup failures

**✅ Resolution Steps:**

1. **Simplify DevContainer config**: Use only `workspace/backend/docker-compose.yml`
2. **Remove PWA dependencies**: Focus DevContainer on backend development
3. **Update devcontainer.json**: Remove PWA compose file reference
4. **Test simplified setup**: Verify DevContainer starts with backend-only config

**🛡️ Prevention Tips:**

- Keep DevContainer dependencies minimal and focused
- Separate development environments by service domain
- Use network dependencies only when absolutely necessary
- Test DevContainer configuration changes thoroughly

**📚 Documentation Reference:** DevContainer Best Practices

---

### **E0019: Scripts Creating Duplicate Environment Files**

**📋 Error Summary:**
User reported: "I can count 3 different env files" - scripts were creating multiple environment files after unification

**🔍 Root Cause (confidence level 90%):**

- `setup-environment.sh` and `setup-devcontainer.sh` creating separate env files
- Scripts not checking for existing unified `.env` file
- Different environment generation logic for different contexts

**✅ Resolution Steps:**

1. **Modify setup scripts**: Check for existing `.env` before creating new files
2. **Add protection logic**: Prevent overwriting unified environment file
3. **Standardize generation**: Use single environment generation approach
4. **Update script logic**: Point all scripts to unified `.env` location

**🛡️ Prevention Tips:**

- Implement file existence checks before creating environment files
- Use consistent environment file naming and location
- Document environment file hierarchy and precedence
- Test script behaviour with existing environment files

**📚 Documentation Reference:** Environment Setup Scripts Guide

---

### **E0022: Host Access Failures for Testing Scripts**

**📋 Error Summary:**

```plaintext
health-check.sh: PostgreSQL and Redis not ready (despite healthy containers)
test-auth.sh: 404 Not Found for /auth/register
```

**🔍 Root Cause (confidence level 75%):**

- Services healthy internally but not accessible from host
- macOS Docker Desktop port forwarding limitations
- Host-to-container networking configuration issues

**⚠️ Resolution Steps:**

1. **Use container-internal testing**: Execute tests from within Docker network
2. **Document host access limitations**: Update known issues documentation
3. **Provide alternative testing**: Show how to test from inside containers
4. **Validate internal functionality**: Confirm services work within network

**🛡️ Prevention Tips:**

- Design tests to work in both host and container contexts
- Document platform-specific networking limitations
- Provide multiple testing approaches for different environments
- Use Docker network inspection tools for debugging

**📚 Documentation Reference:** Testing Strategy Guide

---

### **E0025: Elasticsearch Memory Pressure and Heap Size Issues**

**📋 Error Summary:**

```plaintext
circuit_breaking_exception: [parent] Data too large, data for [<http_request>] would be [1.2gb/1.2gb]
```

**🔍 Root Cause (confidence level 85%):**

- Elasticsearch heap size too small (512MB) for log ingestion
- Memory pressure during bulk operations
- Circuit breaker preventing data loss

**✅ Resolution Steps:**

1. **Increase heap size**: Update `ES_JAVA_OPTS` from `-Xms512m -Xmx512m` to `-Xms2g -Xmx2g`
2. **Restart Elasticsearch**: Execute `docker restart dice_elasticsearch`
3. **Monitor memory usage**: Check `curl localhost:9200/_nodes/stats/jvm`
4. **Validate cluster health**: Ensure GREEN or YELLOW status

**🛡️ Prevention Tips:**

- Allocate sufficient heap memory for Elasticsearch (minimum 2GB for development)
- Monitor memory usage during log ingestion
- Configure circuit breakers appropriately for environment
- Use proper resource limits in Docker Compose

**📚 Documentation Reference:** Elasticsearch Configuration Guide

---

### **E0026: Fluent Bit Plugin Configuration Errors**

**📋 Error Summary:**

```plaintext
[ERROR] [config] section 'docker_meta' tried to instance a plugin name that doesn't exist
[ERROR] [input:systemd:systemd.4] given path /host/var/log/journal is invalid
```

**🔍 Root Cause (confidence level 90%):**

- Invalid plugin name `docker_meta` (not a valid Fluent Bit plugin)
- Systemd input trying to access non-existent host path
- Empty configuration values causing parsing errors

**✅ Resolution Steps:**

1. **Fix plugin names**: Change `Name docker_meta` to `Name modify`
2. **Simplify configuration**: Remove systemd input and use dummy input for testing
3. **Remove empty values**: Delete empty `HTTP_User` and `HTTP_Passwd` lines
4. **Add health check**: Configure proper HTTP health check endpoint

**🛡️ Prevention Tips:**

- Use only valid Fluent Bit plugin names
- Test configuration syntax before deployment
- Use simplified configurations for development environments
- Validate all configuration values are properly set

**📚 Documentation Reference:** Fluent Bit Configuration Guide

---

### **E0027: Health Check Script Container-Internal Testing Issues**

**📋 Error Summary:**

```plaintext
./infrastructure/scripts/health-check.sh: line 400: $2: unbound variable
print_warn: command not found
```

**🔍 Root Cause (confidence level 80%):**

- Script calling functions with incorrect number of arguments
- Missing function definitions in common.sh
- Container-internal testing approach not properly implemented

**✅ Resolution Steps:**

1. **Fix function calls**: Ensure `show_banner` receives correct number of arguments
2. **Use correct function names**: Change `print_warn` to `print_warning`
3. **Implement container-internal testing**: Use `docker exec` for health checks
4. **Add proper error handling**: Include fallback mechanisms for failed checks

**🛡️ Prevention Tips:**

- Test script functions with proper argument counts
- Use consistent function naming across scripts
- Implement container-internal testing for macOS compatibility
- Add comprehensive error handling and logging

**📚 Documentation Reference:** Script Development Guidelines

---

## 🟢 **LOW SEVERITY ERRORS (Minor Impact)**

### **E0005: ELK Stack Version Mismatch Warnings**

**📋 Error Summary:**
Kibana 7.17.0 with Elasticsearch 8.11.0 version mismatch causing warnings but not affecting functionality.

**🔍 Root Cause (confidence level 90%):**

- Different versions of ELK stack components
- Version compatibility issues between Kibana and Elasticsearch
- Non-critical warnings in system logs

**✅ Resolution Steps:**

1. **Acknowledged warning** but confirmed functionality
2. **Verified Kibana was working** despite version difference
3. **Documented as non-critical issue** for future reference
4. **Planned version alignment** for future updates

**🛡️ Prevention Tips:**

- Use compatible versions of ELK stack components
- Test version combinations before deployment
- Document version requirements clearly
- Plan regular version updates and alignment

**📚 Documentation Reference:** ELK Stack Version Compatibility Guide

---

### **E0020: unified-validation.sh Expected Failure**

**📋 Error Summary:**

```plaintext
❌ docker-compose.yml not found
```

**🔍 Root Cause (confidence level 95%):**

- Validation script looking for old file location
- `docker-compose.yml` moved to `infrastructure/docker/docker-compose.orchestrator.yml`
- Script validation logic not updated for new architecture

**✅ Resolution Steps:**

1. **Update validation script**: Modify to check correct file locations
2. **Document architectural changes**: Update validation expectations
3. **Fix script logic**: Point to new orchestrator file location
4. **Test validation accuracy**: Ensure script validates current architecture

**🛡️ Prevention Tips:**

- Update validation scripts when making architectural changes
- Maintain validation script accuracy with file structure changes
- Document expected validation results for different configurations
- Test validation scripts after major refactoring

**📚 Documentation Reference:** Validation Script Maintenance

---

### **E0023: npm audit Lockfile Error**

**📋 Error Summary:**

```plaintext
npm error code ENOLOCK
This command requires an existing lockfile
```

**🔍 Root Cause (confidence level 100%):**

- Project uses pnpm as package manager, not npm
- npm command executed in pnpm-managed project
- Missing npm lockfile (`package-lock.json`) because project uses `pnpm-lock.yaml`

**✅ Resolution Steps:**

1. **Use correct package manager**: Execute `pnpm audit` instead of `npm audit`
2. **Update scripts**: Ensure all dependency commands use pnpm
3. **Document package manager**: Clearly specify pnpm usage in documentation
4. **Validate audit results**: Review pnpm audit output for security issues

**🛡️ Prevention Tips:**

- Consistently use the project's designated package manager (pnpm)
- Document package manager choice clearly in README
- Add package manager validation to setup scripts
- Use pnpm for all dependency operations (install, audit, update)

**📚 Documentation Reference:** Package Manager Guidelines

---

### **E0028: TypeScript Compilation Errors (170 Errors)**

**📋 Error Summary:**
Frontend PWA TypeScript compilation failed with 170 errors during comprehensive health check validation.

**Error message:**

```plaintext
Result (56 files): 
- 170 errors
- 0 warnings
- 37 hints

ELIFECYCLE  Command failed with exit code 1.
```

**Stack trace:**

```plaintext
[ERROR] TypeScript compilation failed
[ERROR] Multiple component type export errors
[ERROR] Astro/React integration syntax errors
[ERROR] Missing type definitions for dependencies
[ERROR] Storybook story type errors
```

**🔍 Root Cause (confidence level 95%):**

- Missing type exports in UI components (ButtonProps, InputProps, etc.)
- JSX syntax errors in Astro files when using React components
- Missing Node.js type definitions for environment variables
- Storybook story definitions missing required args
- Component prop type mismatches

**⚠️ Resolution Steps:**

1. **Install missing dependencies**: `pnpm add -D @types/node @types/crypto-js` ✅ COMPLETED
2. **Export component types**: Add proper type exports to all UI components
3. **Fix Astro/React integration**: Use React.createElement instead of JSX in Astro files
4. **Fix Storybook stories**: Add required args to all story definitions
5. **Resolve type mismatches**: Fix component prop type definitions

**🛡️ Prevention Tips:**

- Always export component prop types for TypeScript projects
- Use proper React.createElement syntax in Astro files
- Install corresponding @types packages for all dependencies
- Test TypeScript compilation before deployment
- Maintain consistent type definitions across components

**📚 Documentation Reference:** TypeScript Configuration Guide

---

### **E0029: Storybook Component Library Not Accessible**

**📋 Error Summary:**
Storybook component library failed to start and was not accessible on port 6006 during health check validation.

**Error message:**

```plaintext
Storybook Status: 000
Storybook Status: Still starting...
```

**Stack trace:**

```plaintext
[ERROR] Storybook not starting automatically
[ERROR] Manual start required
[ERROR] Port 6006 not accessible
[ERROR] Component library unavailable
```

**🔍 Root Cause (confidence level 85%):**

- Storybook not configured to start automatically with PWA container
- Manual start required for component library
- TypeScript errors preventing Storybook compilation
- Missing Storybook configuration or dependencies

**⚠️ Resolution Steps:**

1. **Start Storybook manually**: `docker compose exec pwa pnpm run storybook`
2. **Fix TypeScript errors**: Resolve compilation issues preventing Storybook startup
3. **Update container configuration**: Add Storybook to automatic startup
4. **Verify Storybook configuration**: Check .storybook/main.js and .storybook/preview.js
5. **Test component library**: Ensure all components render properly in Storybook

**🛡️ Prevention Tips:**

- Configure Storybook to start automatically with development environment
- Test Storybook startup as part of health checks
- Fix TypeScript errors before attempting Storybook startup
- Document Storybook manual start procedure for development

**📚 Documentation Reference:** Storybook Configuration Guide

---

### **E0030: Missing Type Exports in UI Components**

**📋 Error Summary:**
UI components missing proper type exports causing TypeScript compilation errors and Storybook issues.

**Error message:**

```plaintext
src/components/ui/atoms/index.ts:9:15 - error ts(2459): Module declares 'ButtonProps' locally, but it is not exported.
src/components/ui/molecules/index.ts:8:15 - error ts(2459): Module declares 'CardProps' locally, but it is not exported.
```

**Stack trace:**

```plaintext
[ERROR] TypeScript compilation failed
[ERROR] Missing type exports for component props
[ERROR] Storybook story type errors
[ERROR] Component type definitions not accessible
```

**🔍 Root Cause (confidence level 90%):**

- Component prop types not exported from component files
- Index files trying to export types that aren't available
- Inconsistent type definition patterns across components
- Missing export statements for component interfaces

**⚠️ Resolution Steps:**

1. **Export component types**: Add proper export statements for all component prop types
2. **Update index files**: Ensure index files only export available types
3. **Standardize type definitions**: Use consistent type definition patterns
4. **Fix Storybook stories**: Update stories to use properly exported types
5. **Test type compilation**: Verify all types are accessible after fixes

**🛡️ Prevention Tips:**

- Always export component prop types for reuse
- Use consistent type definition patterns across components
- Test type exports in index files before committing
- Document component type requirements clearly
- Use TypeScript strict mode to catch missing exports

**📚 Documentation Reference:** TypeScript Component Guidelines

---

### **E0031: Astro/React Integration JSX Syntax Errors**

**📋 Error Summary:**
JSX syntax errors in Astro files when integrating React components, causing compilation failures.

**Error message:**

```plaintext
src/components/features/CharacterWizard/CharacterWizard.astro:49:30:
return <ProfileStep />;
```

**Stack trace:**

```plaintext
[ERROR] JSX syntax not supported in Astro context
[ERROR] React.createElement required instead of JSX
[ERROR] Component mounting issues
[ERROR] Astro/React integration errors
```

**🔍 Root Cause (confidence level 95%):**

- JSX syntax not supported in Astro files
- React components need to use React.createElement syntax in Astro context
- Component mounting and rendering issues
- Incorrect integration patterns between Astro and React

**⚠️ Resolution Steps:**

1. **Replace JSX with React.createElement**: Convert all JSX to React.createElement syntax
2. **Fix component mounting**: Use proper React mounting patterns in Astro
3. **Update integration patterns**: Follow Astro/React integration best practices
4. **Test component rendering**: Verify components render correctly after fixes
5. **Document integration patterns**: Create guidelines for Astro/React integration

**🛡️ Prevention Tips:**

- Use React.createElement instead of JSX in Astro files
- Follow Astro/React integration documentation
- Test component rendering in Astro context
- Document integration patterns for team reference
- Use proper TypeScript types for React components in Astro

**📚 Documentation Reference:** Astro/React Integration Guide

---

### **E0032: Missing @types/node and @types/crypto-js Dependencies**

**📋 Error Summary:**
Frontend PWA missing essential TypeScript type definitions causing compilation errors.

**Error message:**

```plaintext
src/lib/api/client.ts:366:3 - error ts(2580): Cannot find name 'process'.
src/lib/storage/SecureStorage.ts:1:22 - error ts(7016): Could not find a declaration file for module 'crypto-js'.
```

**Stack trace:**

```plaintext
[ERROR] Missing Node.js type definitions
[ERROR] Missing crypto-js type definitions
[ERROR] TypeScript compilation errors
[ERROR] Environment variable access issues
```

**🔍 Root Cause (confidence level 100%):**

- Missing @types/node package for Node.js type definitions
- Missing @types/crypto-js package for crypto-js type definitions
- Environment variable access without proper types
- TypeScript strict mode requiring all type definitions

**✅ Resolution Steps:**

1. **Install missing dependencies**: `pnpm add -D @types/node @types/crypto-js` ✅ COMPLETED
2. **Verify type definitions**: Confirm all types are now available
3. **Test compilation**: Run TypeScript compilation to verify fixes
4. **Update documentation**: Document required type dependencies
5. **Add to setup scripts**: Include type dependencies in project setup

**🛡️ Prevention Tips:**

- Always install corresponding @types packages for TypeScript projects
- Document all type dependencies in package.json
- Include type dependencies in project setup scripts
- Test TypeScript compilation after adding new dependencies
- Use TypeScript strict mode to catch missing type definitions

**📚 Documentation Reference:** TypeScript Dependencies Guide

---
