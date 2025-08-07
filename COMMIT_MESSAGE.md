fix: New shell-agnostic architecture implementation

**Core Change**: Converted DICE development environment from shell-specific to universal POSIX-compliant architecture

### **🔧 Key Improvements**

**Shell Compatibility**
- ✅ POSIX-compliant scripts (works with zsh, bash, dash, any POSIX shell)
- ✅ Removed shell-specific features (associative arrays, BASH_SOURCE)
- ✅ Universal path resolution and script loading

**Architecture Enhancements**
- ✅ Unified service management with string-based configurations
- ✅ Helper functions for data lookup (`get_service_config`, `get_profile_config`)
- ✅ Clean Makefile without explicit shell specifications

**New Features**
- ✅ Profile support for orchestrator service (`--proxy`)
- ✅ Comprehensive development workflows (`quick-start`, `dev-*`, `test-*`)
- ✅ Enhanced health monitoring and backup/restore capabilities

### **�� Code Cleanup**
- ✅ Removed legacy ELK stack management targets
- ✅ Consolidated logging and health check functionality
- ✅ Eliminated redundant targets and improved organization

### **✅ Validation**
- ✅ Tested with zsh, bash, dash
- ✅ Verified `make quick-start` works across all shells
- ✅ All service management commands operational

### **📈 Benefits**
- **Universal**: Works on macOS, Linux, BSD with any POSIX shell
- **Maintainable**: Follows shell scripting best practices
- **Backward Compatible**: No breaking changes, existing commands work

**Result**: Shell-agnostic DICE development environment with enhanced workflows and universal compatibility 🚀