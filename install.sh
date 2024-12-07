#!/bin/bash

# Black Geck0 Installation Script for Kali Linux on Raspberry Pi
# Installs essential tools, configures the system, and optimizes for pen-testing operations

# Function to check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[-] This script must be run as root. Use sudo." >&2
        exit 1
    fi
}

# Function to update and upgrade the system
update_system() {
    echo "[+] Updating and upgrading the system..."
    apt update && apt full-upgrade -y
    apt autoremove -y
}

# Function to configure system resources
configure_resources() {
    echo "[+] Configuring system resources..."
    # Add a swap file for Raspberry Pi
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
}

# Function to install essential tools
install_tools() {
    echo "[+] Installing essential tools and dependencies..."
    apt install -y git scp espeak tilix sublime-text vlc gimp tlp dirbuster \
        tor proxychains openvpn openssh-server netcat-openbsd hydra \
        beef-xss maltego kismet nmap sqlmap amass subfinder exploitdb \
        searchsploit john aircrack-ng wfuzz nikto gobuster python3-pip \
        build-essential gcc make curl libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev libffi-dev libncurses5-dev libgdbm-dev \
        liblzma-dev tk-dev impacket mitmproxy

    echo "[+] Installing SecLists..."
    git clone https://github.com/danielmiessler/SecLists.git /usr/share/seclists

    echo "[+] Installing Python tools..."
    pip3 install requests beautifulsoup4 scapy flask
}

# Function to configure Raspberry Pi settings
configure_rpi() {
    echo "[+] Configuring Raspberry Pi-specific settings..."
    # Enable SSH on boot
    systemctl enable ssh

    # Optimize GPU memory (optional)
    sed -i 's/^#gpu_mem=16/gpu_mem=32/' /boot/config.txt

    # Enable interfaces (optional)
    raspi-config nonint do_i2c 0
    raspi-config nonint do_spi 0
}

# Function to configure tools and settings
configure_system() {
    echo "[+] Configuring system settings..."

    # Set keyboard layout to British English
    echo "[+] Setting keyboard layout to British English..."
    loadkeys uk
    sed -i 's/XKBLAYOUT="us"/XKBLAYOUT="gb"/' /etc/default/keyboard

    # Enable and configure UFW firewall
    echo "[+] Enabling and configuring UFW firewall..."
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw enable

    # Configure ProxyChains
    echo "[+] Configuring ProxyChains..."
    sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains.conf
    sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains.conf
    sed -i 's/^#socks4/socks4/' /etc/proxychains.conf
}

# Function to create a standard user
create_standard_user() {
    echo "[+] Creating standard user 'Ketama'..."
    useradd -m -s /bin/bash Ketama
    passwd Ketama
    usermod -aG sudo Ketama
}

# Function to check Python version
check_python_version() {
    echo "[+] Checking Python version..."
    python3 --version || apt install -y python3
}

# Function to configure Metasploit
configure_metasploit() {
    echo "[+] Configuring Metasploit..."
    msfdb init
}

# Function to prompt for changing root password
change_root_password() {
    echo "[+] Changing the root password (manual input required)..."
    passwd root
}

# Function to add custom ASCII art for boot
add_hacker_logo() {
    echo "[+] Adding custom hacker logo for boot..."
    cat <<'EOF' > /etc/motd
.______    __          ___       ______  __  ___      _______  _______   ______  __  ___   ___   
|   _  \  |  |        /   \     /      ||  |/  /     /  _____||   ____| /      ||  |/  /  / _ \  
|  |_)  | |  |       /  ^  \   |  ,----'|  '  /     |  |  __  |  |__   |  ,----'|  '  /  | | | | 
|   _  <  |  |      /  /_\  \  |  |     |    <      |  | |_ | |   __|  |  |     |    <   | | | | 
|  |_)  | |  `----./  _____  \ |  `----.|  .  \     |  |__| | |  |____ |  `----.|  .  \  | |_| | 
|______/  |_______/__/     \__\ \______||__|\__\     \______| |_______| \______||__|\__\  \___/  
EOF
}

# Function to notify completion
notify_completion() {
    espeak "Black Geck0 setup is complete. Happy hacking!" || echo "[+] Setup complete!"
}

# Main function
main() {
    check_root
    update_system
    configure_resources
    install_tools
    configure_rpi
    configure_system
    create_standard_user
    check_python_version
    configure_metasploit
    add_hacker_logo

    echo "[+] Installation complete. Finalizing setup..."
    change_root_password
    notify_completion
}

# Execute the main function
main

