# Enhanced Cron Replayer with Mail Logic

## Overview

The Enhanced Cron Replayer is a comprehensive script designed to simulate and track cron job executions across multiple services with detailed time window management and email reporting capabilities. It provides enhanced mail logic that includes time windows (OPDEACT & OPACT), execution tracking, and detailed error reporting.

## Features

### Core Functionality
- **Time Window Management**: Track OPDEACT (deactivation) and OPACT (activation) times for each service
- **Execution Simulation**: Simulate cron job executions with realistic success/failure rates
- **Comprehensive Tracking**: Monitor successful, failed, and skipped executions
- **Detailed Reporting**: Generate structured email reports with multiple sections

### Enhanced Mail Logic
- **Summary Section**: Overall statistics and execution overview
- **Time Windows Section**: OPDEACT/OPACT times and duration for each service
- **Successful Executions**: Detailed list with timing information
- **Failed Executions**: Error details and troubleshooting info
- **Skipped Executions**: Jobs that were outside their service windows
- **Debug Information**: Enhanced logging and system information

## File Structure

```
Shell-Script-Container/
├── cron_replayer.sh      # Main cron replayer script
├── cron_config.json      # Configuration file for services and time windows
├── cron_replayer.log     # Execution log file (generated)
├── cron_report_*.txt     # Email reports (generated)
├── test_script.sh        # Original test script (preserved)
├── Dockerfile            # Updated Docker configuration
└── README_CRON.md        # This documentation
```

## Configuration

### cron_config.json Structure

The configuration file defines services, their time windows, and associated cron jobs:

```json
{
  "services": {
    "service1": {
      "name": "Database Service",
      "opdeact": "2024-01-15 02:00:00",
      "opact": "2024-01-15 06:00:00",
      "cron_jobs": [
        {
          "name": "backup_job",
          "command": "/usr/bin/backup.sh",
          "schedule": "0 3 * * *",
          "description": "Daily database backup"
        }
      ]
    }
  },
  "email_settings": {
    "recipients": ["admin@example.com"],
    "sender": "cron-replayer@example.com"
  }
}
```

## Usage

### Basic Usage

```bash
# Run with current time
./cron_replayer.sh

# Run with specific execution time
./cron_replayer.sh "2024-01-15 04:30:00"
```

### Docker Usage

```bash
# Build the container
docker build -t enhanced-cron-replayer .

# Run the cron replayer in the container
docker run -it --name cron-replayer-instance enhanced-cron-replayer bash /root/cron_replayer.sh

# Run with specific time
docker run -it --name cron-replayer-instance enhanced-cron-replayer bash /root/cron_replayer.sh "2024-01-15 04:30:00"
```

## Output Examples

### Sample Email Report

```
CRON REPLAYER EXECUTION SUMMARY
===============================
Execution Date: 2025-07-20 07:46:45
Total Jobs Processed: 5
Successful Executions: 4
Failed Executions: 1
Skipped Executions: 0
Success Rate (Eligible Jobs): 80.00%

SERVICE TIME WINDOWS (OPDEACT/OPACT)
====================================
Service: service1        OPDEACT: 2024-01-15 02:00:00  OPACT: 2024-01-15 06:00:00  Duration: 4.00h
Service: service2        OPDEACT: 2024-01-15 01:30:00  OPACT: 2024-01-15 07:30:00  Duration: 6.00h

SUCCESSFUL EXECUTIONS
====================
Job                       Execution Time       Duration(s)  Command
---                       --------------       -----------  -------
service1/backup_job       2024-01-15 04:00:00  1.411        /usr/bin/backup.sh
service2/sync_job         2024-01-15 04:00:00  1.194        /usr/bin/sync.sh

FAILED EXECUTIONS
=================
Job                       Execution Time       Duration(s)  Error
---                       --------------       -----------  -----
service1/cleanup_job      2024-01-15 04:00:00  0.007        Simulated execution failure - command returned non-zero exit code
```

### Console Output

```
[2025-07-20 07:46:41] [INFO] Starting Enhanced Cron Replayer Script
[2025-07-20 07:46:41] [INFO] Initializing cron replayer tracking system
[2025-07-20 07:46:41] [INFO] Parsing time window configuration from cron_config.json
[2025-07-20 07:46:41] [INFO] Loaded 6 time window entries
[2025-07-20 07:46:41] [INFO] Executing cron jobs for time: 2024-01-15 04:00:00
[2025-07-20 07:46:42] [INFO] Job service1/backup_job completed successfully
[2025-07-20 07:46:42] [ERROR] Job service1/cleanup_job failed: Simulated execution failure
[2025-07-20 07:46:45] [INFO] Email report generated: cron_report_20250720_074645.txt
```

## Key Features Implemented

### Time Window Management
- **OPDEACT/OPACT Tracking**: Each service has defined deactivation and activation times
- **Window Validation**: Jobs are only executed if the execution time falls within the service window
- **Duration Calculation**: Automatic calculation of service window durations

### Execution Tracking
- **Status Monitoring**: Track SUCCESS, FAILED, and SKIPPED status for each job
- **Timing Information**: Record execution duration for performance analysis
- **Error Messages**: Capture detailed error information for failed executions

### Enhanced Reporting
- **Structured Output**: Multiple report sections for different types of information
- **Statistics**: Success rates, execution counts, and performance metrics
- **Debugging**: System information, log entries, and troubleshooting data

### Error Handling
- **Graceful Failures**: Handle missing dependencies and configuration errors
- **Logging**: Comprehensive logging with different severity levels
- **Recovery**: Fallback mechanisms for calculation and timing functions

## Customization

### Adding New Services

1. Edit `cron_config.json` to add new service definitions
2. Include OPDEACT/OPACT times and cron job definitions
3. Run the script to automatically pick up the new configuration

### Modifying Report Format

The report generation functions can be customized:
- `generate_summary_section()`: Modify summary statistics
- `generate_time_windows_section()`: Adjust time window display
- `generate_successful_section()`: Customize successful execution format
- `generate_failed_section()`: Modify error reporting format

### Simulation Parameters

Adjust simulation behavior by modifying:
- Failure rate (currently 15% failure chance)
- Execution duration ranges
- Sleep times and delays

## Backward Compatibility

The implementation preserves all existing functionality:
- Original `test_script.sh` remains unchanged
- Docker container still runs the original script by default
- New functionality is additive and doesn't break existing workflows

## Dependencies

- **bash**: For advanced shell scripting features
- **gawk**: For floating-point calculations
- **coreutils**: For date manipulation and system utilities

## Troubleshooting

### Common Issues

1. **Configuration File Not Found**
   - Ensure `cron_config.json` exists in the script directory
   - Check file permissions and JSON syntax

2. **Time Parsing Errors**
   - Verify date format: "YYYY-MM-DD HH:MM:SS"
   - Ensure system date utilities are available

3. **Permission Errors**
   - Make script executable: `chmod +x cron_replayer.sh`
   - Check write permissions for log and report files

### Debug Mode

Enable verbose logging by setting:
```bash
export LOG_LEVEL=DEBUG
./cron_replayer.sh
```

This implementation provides a complete cron replayer system with enhanced mail logic that meets all the requirements specified in the problem statement while maintaining backward compatibility with the existing Docker projects repository structure.