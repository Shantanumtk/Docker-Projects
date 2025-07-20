#!/bin/bash

# Enhanced Cron Replayer Script with Mail Logic
# Author: Enhanced Mail Logic Implementation
# Version: 1.0
# Description: Replays cron jobs with time window tracking and detailed email reporting

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/cron_config.json"
LOG_FILE="${SCRIPT_DIR}/cron_replayer.log"
MAIL_TEMPLATE_DIR="${SCRIPT_DIR}/mail_templates"

# Global variables for tracking
declare -A SERVICE_WINDOWS=()
declare -A SUCCESSFUL_RUNS=()
declare -A FAILED_RUNS=()
declare -A SKIPPED_RUNS=()
declare -A EXECUTION_TIMES=()
declare -A ERROR_MESSAGES=()

# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Initialize tracking arrays
init_tracking() {
    log "INFO" "Initializing cron replayer tracking system"
    
    # Clear and initialize tracking arrays
    SUCCESSFUL_RUNS=()
    FAILED_RUNS=()
    SKIPPED_RUNS=()
    EXECUTION_TIMES=()
    ERROR_MESSAGES=()
    
    declare -gA SUCCESSFUL_RUNS FAILED_RUNS SKIPPED_RUNS EXECUTION_TIMES ERROR_MESSAGES
}

