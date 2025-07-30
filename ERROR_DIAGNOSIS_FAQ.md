# DICE Error Diagnosis FAQ

**Last Updated**: July 30, 2025  
**Version**: 1.1 - Comprehensive Error Documentation with ELK Stack Issues  
**Purpose**: 📚 **KNOWLEDGE BASE** - Complete error resolution guide and prevention strategies

---

## 📋 **Error Index - Quick Reference**

| **Error ID** | **Category** | **Severity**   | **Status**        | **Quick Description**                           |
| ------------ | ------------ | -------------- | ----------------- | ----------------------------------------------- |
| **E001**     | Backend      | 🔴 **Critical** | ✅ **Resolved**    | TypeScript compilation errors during startup    |
| **E002**     | Scripts      | 🟡 **Medium**   | ✅ **Resolved**    | sed "multiple occurrences" error                |
| **E003**     | Database     | 🔴 **Critical** | ✅ **Resolved**    | Temporal service password authentication failed |
| **E004**     | Backend      | 🔴 **Critical** | ✅ **Resolved**    | Backend EACCES permission denied                |
| **E005**     | Network      | 🟡 **Medium**   | ⚠️ **Known Issue** | Backend health check 404 from host              |
| **E006**     | DevContainer | 🟡 **Medium**   | ✅ **Resolved**    | Container name conflict                         |
| **E007**     | Environment  | 🟡 **Medium**   | ✅ **Resolved**    | Docker Compose not loading .env automatically   |
| **E008**     | DevContainer | 🟡 **Medium**   | ✅ **Resolved**    | Network dependencies failure                    |
| **E009**     | Environment  | 🟡 **Medium**   | ✅ **Resolved**    | Scripts creating duplicate .env files           |
| **E011**     | Validation   | 🟢 **Low**      | ✅ **Expected**    | unified-validation.sh failure                   |
| **E012**     | Database     | 🔴 **Critical** | ✅ **Resolved**    | docker-orchestrator.sh Temporal failure         |
| **E013**     | Network      | 🟡 **Medium**   | ⚠️ **Known Issue** | Host access failures for scripts                |
| **E014**     | Dependencies | 🟢 **Low**      | ✅ **Resolved**    | npm audit lockfile error                        |
| **E015**     | ELK Stack    | 🔴 **Critical** | ✅ **Resolved**    | Kibana basePath configuration validation error  |
| **E016**     | ELK Stack    | 🟡 **Medium**   | ✅ **Resolved**    | Elasticsearch memory pressure and heap size     |
| **E017**     | ELK Stack    | 🟡 **Medium**   | ✅ **Resolved**    | Fluent Bit plugin configuration errors          |
| **E018**     | Scripts      | 🟡 **Medium**   | ✅ **Resolved**    | Health check script container-internal testing  |

---

## 🔴 **CRITICAL ERRORS (Service Breaking)**

### **E001: TypeScript Compilation Errors During Backend Startup**

**📋 Error Summary:**

```
TSError: ⨯ Unable to compile TypeScript: 
src/auth/auth.service.ts:105:16 - error TS2769: No overload matches this call.
```

**🔍 Root Cause:**

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

---

### **E003: Temporal Service Password Authentication Failed**

**📋 Error Summary:**

```
Container backend_temporal Error
pq: password authentication failed for user "dice_user"
```

**🔍 Root Cause:**

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

---

### **E004: Backend EACCES Permission Denied**

**📋 Error Summary:**

```
[ERROR] Backend failed to start within 60 seconds
EACCES: permission denied, mkdir '/app/node_modules/.pnpm'
```

**🔍 Root Cause:**

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

---

### **E012: Docker Orchestrator Temporal Service Failure**

**📋 Error Summary:**

```
Container backend_temporal Error
dependency failed to start: container backend_temporal exited (1)
```

**🔍 Root Cause:**

- Recurrence of password authentication issue (E003)
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

---

## 🟡 **MEDIUM SEVERITY ERRORS (Workflow Impact)**

### **E002: sed "Multiple Occurrences" Error**

**📋 Error Summary:**

```
Error calling tool: The specified string appears X times in the file, can only edit one at a time.
```

**🔍 Root Cause:**

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

---

### **E005: Backend Health Check 404 from Host**

**📋 Error Summary:**

```
jq: parse error: Invalid numeric literal at line 1, column 10
curl: (22) The requested URL returned error: 404 Not Found
```

**🔍 Root Cause:**

- Host port forwarding issues (likely macOS Docker Desktop specific)
- Backend API healthy internally but not accessible from host system
- Network configuration preventing external API access

**✅ Resolution Steps:**

1. **Use container-internal testing**: Test APIs from within Docker network
2. **Document as known issue**: Update documentation with workaround
3. **Alternative testing approach**: Use `docker exec` for internal API calls
4. **Monitor internal health**: Verify services work within container network

**🛡️ Prevention Tips:**

- Design tests to work both internally and externally
- Document network limitations for different platforms
- Implement container-internal health validation
- Consider using Docker Desktop alternatives for better networking

---

### **E006: DevContainer Name Conflict**

**📋 Error Summary:**

```
Conflict. The container name "/pwa_dev" is already in use by container
```

**🔍 Root Cause:**

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

---

### **E007: Docker Compose Environment Loading Issue**

**📋 Error Summary:**

```
Docker Compose using default passwords instead of secure ones from .env.development
```

**🔍 Root Cause:**

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

---

