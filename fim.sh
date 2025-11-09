#!/bin/bash
# ================================================================
#  FILE INTEGRITY MONITOR (FIM) v1.0
#  Author: David Olutimi
#  Description:
#     A Bash-based File Integrity Monitoring tool that creates
#     SHA256 baselines for files, monitors changes, and sends
#     email alerts when unauthorized modifications are detected.
# ================================================================


# ────────────────────────────────────────────────────────────────
#  DISPLAY HELP / BANNER
#  Shown when the user runs the script without arguments.
# ────────────────────────────────────────────────────────────────
if [[ -z "$1" ]]; then
    echo "┌──────────────────────────────────────────┐"
    sleep 0.1s
    echo "│   ███████╗██╗███╗   ███╗                 │"
    sleep 0.1s
    echo "│   ██╔════╝██║████╗ ████║                 │"
    sleep 0.1s
    echo "│   █████╗  ██║██╔████╔██║                 │"
    sleep 0.1s
    echo "│   ██╔══╝  ██║██║╚██╔╝██║    FILE         │"
    sleep 0.1s
    echo "│   ██╔══╝  ██║██║╚██╔╝██║    INTEGRITY    │"
    sleep 0.1s
    echo "│   ██║     ██║██║ ╚═╝ ██║    MONITOR      │"
    sleep 0.1s
    echo "│   ╚═╝     ╚═╝╚═╝     ╚═╝    (FIM) v1.0   │"
    sleep 0.1s
    echo "│------------------------------------------│"
    sleep 0.1s
    echo "│  Usage: fim [--baseline | --check        │"
    sleep 0.1s
    echo "│              --monitor | --stop | --update] │"
    sleep 0.1s
    echo "└──────────────────────────────────────────┘"
    exit 0
fi


# ────────────────────────────────────────────────────────────────
#  BASELINE FUNCTION
#  Purpose:
#     Creates or updates a hash baseline for a specific file.
#     The baseline is stored at ~/.fim/baselines.txt
# ────────────────────────────────────────────────────────────────
baselineMethod() {
    target="$1"

    # Validate file existence
    if [ ! -f "$target" ]; then
        echo "[ERROR] File not found: $target"
        exit 1
    fi

    # Generate absolute path (for consistency) and SHA256 hash
    absolute_path=$(realpath "$target")
    hash_val=$(sha256sum "$absolute_path" | awk '{print $1}')

    # Ensure the baseline directory exists
    mkdir -p ~/.fim

    # If baseline exists, replace it; else append it
    if grep -q "$absolute_path" ~/.fim/baselines.txt 2>/dev/null; then
        sed -i "/$absolute_path/c\\$hash_val $absolute_path" ~/.fim/baselines.txt
        echo "[OK] Baseline updated for $absolute_path"
    else
        echo "$hash_val $absolute_path" >> ~/.fim/baselines.txt
        echo "[OK] Baseline created for $absolute_path"
    fi
}


# ────────────────────────────────────────────────────────────────
#  CHECK FUNCTION
#  Purpose:
#     Compares the current file hash with the stored baseline
#     to detect unauthorized modifications.
# ────────────────────────────────────────────────────────────────
checkBaselineMethod() {
    target="$1"

    # Validate target file
    if [ ! -f "$target" ]; then
        echo "[ERROR] File not found: $target"
        exit 1
    fi

    # Extract the baseline hash for the file
    absolute_path=$(realpath "$target")
    baseline_line=$(grep "$absolute_path" ~/.fim/baselines.txt 2>/dev/null)

    if [ -z "$baseline_line" ]; then
        echo "[ERROR] No baseline found for $absolute_path"
        exit 1
    fi

    baseline_hash=$(echo "$baseline_line" | awk '{print $1}')
    current_hash=$(sha256sum "$absolute_path" | awk '{print $1}')

    # Compare the stored and current hash values
    if [ "$current_hash" = "$baseline_hash" ]; then
        echo "[OK] No changes detected for $absolute_path"
        exit 0
    else
        echo "[WARNING] File modified: $absolute_path"
        echo "         Previous hash: $baseline_hash"
        echo "         Current hash : $current_hash"
        exit 1
    fi
}


