#!/bin/bash
# Continuous test watcher using inotifywait (more efficient than polling)
#
# Usage:
#   ./watch_tests.sh
#
# Requires: inotify-tools
#   Ubuntu/Debian: apt-get install inotify-tools
#   Mac: brew install fswatch (use fswatch instead)

echo "========================================"
echo "EvoDiff Continuous Test Watcher (Shell)"
echo "========================================"
echo "Watching .m files for changes..."
echo "Press Ctrl+C to stop"
echo ""

# Run tests once at startup
echo "Running initial tests..."
matlab -batch "run_tests()" 2>&1

# Watch for changes
if command -v inotifywait &> /dev/null; then
    # Linux with inotifywait
    while true; do
        inotifywait -q -e modify,create -r . --include '.*\.m$' 2>/dev/null

        echo ""
        echo "========================================"
        echo "[$(date +%H:%M:%S)] Change detected, running tests..."
        echo "========================================"
        echo ""

        # Run tests
        matlab -batch "run_tests()" 2>&1

        # Wait a bit to avoid multiple triggers
        sleep 1
    done
elif command -v fswatch &> /dev/null; then
    # macOS with fswatch
    fswatch -o -e ".*" -i "\\.m$" . | while read change; do
        echo ""
        echo "========================================"
        echo "[$(date +%H:%M:%S)] Change detected, running tests..."
        echo "========================================"
        echo ""

        # Run tests
        matlab -batch "run_tests()" 2>&1

        # Wait a bit to avoid multiple triggers
        sleep 1
    done
else
    echo "ERROR: Neither inotifywait nor fswatch found."
    echo "Install one of:"
    echo "  Linux: apt-get install inotify-tools"
    echo "  macOS: brew install fswatch"
    exit 1
fi
