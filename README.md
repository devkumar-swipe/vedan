# Vedan - Bug Bounty Toolkit 🛠️

Vedan is a powerful and automated Bug Bounty Toolkit designed to simplify subdomain enumeration, HTTP probing, and XSS vulnerability scanning. It is built with simplicity and efficiency in mind, making it a great tool for bug bounty hunters, security researchers, and developers.

---

## Features ✨
- **Subdomain Enumeration**: Uses `subfinder` and `amass` to discover subdomains.
- **HTTP Probing**: Uses `httprobe` to find live HTTP/HTTPS servers.
- **XSS Scanning**: Uses `waybackurls` and `kxss` to identify potential XSS vulnerabilities.
- **Automated Workflow**: Combines multiple tools into a single, easy-to-use script.
- **Output Organization**: Saves all results in a dedicated `~/vedan/` directory.

---

## Installation 🛠️

### Prerequisites
Before using Vedan, ensure you have the following installed:
- **Go** (to install Go-based tools)
- **Git** (to clone the repository)

### Step 1: Clone the Repository
```bash
git clone https://github.com/devkumar-swipe/vedan.git
cd vedan
