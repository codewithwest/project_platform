#!/usr/bin/env bash
set -u

echo "============================================================"
echo "              DRAGONSLUR MACHINE SPEC"
echo "============================================================"

echo
echo "### IDENTITY"
echo "Hostname:     $(hostname)"
echo "FQDN:         $(hostname -f 2>/dev/null || echo 'N/A')"
echo "Date:         $(date -Is)"

echo
echo "### OS"
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION_ID)='
echo "Kernel:       $(uname -r)"
echo "Architecture: $(uname -m)"

echo
echo "### CPU"
echo "Model:        $(lscpu | awk -F: '/Model name/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"
echo "Sockets:      $(lscpu | awk -F: '/Socket.s/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"
echo "Cores/socket: $(lscpu | awk -F: '/Core.s per socket/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"
echo "Threads/core: $(lscpu | awk -F: '/Thread.s per core/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"
echo "CPU threads:  $(nproc)"
echo "CPU MHz:      $(lscpu | awk -F: '/CPU max MHz/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"

echo
echo "### MEMORY"
free -h
echo
echo "Memory modules:"
sudo dmidecode -t memory 2>/dev/null | grep -E '^[[:space:]]*(Size:|Type:|Speed:|Manufacturer:|Part Number:)' || true

echo
echo "### GPU"
if command -v lspci >/dev/null 2>&1; then
    lspci | grep -Ei 'vga|3d|display' || echo "No PCI GPU detected"
else
    echo "lspci not installed"
fi

echo
echo "### NETWORK INTERFACES"
ip -br addr

echo
echo "### NETWORK DETAILS"
for iface in $(ls /sys/class/net | grep -v '^lo$'); do
    echo "--- $iface ---"
    echo "MAC:   $(cat /sys/class/net/$iface/address 2>/dev/null)"
    echo "State: $(cat /sys/class/net/$iface/operstate 2>/dev/null)"
    if command -v ethtool >/dev/null 2>&1; then
        sudo ethtool "$iface" 2>/dev/null | grep -E 'Speed:|Duplex:|Auto-negotiation:' || true
    fi
done

echo
echo "### ROUTING"
ip route

echo
echo "### DNS"
resolvectl status 2>/dev/null | grep -E 'DNS Servers:|Current DNS Server:' || cat /etc/resolv.conf

echo
echo "### STORAGE DEVICES"
lsblk -e7 -o NAME,MODEL,SIZE,TYPE,FSTYPE,FSVER,MOUNTPOINTS

echo
echo "### DISK USAGE"
df -hT

echo
echo "### LVM"
if command -v vgs >/dev/null 2>&1; then
    sudo pvs
    echo
    sudo vgs
    echo
    sudo lvs -a -o lv_name,lv_size,vg_name,lv_attr
else
    echo "LVM tools not installed"
fi

echo
echo "### PCI DEVICES"
if command -v lspci >/dev/null 2>&1; then
    lspci | grep -Ei 'ethernet|network|storage|sata|nvme|raid|usb controller'
fi

echo
echo "### USB DEVICES"
if command -v lsusb >/dev/null 2>&1; then
    lsusb
fi

echo
echo "### SWAP"
swapon --show

echo
echo "### K3S"
if command -v k3s >/dev/null 2>&1; then
    k3s --version
    echo
    echo "K3s service:"
    systemctl is-active k3s 2>/dev/null || true
    echo
    echo "K3s nodes:"
    sudo k3s kubectl get nodes -o wide 2>/dev/null || true
else
    echo "K3s not installed"
fi

echo
echo "### KUBERNETES STORAGE"
if command -v k3s >/dev/null 2>&1; then
    sudo k3s kubectl get storageclass 2>/dev/null || true
fi

echo
echo "### LONGHORN PREREQUISITES"
echo -n "open-iscsi: "
dpkg-query -W -f='${Status}' open-iscsi 2>/dev/null | grep -q "install ok installed" && echo "installed" || echo "NOT INSTALLED"
echo -n "nfs-common: "
dpkg-query -W -f='${Status}' nfs-common 2>/dev/null | grep -q "install ok installed" && echo "installed" || echo "NOT INSTALLED"
echo -n "iscsid: "
systemctl is-active iscsid 2>/dev/null || echo "inactive/not installed"
echo -n "iscsi_tcp: "
lsmod | grep -q '^iscsi_tcp' && echo "loaded" || echo "NOT LOADED"

echo
echo "### PCI NETWORK CONTROLLERS"
lspci 2>/dev/null | grep -Ei 'ethernet|network' || true

echo
echo "### MACHINE SUMMARY"
echo "------------------------------------------------------------"
echo "Hostname: $(hostname)"
echo "CPU:      $(lscpu | awk -F: '/Model name/ {gsub(/^ +| +$/,"",$2); print $2; exit}')"
echo "Threads:  $(nproc)"
echo "RAM:      $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk(s):  $(lsblk -dn -o SIZE,TYPE | awk '$2=="disk" {print $1}' | paste -sd ', ' -)"
echo "IP(s):    $(hostname -I 2>/dev/null)"
echo "K3s:      $(command -v k3s >/dev/null 2>&1 && k3s --version | head -1 || echo 'Not installed')"
echo "------------------------------------------------------------"
echo
echo "============================================================"
echo "                 END MACHINE SPEC"
echo "============================================================"
