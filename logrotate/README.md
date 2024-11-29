## logrotate.sh
- Moves the current log to a backup directory, compresses it, and creates a new log file.
- Keeps logs manageable in size.

### Usage:
./logrotate.sh -s /path/to/your.log -d /path/to/destination/directory -n your-log-name
