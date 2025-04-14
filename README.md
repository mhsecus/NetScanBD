# NetScanBD - MHSec

**Author:** Mahdi Hasan  
**Country:** Bangladesh  
**Tool Type:** Bash Script for Network Scanning & Risk Analysis  
**Version:** Stable  
**License:** MIT (or whichever you choose)  

---

🧠 Features
✅ Port Scanning (Stealth or Full)

✅ RustScan + Masscan Combo

✅ Exploit Matching via Searchsploit

✅ CVE Matching from NIST NVD

✅ Shodan Host Lookup

✅ AI Risk Evaluation (LLaMA 3)

✅ Web Application Firewall Detection

## 🚀 Overview

NetScanBD is a comprehensive network scanning and vulnerability analysis tool developed in Bash. It integrates multiple scanners and intelligence sources like **Nmap**, **RustScan**, **Masscan**, **Shodan**, **NIST NVD**, **Exploit-DB**, and **AI-powered analysis (LLaMA 3 via Ollama)**.

This script is designed to:

- Scan single or multiple IPs/domains
- Perform stealth or aggressive scans
- Lookup CVEs from NIST NVD and Shodan
- Use Exploit-DB to find public exploits
- Detect WAFs using `wafw00f`
- Analyze risk using LLaMA 3 model via Ollama

---

## 📦 Dependencies

Make sure the following tools are installed before using NetScanBD:

Tools used: `nmap`, `masscan`, `rustscan`, `searchsploit`, `wafw00f`, `ollama`, `curl`, `jq`

```bash
sudo apt install nmap masscan curl jq
sudo snap install rustscan
sudo pip install wafw00f
# install searchsploit and ollama manually
```


🔐 API Keys Required
Before running the script, make sure to set the following environment variables:

bash
Copy
Edit

```bash
export SHODAN_API_KEY="your_shodan_key_here"
export NIST_API_KEY="your_nist_key_here"
export AI_MODEL="llama3"  # Adjust to match your Ollama setup
```

🛠️ Usage
bash
Copy
Edit

```bash
chmod +x NetScanBD.sh
./NetScanBD.sh
```

Choose your scanning method:

Single IP or Domain

Multiple Targets from File

IP Range (CIDR)

Local Network Scan

Then, choose optional modules:

Stealth mode

Shodan lookup

NIST CVE search

AI Risk Analysis via Ollama

Exploit-DB lookup
