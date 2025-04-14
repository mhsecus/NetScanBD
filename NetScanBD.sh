#!/bin/bash

# NetScanBD - MHSec
# By Mahdi Hasan

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# API Keys (set these before using!)
SHODAN_API_KEY=""
NIST_API_KEY=""
AI_MODEL="llama3"  # Ollama model name (adjust to your setup)

# ----------------- Check Dependencies ------------------
check_dependencies() {
    echo -e "${BLUE}[+] Checking required tools...${NC}"
    local tools=("nmap" "masscan" "rustscan" "searchsploit" "wafw00f" "ollama" "curl" "jq")
    for tool in "${tools[@]}"; do
        if ! command -v $tool &>/dev/null; then
            echo -e "${RED}[-] $tool is not installed. Please install it before running the script.${NC}"
            exit 1
        fi
    done
}

# ----------------- Trap SIGINT (Ctrl+C) ----------------
trap "echo -e '\n[!] Ctrl+C Pressed! Exiting...'; exit 1" SIGINT

# ----------------- Initial Setup -----------------------
initial_setup() {
    clear
    echo -e "${GREEN}
=============================================
     N E T S C A N B D   -   M H S E C
=============================================
        Created by Mahdi Hasan
        Country : Bangladesh
=============================================${NC}"

    echo -e "${YELLOW}[?] Select input type:${NC}
1) Single IP or Domain
2) Multiple IPs/Subdomains from File
3) IP Range
4) Local Network"
    read -p "Choice: " input_choice

    read -p "Use stealth scan? (y/n): " stealth_choice
    [[ "$stealth_choice" =~ ^[Yy]$ ]] && STEALTH=true || STEALTH=false

    read -p "Enable Shodan lookup? (y/n): " shodan_choice
    [[ "$shodan_choice" =~ ^[Yy]$ ]] && USE_SHODAN=true || USE_SHODAN=false

    read -p "Enable NIST CVE lookup? (y/n): " nist_choice
    [[ "$nist_choice" =~ ^[Yy]$ ]] && USE_NIST=true || USE_NIST=false

    read -p "Enable AI Risk Analysis (LLaMA)? (y/n): " ai_choice
    [[ "$ai_choice" =~ ^[Yy]$ ]] && USE_AI=true || USE_AI=false

    read -p "Enable Exploit-DB lookup? (y/n): " exploit_choice
    [[ "$exploit_choice" =~ ^[Yy]$ ]] && USE_EXPLOIT=true || USE_EXPLOIT=false

    # Ask about Masscan at the beginning
    read -p "Run Masscan on targets? (y/n): " masscan_choice
    [[ "$masscan_choice" =~ ^[Yy]$ ]] && RUN_MASSCAN=true || RUN_MASSCAN=false

    case $input_choice in
        1) read -p "Enter IP or domain: " TARGETS ;;
        2) 
            echo -e "${BLUE}[+] Available .txt files in current directory:${NC}"
            ls *.txt
            read -p "Enter filename (e.g. targets.txt): " file
            [ ! -f "$file" ] && echo -e "${RED}[-] File not found.${NC}" && exit 1
            TARGETS=$(cat "$file")
            ;;
        3) 
            read -p "Enter IP range (CIDR, e.g. 192.168.1.0/24): " range
            TARGETS=$(nmap -n -sL "$range" | awk '/Nmap scan report/{print $NF}')
            ;;
        4) 
            local_ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
            local_net=$(echo "$local_ip" | awk -F. '{print $1"."$2"."$3".0/24"}')
            TARGETS=$(nmap -n -sn "$local_net" | awk '/Nmap scan report/{print $NF}')
            ;;
        *) echo -e "${RED}Invalid option.${NC}" && exit 1 ;;
    esac
}

# ----------------- Scan Target -------------------------
scan_target() {
    ip="$1"
    echo -e "\n${YELLOW}========== SCANNING: $ip ==========${NC}"

    if $STEALTH; then
        echo -e "${GREEN}[+] Stealth scan on $ip${NC}"
        nmap -sS --script vuln -Pn "$ip"
    else
        echo -e "${GREEN}[+] Running Nmap for service detection on $ip${NC}"
        nmap -sS --script vuln -Pn "$ip"
    fi

    # Run Rustscan as an alternative to Nmap (only if needed)
    if ! $RUN_MASSCAN; then
        echo -e "${GREEN}[+] Running Rustscan for service discovery on $ip${NC}"
        rustscan -a "$ip" --ulimit 5000 -- -sV
    fi

    # Run Masscan for quick port scanning (if enabled)
    if $RUN_MASSCAN; then
        echo -e "${BLUE}[+] Running Masscan on $ip...${NC}"
        sudo masscan "$ip" -p1-65535 --rate=1000
    else
        echo -e "${YELLOW}[-] Skipping Masscan for $ip.${NC}"
    fi

    # Exploit-DB Lookup
    if $USE_EXPLOIT; then
        echo -e "${BLUE}[+] Exploit-DB Lookup...${NC}"
        nmap -sV "$ip" -oG - | awk '/Ports/ {print $0}' | while read -r line; do
            service=$(echo "$line" | awk -F'[()]' '{print $2}')
            [ -n "$service" ] && searchsploit "$service"
        done
    fi

    # Shodan Lookup
    if $USE_SHODAN; then
        echo -e "${BLUE}[+] Shodan lookup for $ip...${NC}"
        curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY" | jq
    fi

    # NIST CVE Lookup
    if $USE_NIST; then
        echo -e "${BLUE}[+] NIST CVE lookup...${NC}"
        nmap -sV "$ip" -oG - | awk '/Ports/ {print $0}' | while read -r line; do
            service=$(echo "$line" | awk -F'[()]' '{print $2}')
            if [ -n "$service" ]; then
                echo -e "${BLUE}[+] Searching NVD for: $service${NC}"
                query=$(echo "$service" | sed 's/ /%20/g')
                curl -s "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$query&apiKey=$NIST_API_KEY" | \
                jq '.vulnerabilities[] | {id: .cve.id, severity: .cve.metrics.cvssMetricV31[0].cvssData.baseSeverity, score: .cve.metrics.cvssMetricV31[0].cvssData.baseScore, description: .cve.descriptions[0].value}' 2>/dev/null
            fi
        done
    fi

    # WAF Detection
    echo -e "${BLUE}[+] WAF Detection...${NC}"
    wafw00f "$ip"

    # AI Risk Analysis
    if $USE_AI; then
        echo -e "${BLUE}[+] AI Risk Analysis via Ollama...${NC}"
        echo "Analyze potential network vulnerabilities and security risks for target $ip based on scan data." | ollama run "$AI_MODEL"
    fi

    echo -e "${YELLOW}========== END OF $ip ==========${NC}"
}

# ----------------- Batch Run ---------------------------
batch_run_all() {
    echo -e "${GREEN}[+] Starting scans...${NC}"
    for ip in $TARGETS; do
        ip=$(echo "$ip" | xargs)
        [ -z "$ip" ] && continue
        scan_target "$ip"
    done
    echo -e "${GREEN}[✓] All scans completed.${NC}"
}

# ----------------- RUN SCRIPT --------------------------
check_dependencies
initial_setup
batch_run_all