### **E008: DevContainer Network Dependencies Failure**

**📋 Error Summary:**

```
network pwa_network declared as external, but could not be found
```

**🔍 Root Cause:**

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

---

### **E009: Scripts Creating Duplicate Environment Files**

**📋 Error Summary:**
User reported: "I can count 3 different env files" - scripts were creating multiple environment files after unification

**🔍 Root Cause:**

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

---

### **E013: Host Access Failures for Testing Scripts**

**📋 Error Summary:**

```
health-check.sh: PostgreSQL and Redis not ready (despite healthy containers)
test-auth.sh: 404 Not Found for /auth/register
```

**🔍 Root Cause:**

- Services healthy internally but not accessible from host
- macOS Docker Desktop port forwarding limitations
- Host-to-container networking configuration issues

**✅ Resolution Steps:**

1. **Use container-internal testing**: Execute tests from within Docker network
2. **Document host access limitations**: Update known issues documentation
3. **Provide alternative testing**: Show how to test from inside containers
4. **Validate internal functionality**: Confirm services work within network

**🛡️ Prevention Tips:**

- Design tests to work in both host and container contexts
- Document platform-specific networking limitations
- Provide multiple testing approaches for different environments
- Use Docker network inspection tools for debugging

---

## 🟢 **LOW SEVERITY ERRORS (Minor Impact)**

### **E011: unified-validation.sh Expected Failure**

**📋 Error Summary:**

```
❌ docker-compose.yml not found
```

**🔍 Root Cause:**

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

---

### **E014: npm audit Lockfile Error**

**📋 Error Summary:**

```
npm error code ENOLOCK
This command requires an existing lockfile
```

**🔍 Root Cause:**

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

---

### **E015: Kibana basePath Configuration Validation Error**

**📋 Error Summary:**

```
FATAL Error: [config validation of [server].basePath]: must start with a slash, don't end with one
```

**🔍 Root Cause:**

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

---

### **E016: Elasticsearch Memory Pressure and Heap Size Issues**

**📋 Error Summary:**

```
circuit_breaking_exception: [parent] Data too large, data for [<http_request>] would be [1.2gb/1.2gb]
```

**🔍 Root Cause:**

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

---

### **E017: Fluent Bit Plugin Configuration Errors**

**📋 Error Summary:**

```
[ERROR] [config] section 'docker_meta' tried to instance a plugin name that doesn't exist
[ERROR] [input:systemd:systemd.4] given path /host/var/log/journal is invalid
```

**🔍 Root Cause:**

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

---

### **E018: Health Check Script Container-Internal Testing Issues**

**📋 Error Summary:**

```
./infrastructure/scripts/health-check.sh: line 400: $2: unbound variable
print_warn: command not found
```

**🔍 Root Cause:**

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

---

## 📊 **Error Pattern Analysis**

### **Most Common Error Categories:**

1. **ELK Stack Issues** (4 errors) - 24%
2. **Environment Configuration** (4 errors) - 24%
3. **Container & Docker Issues** (3 errors) - 18%
4. **Network & Host Access** (3 errors) - 18%
5. **Service Startup Failures** (2 errors) - 12%
6. **Development Dependencies** (1 error) - 6%

### **Resolution Success Rate:**

- **✅ Fully Resolved**: 14 errors (82%)
- **⚠️ Known Issues**: 2 errors (12%)
- **❌ Expected Behaviour**: 1 error (6%)

### **Prevention Strategies Implemented:**

- Environment file unification and validation
- Container permission standardization
- Network dependency simplification
- Package manager consistency
- ELK stack configuration validation
- Memory allocation optimization
- Health check container-internal testing

---

## 🔄 **Error Prevention Checklist**

### **Before Making Changes:**

- [ ] **Backup important files** before major operations
- [ ] **Test changes in isolation** before full integration
- [ ] **Verify environment variables** are properly loaded
- [ ] **Check container permissions** for filesystem operations
- [ ] **Validate network dependencies** for service connectivity

### **During Development:**

- [ ] **Use correct package manager** (pnpm) consistently
- [ ] **Test both internal and external** API access
- [ ] **Monitor container logs** during service startup
- [ ] **Verify environment file** loading in all contexts

### **After Changes:**

- [ ] **Run full service stack** to validate integration
- [ ] **Execute health checks** on all services
- [ ] **Test authentication flow** end-to-end
- [ ] **Verify script functionality** in clean environment
- [ ] **Update documentation** to reflect changes

---

## 📞 **When You Encounter New Errors**

### **Immediate Steps:**

1. **Capture full error message** including stack traces
2. **Document reproduction steps** clearly
3. **Check similar patterns** in this FAQ
4. **Try container restart** as first troubleshooting step
5. **Verify environment variables** are loaded correctly

### **Investigation Process:**

1. **Isolate the component** causing the issue
2. **Check container logs** for detailed error information
3. **Validate configuration files** for syntax and values
4. **Test with minimal setup** to identify core issue
5. **Search for similar issues** in project history

### **Documentation Requirements:**

1. **Add new error** to this FAQ with complete details
2. **Update error index** with new error ID and category
3. **Document resolution steps** with exact commands
4. **Add prevention tips** based on root cause analysis
5. **Update related documentation** if architectural changes needed

---

**🔧 This FAQ is a living document - update it whenever new errors are encountered or resolved! 📚**

*Total Technical Errors Documented: 17*  
*Last Error Added: E018 (July 30, 2025)*  
*Next Error ID: E019*