# Parse time window configuration from JSON
parse_time_windows() {
    log "INFO" "Parsing time window configuration from $CONFIG_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Extract service time windows from JSON using basic parsing
    # This is a simplified approach - in production, consider using jq
    while IFS= read -r line; do
        if [[ $line =~ \"([^\"]+)\":[[:space:]]*\{ ]]; then
            local service="${BASH_REMATCH[1]}"
            continue
        elif [[ $line =~ \"opdeact\":[[:space:]]*\"([^\"]+)\" ]]; then
            SERVICE_WINDOWS["${service}_deact"]="${BASH_REMATCH[1]}"
        elif [[ $line =~ \"opact\":[[:space:]]*\"([^\"]+)\" ]]; then
            SERVICE_WINDOWS["${service}_act"]="${BASH_REMATCH[1]}"
        fi
    done < "$CONFIG_FILE"
    
    log "INFO" "Loaded ${#SERVICE_WINDOWS[@]} time window entries"
}

# Check if current time is within service window
is_within_window() {
    local service="$1"
    local current_time="$2"
    
    local deact_key="${service}_deact"
    local act_key="${service}_act"
    
    if [[ -n "${SERVICE_WINDOWS[$deact_key]:-}" && -n "${SERVICE_WINDOWS[$act_key]:-}" ]]; then
        local deact_time="${SERVICE_WINDOWS[$deact_key]}"
        local act_time="${SERVICE_WINDOWS[$act_key]}"
        
        # Convert to timestamps for comparison - handle invalid dates gracefully
        local deact_ts=$(date -d "$deact_time" +%s 2>/dev/null || echo "0")
        local act_ts=$(date -d "$act_time" +%s 2>/dev/null || echo "0")
        local current_ts=$(date -d "$current_time" +%s 2>/dev/null || echo "0")
        
        # If any timestamp is invalid, assume outside window
        if [[ $deact_ts -eq 0 || $act_ts -eq 0 || $current_ts -eq 0 ]]; then
            return 1  # Outside window or invalid time
        fi
        
        if [[ $current_ts -ge $deact_ts && $current_ts -le $act_ts ]]; then
            return 0  # Within window
        fi
    fi
    
    return 1  # Outside window
}

# Simulate cron job execution
execute_cron_job() {
    local service="$1"
    local job_name="$2"
    local command="$3"
    local execution_time="$4"
    
    log "INFO" "Executing cron job: $service/$job_name"
    
    local start_time=$(date +%s)
    local status="SUCCESS"
    local error_msg=""
    
    # Check if within time window
    if ! is_within_window "$service" "$execution_time"; then
        status="SKIPPED"
        # Check if it's due to invalid time format
        if ! date -d "$execution_time" +%s >/dev/null 2>&1; then
            error_msg="Invalid execution time format"
            log "ERROR" "Job $service/$job_name skipped - invalid time format: $execution_time"
        else
            error_msg="Outside service time window"
            log "WARN" "Job $service/$job_name skipped - outside time window"
        fi
    else
        # Simulate job execution (85% success rate for more realistic failures)
        local failure_chance=$(( RANDOM % 100 ))
        if [[ $failure_chance -lt 85 ]]; then
            # Simulate successful execution with basic sleep
            sleep $(( (RANDOM % 3) + 1 ))
            log "INFO" "Job $service/$job_name completed successfully"
        else
            # Simulate failure
            status="FAILED"
            error_msg="Simulated execution failure - command returned non-zero exit code"
            log "ERROR" "Job $service/$job_name failed: $error_msg"
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Record execution results
    local job_key="${service}/${job_name}"
    EXECUTION_TIMES["$job_key"]="$duration"
    
    if [[ "$status" == "SUCCESS" ]]; then
        SUCCESSFUL_RUNS["$job_key"]="$execution_time|$duration|$command"
    elif [[ "$status" == "FAILED" ]]; then
        FAILED_RUNS["$job_key"]="$execution_time|$duration|$command"
        ERROR_MESSAGES["$job_key"]="$error_msg"
    elif [[ "$status" == "SKIPPED" ]]; then
        SKIPPED_RUNS["$job_key"]="$execution_time|$duration|$command"
        ERROR_MESSAGES["$job_key"]="$error_msg"
    fi
    
    return 0
}

# Generate email summary section
generate_summary_section() {
    local total_jobs=$((${#SUCCESSFUL_RUNS[@]} + ${#FAILED_RUNS[@]} + ${#SKIPPED_RUNS[@]}))
    local success_count=${#SUCCESSFUL_RUNS[@]}
    local failure_count=${#FAILED_RUNS[@]}
    local skipped_count=${#SKIPPED_RUNS[@]}
    local success_rate=0
    local eligible_jobs=$((${#SUCCESSFUL_RUNS[@]} + ${#FAILED_RUNS[@]}))
    
    if [[ $eligible_jobs -gt 0 ]]; then
        success_rate=$(( (success_count * 100) / eligible_jobs ))
    fi
    
    cat << EOF
CRON REPLAYER EXECUTION SUMMARY
===============================
Execution Date: $(date '+%Y-%m-%d %H:%M:%S')
Total Jobs Processed: $total_jobs
Successful Executions: $success_count
Failed Executions: $failure_count
Skipped Executions: $skipped_count
Success Rate (Eligible Jobs): ${success_rate}%

EOF
}

# Generate time windows section
generate_time_windows_section() {
    cat << EOF
SERVICE TIME WINDOWS (OPDEACT/OPACT)
====================================
EOF
    
    local services=()
    for key in "${!SERVICE_WINDOWS[@]}"; do
        local service="${key%_*}"
        if [[ ! " ${services[*]} " =~ " ${service} " ]]; then
            services+=("$service")
        fi
    done
    
    for service in "${services[@]}"; do
        local deact_time="${SERVICE_WINDOWS[${service}_deact]:-N/A}"
        local act_time="${SERVICE_WINDOWS[${service}_act]:-N/A}"
        
        if [[ "$deact_time" != "N/A" && "$act_time" != "N/A" ]]; then
            local deact_ts=$(date -d "$deact_time" +%s 2>/dev/null || echo "0")
            local act_ts=$(date -d "$act_time" +%s 2>/dev/null || echo "0")
            local duration_hours=0
            
            if [[ $deact_ts -gt 0 && $act_ts -gt 0 ]]; then
                duration_hours=$(( (act_ts - deact_ts) / 3600 ))
            fi
            
            printf "Service: %-15s OPDEACT: %-20s OPACT: %-20s Duration: %dh\n" \
                "$service" "$deact_time" "$act_time" "$duration_hours"
        fi
    done
    
    echo ""
}

# Generate successful executions section
generate_successful_section() {
    cat << EOF
SUCCESSFUL EXECUTIONS
====================
EOF
    
    if [[ ${#SUCCESSFUL_RUNS[@]} -eq 0 ]]; then
        echo "No successful executions recorded."
        echo ""
        return
    fi
    
    printf "%-25s %-20s %-12s %s\n" "Job" "Execution Time" "Duration(s)" "Command"
    printf "%-25s %-20s %-12s %s\n" "---" "-------------- " "-----------" "-------"
    
    for job in "${!SUCCESSFUL_RUNS[@]}"; do
        IFS='|' read -r exec_time duration command <<< "${SUCCESSFUL_RUNS[$job]}"
        printf "%-25s %-20s %-12s %s\n" "$job" "$exec_time" "${duration}s" "$command"
    done
    
    echo ""
}

# Generate failed executions section
generate_failed_section() {
    cat << EOF
FAILED EXECUTIONS
=================
EOF
    
    if [[ ${#FAILED_RUNS[@]} -eq 0 ]]; then
        echo "No failed executions recorded."
        echo ""
        return
    fi
    
    printf "%-25s %-20s %-12s %s\n" "Job" "Execution Time" "Duration(s)" "Error"
    printf "%-25s %-20s %-12s %s\n" "---" "-------------- " "-----------" "-----"
    
    for job in "${!FAILED_RUNS[@]}"; do
        IFS='|' read -r exec_time duration command <<< "${FAILED_RUNS[$job]}"
        local error_msg="${ERROR_MESSAGES[$job]:-Unknown error}"
        printf "%-25s %-20s %-12s %s\n" "$job" "$exec_time" "${duration}s" "$error_msg"
    done
    
    echo ""
}

# Generate skipped executions section
generate_skipped_section() {
    cat << EOF
SKIPPED EXECUTIONS
==================
EOF
    
    if [[ ${#SKIPPED_RUNS[@]} -eq 0 ]]; then
        echo "No skipped executions recorded."
        echo ""
        return
    fi
    
    printf "%-25s %-20s %-12s %s\n" "Job" "Execution Time" "Reason" "Command"
    printf "%-25s %-20s %-12s %s\n" "---" "-------------- " "------" "-------"
    
    for job in "${!SKIPPED_RUNS[@]}"; do
        IFS='|' read -r exec_time duration command <<< "${SKIPPED_RUNS[$job]}"
        local skip_reason="${ERROR_MESSAGES[$job]:-Unknown reason}"
        printf "%-25s %-20s %-12s %s\n" "$job" "$exec_time" "$skip_reason" "$command"
    done
    
    echo ""
}

# Generate debug information section
generate_debug_section() {
    cat << EOF
DEBUG INFORMATION
=================
Script Version: 1.0
Execution Host: $(hostname)
Script Path: $SCRIPT_DIR
Log File: $LOG_FILE
Total Memory Usage: $(free -h | awk 'NR==2{printf "%.1f%%", $3/$2*100}' 2>/dev/null || echo "N/A")
Load Average: $(uptime | awk -F'load average:' '{print $2}' | xargs 2>/dev/null || echo "N/A")

Recent Log Entries:
$(tail -n 5 "$LOG_FILE" 2>/dev/null || echo "No recent log entries available")

EOF
}

# Generate complete email report
generate_email_report() {
    local email_file="${SCRIPT_DIR}/cron_report_$(date +%Y%m%d_%H%M%S).txt"
    
    log "INFO" "Generating email report: $email_file"
    
    {
        generate_summary_section
        generate_time_windows_section
        generate_successful_section
        generate_failed_section
        generate_skipped_section
        generate_debug_section
    } > "$email_file"
    
    echo "$email_file"
}

# Simulate sending email (placeholder for actual email sending)
send_email_report() {
    local report_file="$1"
    local recipient="${EMAIL_RECIPIENT:-admin@example.com}"
    local subject="Cron Replayer Report - $(date '+%Y-%m-%d %H:%M:%S')"
    
    log "INFO" "Email report generated: $report_file"
    log "INFO" "Would send email to: $recipient with subject: $subject"
    
    # In a real implementation, this would use mail/sendmail/SMTP
    # mail -s "$subject" "$recipient" < "$report_file"
    
    echo "Email report saved to: $report_file"
}

# Parse and execute cron jobs from configuration
execute_configured_jobs() {
    local execution_time="$1"
    
    log "INFO" "Executing configured cron jobs"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Parse services and their cron jobs from JSON
    local current_service=""
    local in_cron_jobs=false
    local job_name=""
    local job_command=""
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Match service name
        if [[ $line =~ \"([^\"]+)\":[[:space:]]*\{ ]] && [[ $line != *"cron_jobs"* ]] && [[ $line != *"email_settings"* ]] && [[ $line != *"logging"* ]]; then
            current_service="${BASH_REMATCH[1]}"
            in_cron_jobs=false
            continue
        fi
        
        # Check if we're in the cron_jobs array
        if [[ $line =~ \"cron_jobs\":[[:space:]]*\[ ]]; then
            in_cron_jobs=true
            continue
        fi
        
        # End of cron_jobs array
        if [[ $in_cron_jobs == true && $line == *"]"* ]]; then
            in_cron_jobs=false
            continue
        fi
        
        # Parse job properties
        if [[ $in_cron_jobs == true ]]; then
            if [[ $line =~ \"name\":[[:space:]]*\"([^\"]+)\" ]]; then
                job_name="${BASH_REMATCH[1]}"
            elif [[ $line =~ \"command\":[[:space:]]*\"([^\"]+)\" ]]; then
                job_command="${BASH_REMATCH[1]}"
                
                # Execute job when we have both name and command
                if [[ -n "$job_name" && -n "$job_command" && -n "$current_service" ]]; then
                    execute_cron_job "$current_service" "$job_name" "$job_command" "$execution_time"
                    job_name=""
                    job_command=""
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}

# Main execution function
main() {
    log "INFO" "Starting Enhanced Cron Replayer Script"
    
    # Initialize tracking
    init_tracking
    
    # Parse configuration
    parse_time_windows
    
    # Get current time or use provided time
    local execution_time="${1:-$(date '+%Y-%m-%d %H:%M:%S')}"
    
    # For demonstration, use a time within some windows
    if [[ $# -eq 0 ]]; then
        execution_time="2024-01-15 04:30:00"
    fi
    
    log "INFO" "Executing cron jobs for time: $execution_time"
    
    # Execute configured cron jobs
    execute_configured_jobs "$execution_time"
    
    # Generate and send email report
    local report_file
    report_file=$(generate_email_report)
    send_email_report "$report_file"
    
    log "INFO" "Cron replayer execution completed"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi