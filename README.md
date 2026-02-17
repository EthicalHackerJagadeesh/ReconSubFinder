# ReconSubFinder 🔍

**ReconSubFinder** is an advanced, resolver-aware **subdomain enumeration framework** designed to work reliably in **labs, VPNs, cloud shells, and real-world environments**.

It intelligently combines **passive and active recon**, automatically adapting its behavior based on **DNS resolver availability** to avoid crashes, bans, and incomplete results.

---

## ✨ Features

- ✅ Passive subdomain enumeration
- ✅ Active DNS bruteforce (puredns)
- ✅ Resolver-aware auto tuning
- ✅ Automatic wordlist selection
- ✅ Auto rate-limiting
- ✅ Auto `--trusted-only` for low-resolver environments
- ✅ Parallel execution support
- ✅ HTTP probing for live hosts
- ✅ Clean output handling
- ✅ Lab / VPN safe
- ✅ Production-grade Bash scripting

---

## 🛠️ Tools Used

ReconSubFinder integrates the following tools:

- **subfinder**
- **amass**
- **assetfinder**
- **chaos**
- **findomain**
- **gau**
- **crt.sh**
- **puredns**
- **httpx** (optional)

---

## 📦 Requirements

Make sure the following tools are installed:

```bash
subfinder
amass
assetfinder
chaos
findomain
gau
unfurl
jq
puredns
httpx
parallel (optional)
````

Go ≥ **1.20** is recommended.

---

## 📁 Directory Structure

```
ReconSubFinder/
├── ReconSubFinder.sh
├── config.txt
├── README.md
├── resolvers/
│   └── resolvers_clean.txt
├── best-dns-wordlist.txt
├── dns-small.txt
```

---

## ⚙️ Configuration (`config.txt`)

```bash
# Tool configs
export SUBFINDER_CONFIG="$HOME/.config/subfinder/provider-config.yaml"
export AMASS_CONFIG="$HOME/.config/amass/config.ini"

# API Keys
export GITHUB_TOKEN="YOUR_TOKEN"
export CHAOS_API_KEY="YOUR_API_KEY"

# DNS
export RESOLVERS="$HOME/resolvers/resolvers_clean.txt"
export WORDLISTS="$HOME/dns-small.txt"
```

> 🔑 **Tip:** Always use absolute paths.

---

## 🚀 Installation

```bash
git clone https://github.com/yourusername/ReconSubFinder.git
cd ReconSubFinder
chmod +x ReconSubFinder.sh
```

---

## ▶️ Usage

### Basic scan

```bash
./ReconSubFinder.sh -d example.com
```

### Save output to a file

```bash
./ReconSubFinder.sh -d example.com -o results.txt
```

### Silent mode

```bash
./ReconSubFinder.sh -d example.com -s
```

### Enable HTTP probing

```bash
./ReconSubFinder.sh -d example.com -hp
```

### Parallel execution

```bash
./ReconSubFinder.sh -d example.com -p
```

### Version info

```bash
./ReconSubFinder.sh --version
```

---

## 🧠 Smart Logic (Why ReconSubFinder is Different)

ReconSubFinder automatically:

* Detects number of DNS resolvers
* Chooses the correct wordlist size
* Applies safe rate limits
* Enables `--trusted-only` when needed
* Disables puredns if DNS is blocked

This prevents:

* Resolver bans
* Tool crashes
* Wasted scan time
* False negatives

---

## 🧪 Tested Environments

* Kali Linux
* Ubuntu
* Cloud shells
* VPN / restricted networks
* CTF & lab environments

---

## 📌 Example Output

```
[i] Resolvers detected : 1
[i] Puredns enabled   : true
[i] Wordlist in use   : dns-small.txt
[i] Rate limit       : 30

[*] subfinder   : 42
[*] amass       : 18
[*] findomain   : 12
[*] puredns     : 5

[+] Final subdomains: 56
```

---

## ⚠️ Legal Disclaimer

This tool is intended **only for educational purposes and authorized security testing**.

You are responsible for ensuring you have **permission** to test any target.

---

## 👤 Author

**EthicalHackerJagadeesh**

---

## ⭐ Support

If you find ReconSubFinder useful:

* ⭐ Star the repository
* 🐛 Report issues
* 🚀 Suggest features

Happy recon! 🔥


