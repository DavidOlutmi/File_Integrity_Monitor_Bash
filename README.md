# 🛡️ File Integrity Monitor (FIM)

**Author:** David Olutimi  
**Language:** Bash  
**Description:**  
A simple, dependency-free File Integrity Monitoring tool written in Bash. FIM uses SHA256 hashing to detect unauthorized changes to files and can alert you by email.

---

## 🚩 Quick Start: Install as a Command-Line Binary

You can install `fim.sh` to use it just like standard Unix commands (e.g., `ls`, `cat`, etc.), from anywhere in your shell:

```bash
# Clone the repository
git clone https://github.com/DavidOlutmi/File_Integrity_Monitor_Bash.git
cd File_Integrity_Monitor_Bash

# Make the script executable
chmod +x fim.sh

# Move it to a directory in your PATH, e.g. /usr/local/bin
sudo mv fim.sh /usr/local/bin/fim
```

Now, you can run `fim` from anywhere in your terminal as a regular command.

---

## 📝 Usage

```bash
fim [--baseline | --check | --monitor | --update | --stop] [arguments...]
```

### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `--baseline <file>`        | Create or update SHA256 hash baseline for the target file     |
| `--check <file>`           | Verify file integrity against stored baseline                 |
| `--monitor <file> <email>` | Continuously monitor a file and send email alerts on change   |
| `--update <file>`          | Manually update the baseline hash for a file                  |
| `--stop`                   | Stop all active monitoring processes                          |

### Examples

```bash
fim --baseline /etc/passwd
fim --check /etc/passwd
fim --monitor /etc/passwd you@example.com
fim --update /etc/passwd
fim --stop
```

---

## 📁 How It Works

- **Create Baseline:** Stores SHA256 hash of specified files in `~/.fim/baselines.txt`
- **Integrity Check:** Compares new SHA256 hash with stored baseline
- **Monitoring:** Logs changes and can send email alerts (requires msmtp configuration)
- **Logging:** Changes are logged to `~/.fim/fim_report.log`

---

## 📦 Directory Structure

```
File_Integrity_Monitor_Bash/
├── fim              # Main Bash script (becomes 'fim' binary when installed)
├── README.md        # Documentation
└── ~/.fim/          # Hidden user directory for baselines and logs
    ├── baselines.txt
    └── fim_report.log
```

---

## 📧 Email Alerts (Optional)

To enable email notifications, install and configure `msmtp`:

```bash
sudo apt install msmtp
```

Place your configuration in `~/.msmtprc`:

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

Make it secure:

```bash
chmod 600 ~/.msmtprc
echo "Test message" | msmtp you@example.com
```

---

## 🔒 Cybersecurity Concepts Demonstrated

- File Integrity Monitoring
- Hash Verification (SHA256)
- Alerting and Logging
- Bash Scripting Automation

---

## 📥 Download

Grab the latest script from GitHub:  
[**Download fim.sh**](https://github.com/DavidOlutmi/File_Integrity_Monitor_Bash/blob/main/fim.sh)

Or install globally for command-line use!

---

## 🧩 Future Enhancements

- Multiple file monitoring
- JSON baseline option
- SIEM integration (Splunk, Wazuh)
- Real-time detection via `inotify`

---

## 🌐 Author

**David Olutimi**  
Cybersecurity Enthusiast | Security Analyst Path  
[LinkedIn](https://linkedin.com/in/david-olutimi-7109852aa)  
[GitHub](https://github.com/DavidOlutmi)
