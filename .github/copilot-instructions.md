# NP-Linux-Scripts Copilot Instructions

## Project Overview

NP-Linux-Scripts is a collection of modular Bash shell scripts for Linux system administration tasks. Each script is self-contained, organized by functionality into subdirectories, with accompanying README files. Scripts are designed to be sourced or called individually from cron jobs, profiles, or other automation tools.

## Repository Structure

- **auto-updates/**: Automatic system update scripts (Debian/RHEL variants)
- **backup/**: Backup and archiving utilities
- **disk-usage/**: Disk space monitoring scripts
- **docker/**: Docker environment management
- **first-boot/**: Initial server setup and SSH key generation
- **git/**: Git repository automation
- **hostname/**: Hostname configuration
- **logrotate/**: Log file rotation and compression
- **monitoring/**: System performance and connection monitoring
- **ping/**: Network utilities with timestamp logging
- **service/**: Service status checking and management
- **ssl/**: SSL certificate validation and expiration checking
- **user/**: User account management

## Script Conventions & Patterns

### Argument Parsing
All scripts use `getopts` for command-line options. Common flags:
- `-d`: Directory or domain
- `-p`: Port (defaults to 443 for SSL)
- `-n`: Name or hostname
- `-s`: Source directory
- `-b`: Backup directory or branch

Error handling for invalid options is consistent:
```bash
while getopts ":d:p:n:" opt; do
  case ${opt} in
    d) DOMAIN="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2; exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2; exit 1 ;;
  esac
done
```

### Platform Compatibility
Scripts should handle **both GNU tools (Linux) and BSD tools (macOS)**:
- `date` command differs between systems (use conditional checks with `date --version` for detection)
- `sed`, `awk`, `grep` may have different flags
- Always test cross-platform when modifying system utilities

### Timestamps
Use the standard format for consistency:
```bash
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # or "%Y%m%d" for date-only
```

### Root Privilege Handling
Scripts should either:
- Explicitly check and reject root execution (e.g., first-boot.sh)
- Use `sudo` for individual commands requiring elevation
- Document in README which privileges are required

### Error Output
Send error messages to stderr:
```bash
echo "Error message" >&2
exit 1
```

### Logging & Output
- Simple scripts print to stdout
- For cron jobs, redirect output to log files
- Log file paths are typically `/var/log/` with format `{script_name}.log`
- Rotation is handled by the logrotate script

## Key Scripts & Common Usage Patterns

### SSL Certificate Management
**Script**: `ssl/check-certificate.sh`
```bash
./ssl/check-certificate.sh -d gitlab.nilpeter.com -p 443
```
Returns days until expiration. Use in cron for monitoring (runs daily/weekly).

### User Management
**Script**: `user/adduser.sh`
```bash
./user/adduser.sh -n username
```
Creates user, prompts for password, adds to sudo group.

### Git Auto-Pull
**Script**: `git/git-auto-pull.sh`
```bash
./git/git-auto-pull.sh -d /path/to/repo
```
Pulls latest code from `main` branch. Typical cron usage: `0 * * * * /path/to/git-auto-pull.sh -d /var/www/app`

### Backup Operations
**Script**: `backup/backup.sh`
```bash
./backup/backup.sh -s /source -d /backup/dir -n backup_name
```
Creates timestamped tar.gz file: `backup_name_backup_YYYYMMDDHHMMSS.tar.gz`

### Log Rotation
**Script**: `logrotate/logrotate.sh`
```bash
./logrotate/logrotate.sh -s /var/log/app.log -d /backup/logs -n app
```
Moves and compresses log files with date stamp.

### System Monitoring
**Script**: `monitoring/monitoring.sh` (requires `ifstat` tool)
```bash
# Add to crontab for hourly reports:
0 * * * * /path/to/monitoring.sh >> /var/log/system_monitor.log
```
Tracks CPU, memory, disk, and network stats. `monitoring_html.sh` outputs HTML for email reports.

### First Boot Setup
**Script**: `first-boot/first-boot.sh`
Runs once to:
1. Set hostname (prompts user)
2. Generate new SSH host keys (RSA, ECDSA, Ed25519)
3. Creates lockfile `~/.first-boot` to prevent re-execution

Typical usage: Add to `~/.profile` on fresh servers, runs automatically on first login.

### Hostname Configuration
**Script**: `hostname/set-hostname.sh`
```bash
./set-hostname.sh -n new-hostname
```
Uses systemd on modern systems.

## Testing & Validation

**No formal test suite exists.** Validate changes by:
1. Running the script locally or in a VM
2. Testing on both Linux (Debian/RHEL) and macOS if changes affect:
   - Date/time operations
   - System calls (systemctl, useradd, etc.)
   - String manipulation (sed, awk, grep)
3. Update the corresponding README with usage examples
4. Check for hardcoded paths and ensure scripts work across environments

## Important Implementation Notes

- **Avoid absolute paths** where possible; use relative or user-provided paths instead
- **Variable expansion**: Use `${VAR}` syntax consistently (not `$VAR`)
- **Quote handling**: Use double quotes for variable expansion, single quotes for literals
- **Exit codes**: Return 0 on success, 1 on error (standard convention)
- **Idempotency**: Scripts should be safe to run multiple times (especially for cron jobs)
- **Documentation**: Every script needs a README in its directory with purpose and usage examples

## Known Limitations & Future Improvements

- Monitoring scripts require `ifstat` to be pre-installed; not all systems ship with it by default
- Error handling is minimal in some scripts; add validation for missing arguments when enhancing
- No centralized logging/alerting; each script handles its own output independently
- Cross-platform testing should be expanded (currently mostly Linux-focused)

## Useful External Resources

- Git repo is often installed at `${HOME}/NP-Linux-Scripts` or symlinked to `/path/to/linux-scripts`
- Related systems: Uses Smarthost freja.nilpeter.com for email reports
- Monitoring server: Can send logs to external Smarthost for centralized alerting
