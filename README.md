# 🛡️ File Integrity Monitor (FIM) v1.0

**Author:** David Olutimi
**Language:** Bash
**Description:** A lightweight File Integrity Monitoring tool written in Bash that uses SHA256 hashing to detect unauthorized file modifications, deletions, or tampering. Includes email alerts for real-time monitoring.

---

## 📘 Overview

This File Integrity Monitor (FIM) creates a secure baseline of file hashes, compares them periodically, and alerts users when files have been changed or deleted. It can run in continuous monitoring mode and send alerts via **msmtp**.

---

## ⚙️ Features

* Create and update **file baselines** with SHA256 hashing
* Verify **file integrity** manually or automatically
* **Email alerting** on unauthorized changes or deletions
* Continuous file monitoring loop with **auto-refreshing** baselines
* **Lightweight, dependency-free**, Bash-based solution

---

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/DavidOlutmi/File_Integrity_Monitor_Bash.git
cd File_Integrity_Monitor_Bash

# Make the script executable
chmod +x fim.sh
```

---

## 🚀 Usage

```bash
fim.sh [--baseline | --check | --monitor | --update | --stop]
```

### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `--baseline <file>`        | Creates or updates a SHA256 hash baseline for the target file |
| `--check <file>`           | Compares the current file hash with the stored baseline       |
| `--monitor <file> <email>` | Continuously monitors a file and sends email alerts on change |
| `--update <file>`          | Manually updates the baseline hash for the file               |
| `--stop`                   | Stops all active monitoring processes                         |

---

## 🧰 Examples

### Create a baseline

```bash
fim --baseline /etc/passwd
```

### Check file integrity

```bash
fim --check /etc/passwd
```

### Start monitoring a file and receive email alerts

```bash
fim --monitor /etc/passwd you@example.com
```

### Stop all monitors

```bash
fim --stop
```

---

## 📁 Directory Structure

```
File_Integrity_Monitor_Bash/
│
├── fim                     # Main Bash script
├── README.md               # Documentation
└── ~/.fim/                 # Hidden user directory for baselines and logs
    ├── baselines.txt       # Stores SHA256 baselines
    └── fim_report.log      # Logs detected changes
```

---

## 📧 Email Configuration (msmtp)

To enable email alerts, install and configure **msmtp**:

```bash
sudo apt install msmtp
```

Create a config file at `~/.msmtprc`:

```bash
defaults
auth on
host smtp.gmail.com
port 587
user your_email@gmail.com
from your_email@gmail.com
password your_app_password
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
```

Then make it secure:

```bash
chmod 600 ~/.msmtprc
```

Test it:

```bash
echo "Test message" | msmtp you@example.com
```

---

## 🧠 How It Works

1. When you create a baseline, the script calculates the **SHA256 hash** of the file and stores it in `~/.fim/baselines.txt`.
2. When checking or monitoring, the script recomputes the hash and compares it to the stored value.
3. If there’s a difference, it logs the event and (if monitoring) sends an email alert.

---

## 🔒 Cybersecurity Concepts Demonstrated

* File Integrity Monitoring (FIM)
* Hash-based verification (SHA256)
* Incident detection and alerting
* Bash scripting and automation
* Log management

---

## 🧩 Future Enhancements

* Support for multiple file paths at once
* JSON-based baseline storage
* Integration with SIEM tools (Splunk, Wazuh)
* Real-time event detection via **inotify**


---

## 📥 Download

You can download the latest version here:
[**Download fim.sh**](https://github.com/DavidOlutimi/File_Integrity_Monitor_Bash/blob/main/fim.sh)

---

## 🌐 Author

**David Olutimi**
Cybersecurity Enthusiast | SOC Analyst Path
[LinkedIn](https://linkedin.com/in/david-olutimi-7109852aa)
[GitHub](https://github.com/DavidOlutmi)
