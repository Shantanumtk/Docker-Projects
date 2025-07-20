#!/bin/bash

# Test script for Enhanced Cron Replayer with Mail Logic
# Author: Test Suite for Cron Replayer
# Version: 1.0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRON_SCRIPT="${SCRIPT_DIR}/cron_replayer.sh"
TEST_LOG="${SCRIPT_DIR}/test_results.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

log_test() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$TEST_LOG"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    log_test "Running test: $test_name"
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    # Run the test command and capture output
    local output
    if output=$(eval "$test_command" 2>&1); then
        if [[ -n "$expected_pattern" && ! $output =~ $expected_pattern ]]; then
            echo -e "${RED}FAILED: Expected pattern '$expected_pattern' not found${NC}"
            log_test "FAILED: $test_name - Pattern not found"
            return 1
        else
            echo -e "${GREEN}PASSED${NC}"
            log_test "PASSED: $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        fi
    else
        echo -e "${RED}FAILED: Command failed with exit code $?${NC}"
        log_test "FAILED: $test_name - Command failed"
        return 1
    fi
}

# Initialize test log
echo "Enhanced Cron Replayer Test Suite - $(date)" > "$TEST_LOG"
echo "===========================================" >> "$TEST_LOG"

echo "Enhanced Cron Replayer Test Suite"
echo "=================================="

# Test 1: Script existence and permissions
run_test "Script exists and is executable" \
    "test -x '$CRON_SCRIPT'" \
    ""

# Test 2: Configuration file exists
run_test "Configuration file exists" \
    "test -f '${SCRIPT_DIR}/cron_config.json'" \
    ""

# Test 3: Basic script execution
run_test "Basic script execution" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00'" \
    "Cron replayer execution completed"

# Test 4: Time window validation - jobs within window
run_test "Jobs execute within time window" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00' | grep -c 'completed successfully'" \
    "[0-9]"

# Test 5: Time window validation - jobs outside window
run_test "Jobs skipped outside time window" \
    "'$CRON_SCRIPT' '2024-01-15 01:00:00' | grep -c 'skipped - outside time window'" \
    "[0-9]"

# Test 6: Email report generation
run_test "Email report generated" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00' && find '$SCRIPT_DIR' -name 'cron_report_*.txt' -mmin -1 | wc -l" \
    "1"

# Test 7: Report contains all required sections
LATEST_REPORT=$(find "$SCRIPT_DIR" -name 'cron_report_*.txt' -mmin -5 | head -1)
if [[ -n "$LATEST_REPORT" ]]; then
    run_test "Report contains summary section" \
        "grep -c 'CRON REPLAYER EXECUTION SUMMARY' '$LATEST_REPORT'" \
        "1"
    
    run_test "Report contains time windows section" \
        "grep -c 'SERVICE TIME WINDOWS' '$LATEST_REPORT'" \
        "1"
    
    run_test "Report contains execution sections" \
        "grep -c 'SUCCESSFUL EXECUTIONS\|FAILED EXECUTIONS\|SKIPPED EXECUTIONS' '$LATEST_REPORT'" \
        "[1-9]"
    
    run_test "Report contains debug information" \
        "grep -c 'DEBUG INFORMATION' '$LATEST_REPORT'" \
        "1"
fi

# Test 8: Configuration parsing
run_test "Configuration parsing works" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00' | grep -c 'Loaded [0-9]* time window entries'" \
    "1"

# Test 9: Log file creation
run_test "Log file created" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00' && test -f '${SCRIPT_DIR}/cron_replayer.log'" \
    ""

# Test 10: Different execution scenarios
run_test "Mixed success/failure scenario" \
    "'$CRON_SCRIPT' '2024-01-15 04:30:00' | grep -E '(completed successfully|failed)'" \
    ""

# Test 11: Edge case - invalid time format
run_test "Handles invalid time format gracefully" \
    "'$CRON_SCRIPT' 'invalid-time' | grep -c 'invalid time format'" \
    "[1-9]"

# Summary
echo ""
echo "Test Results Summary"
echo "==================="
echo -e "Tests Run: ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"

if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Check $TEST_LOG for details.${NC}"
    exit 1
fi