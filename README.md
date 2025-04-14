# NetScanBD
AI-Powered Network Vulnerability Scanner

🧠 Script Overview
NetScanBD - MHSec
Author: Mahdi Hasan 🇧🇩
Language: Bash
Purpose: A multifunctional, AI-assisted network scanning tool for reconnaissance, vulnerability identification, exploit lookup, and threat analysis.

🔧 Dependencies & Why They're Needed
Tool	Purpose
nmap	Primary port scanner; used for service/version detection and vulnerability script scans.
masscan	Ultra-fast port scanner for large IP ranges and aggressive scans.
rustscan	Lightweight scanner to quickly find open ports before a deeper Nmap scan.
searchsploit	Searches Exploit-DB for known vulnerabilities based on service/version info.
wafw00f	Detects presence of Web Application Firewalls on the target.
ollama	Runs the local LLaMA 3 AI model for intelligent risk analysis.
curl	Fetches data from APIs (Shodan and NIST).
jq	Parses and formats JSON output from APIs.
💡 Make sure all tools are installed on your system. For ollama, a local LLaMA model like llama3 must be set up and available.

🔐 API Keys Required
API	Usage
  🔐 SHODAN_API_KEY	Fetches external intelligence and open ports seen by Shodan.  
  🔐NIST_API_KEY	Looks up CVEs related to detected services via the National Vulnerability Database (NVD).


🚀 What This Script Does (Step-by-Step)
Dependency Check
Ensures all required tools are installed. If not, the script exits early with an error.

Signal Handling
Overrides Ctrl+C behavior to gracefully inform the user instead of force quitting.



Initial Setup

User selects input type:

Single IP/domain

List of IPs/domains from .txt file

IP range in CIDR

Local network discovery

Options to enable/disable:

Stealth scan

Shodan lookup

NIST CVE lookup

AI analysis

Exploit-DB search

Scanning & Analysis Loop (Per Target)

Performs a stealth scan (Nmap with -Pn -sS) or fast aggressive scan (RustScan + Masscan + Nmap).

Checks for known exploits using searchsploit.

If enabled:

Shodan Intelligence: Gathers external data about the IP from Shodan.

NIST CVEs: Queries NVD for known CVEs related to services found.

AI Risk Analysis: Sends a prompt to Ollama for contextual analysis.

Runs WAF detection using wafw00f.

Final Output
Shows that all scans have been completed.



✅ Why Use NetScanBD - MHSec?
Feature	Benefit
🔄 All-in-One	Combines multiple powerful tools in one streamlined interface.
⚡ Fast & Scalable	Supports fast scans, batch processing, and large IP ranges.
🧠 AI Integration	Analyzes vulnerabilities and provides human-like risk assessment using LLaMA 3.
🌐 Intelligence Feed	Shodan and NIST integration bring real-world, up-to-date intelligence.
🔐 Exploit Discovery	Correlates open services with known public exploits.
🛡️ WAF Check	Alerts you to the presence of firewalls that may block intrusion attempts.
📄 Easy Input	Accepts IPs, domains, ranges, and .txt files with targets.
🧩 Modular Design	You can easily add/remove modules like brute force, web scan, etc.
⚙️ Usage Example
bash
Copy
Edit
chmod +x netscanbd.sh
./netscanbd.sh
Choose input: 1 for IP, 2 for file, etc.

Select scan options: stealth, AI, NIST, Shodan, etc.
