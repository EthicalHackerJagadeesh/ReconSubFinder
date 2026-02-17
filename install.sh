#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating system"
apt update -y

echo "[+] Installing base dependencies"
apt install -y \
  git \
  curl \
  wget \
  unzip \
  make \
  gcc \
  jq \
  parallel \
  python3 \
  python3-pip \
  build-essential \
  bind9-dnsutils

echo "[+] Installing Python tools"
pip3 install --upgrade pip
pip3 install shodan censys

# ---------------- GO SETUP ----------------
if ! command -v go >/dev/null 2>&1; then
  echo "[+] Installing Go"
  wget -q https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
  rm go1.22.1.linux-amd64.tar.gz
fi

export GOPATH=/root/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

echo "[+] Installing Go tools"

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/owasp-amass/amass/v4/...@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/chaos-client/cmd/chaos@latest
go install github.com/hakluke/haktrails@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/gwen001/github-subdomains@latest
go install github.com/gwen001/gitlab-subdomains@latest
go install github.com/glebarez/cero@latest
go install github.com/incogbyte/shosubgo@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/unfurl@latest
go install github.com/d3mondev/puredns/v2@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# ---------------- MASSDNS ----------------
echo "[+] Installing massdns"
rm -rf /tmp/massdns
git clone https://github.com/blechschmidt/massdns.git /tmp/massdns
cd /tmp/massdns
make
make install
cd ~

# ---------------- RESOLVERS ----------------
echo "[+] Downloading resolvers"
git clone https://github.com/trickest/resolvers ~/resolvers || true

# ---------------- WORDLIST ----------------
wget -q https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt \
  -O ~/best-dns-wordlist.txt

# ---------------- GAU CONFIG ----------------
wget -q https://raw.githubusercontent.com/lc/gau/master/.gau.toml \
  -O ~/.gau.toml

# ---------------- FINDOMAIN ----------------
echo "[+] Installing Findomain"
wget -q https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux.zip
unzip -o findomain-linux.zip
chmod +x findomain
mv findomain /usr/local/bin/
rm findomain-linux.zip

echo "✅ Installation completed successfully"