# ────────────────────────────────────────────────────────────────
#  MONITOR FUNCTION
#  Purpose:
#     Continuously monitors a file for changes and sends an
#     alert email via msmtp when the file’s hash changes.
# ────────────────────────────────────────────────────────────────
monitorFileMethod() {
    target="$1"
    email="$2"

    # Validate target and email
    if [ ! -f "$target" ]; then
        echo "[ERROR] File not found: $target"
        exit 1
    fi
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
        echo "[ERROR] Invalid email address: $email"
        exit 1
    fi

    # Retrieve baseline info
    absolute_path=$(realpath "$target")
    baseline_line=$(grep "$absolute_path" ~/.fim/baselines.txt 2>/dev/null)

    if [ -z "$baseline_line" ]; then
        echo "[ERROR] No baseline found for $target. Please run --baseline first."
        exit 1
    fi

    baseline_hash=$(echo "$baseline_line" | awk '{print $1}')
    mkdir -p ~/.fim
    log_file=~/.fim/fim_report.log

    echo "[INFO] Monitoring $target... alerts will be sent to $email"

    # Continuous monitoring loop
    while true; do
        # Handle deletion
        if [ ! -f "$target" ]; then
            echo "[ALERT] File deleted: $target" | tee -a "$log_file"

            # Send alert email using msmtp
            printf "Subject: [FIM ALERT] File Deleted\n\nThe monitored file at $absolute_path was deleted on $(date)." \
                | msmtp "$email"
            exit 1
        fi

        # Check file hash
        current_hash=$(sha256sum "$target" | awk '{print $1}')

        # Compare hashes to detect changes
        if [ "$current_hash" != "$baseline_hash" ]; then
            echo "[ALERT] File changed: $target" | tee -a "$log_file"

            # Prepare detailed email body
            body=$(cat <<EOF
Subject: [FIM ALERT] File Changed: $target

File Integrity Monitor Alert

Attention:
The monitored file has experienced a change that does not match its recorded baseline.

Details:
-------------
File Path: $absolute_path
Recorded Baseline Hash: $baseline_hash
Current Hash: $current_hash
Timestamp: $(date)
-------------
Recommended Action: Please review the changes immediately to determine if this modification was authorized.
Unauthorized changes could indicate a security incident.

This is an automated message from your File Integrity Monitoring (FIM) system.
EOF
)
            # Send the alert email
            echo "$body" | msmtp "$email"

            # Update hash in memory (prevents repeated alerts)
            baseline_hash="$current_hash"
        fi

        # Wait 5 seconds between checks
        sleep 5
    done
}


# ────────────────────────────────────────────────────────────────
#  UPDATE FUNCTION
#  Purpose:
#     Allows manual update of a file’s baseline.
# ────────────────────────────────────────────────────────────────
updateBaselineMethod() {
    target="$2"

    if [ ! -f "$target" ]; then
        echo "[ERROR] File not found: $target"
        exit 1
    fi

    absolute_path=$(realpath "$target")
    hash_val=$(sha256sum "$absolute_path" | awk '{print $1}')

    # Replace the baseline entry with the new hash
    sed -i "/$absolute_path/c\\$hash_val $absolute_path" ~/.fim/baselines.txt
    echo "[INFO] Baseline updated for $absolute_path"
}


# ────────────────────────────────────────────────────────────────
#  STOP FUNCTION
#  Purpose:
#     Stops all running FIM monitoring processes.
# ────────────────────────────────────────────────────────────────
stopMonitorMethod() {
    pkill -f "fim --monitor"
    echo "[INFO] All monitoring processes stopped"
}


# ────────────────────────────────────────────────────────────────
#  MAIN ARGUMENT HANDLER
#  Routes the user’s command-line arguments to the proper function
# ────────────────────────────────────────────────────────────────
case "$1" in
    --baseline)
        if [ -z "$2" ]; then
            echo "[ERROR] --baseline requires a file path"
            exit 1
        fi
        baselineMethod "$2"
        ;;
    --check)
        if [ -z "$2" ]; then
            echo "[ERROR] --check requires a file path"
            exit 1
        fi
        checkBaselineMethod "$2"
        ;;
    --monitor)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "[ERROR] --monitor requires a file path and email"
            exit 1
        fi
        monitorFileMethod "$2" "$3"
        ;;
    --update)
        if [ -z "$2" ]; then
            echo "[ERROR] --update requires a file path"
            exit 1
        fi
        updateBaselineMethod "$@"
        ;;
    --stop)
        stopMonitorMethod
        ;;
    *)
        echo "[ERROR] Unknown option '$1'. Run fim without arguments for help."
        exit 1
        ;;
esac
