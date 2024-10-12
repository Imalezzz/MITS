#!/bin/bash

echo """███╗   ███╗ ██████╗ ██╗   ██╗██╗███╗   ██╗ ██████╗     ██╗███╗   ██╗    ████████╗██╗  ██╗███████╗    ███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
████╗ ████║██╔═══██╗██║   ██║██║████╗  ██║██╔════╝     ██║████╗  ██║    ╚══██╔══╝██║  ██║██╔════╝    ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
██╔████╔██║██║   ██║██║   ██║██║██╔██╗ ██║██║  ███╗    ██║██╔██╗ ██║       ██║   ███████║█████╗      ███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
██║╚██╔╝██║██║   ██║╚██╗ ██╔╝██║██║╚██╗██║██║   ██║    ██║██║╚██╗██║       ██║   ██╔══██║██╔══╝      ╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
██║ ╚═╝ ██║╚██████╔╝ ╚████╔╝ ██║██║ ╚████║╚██████╔╝    ██║██║ ╚████║       ██║   ██║  ██║███████╗    ███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝╚═╝  ╚═══╝       ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝ 
                                                                                                                                                        """

random_windows_hostname() {
    printf "DESKTOP-$(tr -dc A-Z0-9 </dev/urandom | head -c 7)"
}

hidding_you() {
    # Check if the script is being run as root
    if [[ $(id -u) -ne 0 ]]; then
        echo "Please run this script as root."
        exit 1
    fi

    echo -n """Choose an option 
    1. Change the hostname
    2. Disable system name transfer via DHCP
    3. Change system TTL
    4. Disable NTP
    5. Disable ICMP Redirect   
    6. Change Hardware Options on your Kali machine (don't do it on main!)
    """ 
    read -r CHOICE
    case $CHOICE in
        1)
            echo -n "Changing hostname... "
            NEW_HOSTNAME=$(random_windows_hostname)
            hostnamectl set-hostname "$NEW_HOSTNAME" 2>/dev/null
            echo "Hostname changed! Now it's  $(cat /etc/hostname)"
            sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
            hidding_you
            ;;
        2)
            echo -n "Disabling system name transfer via DHCP... "
            sed -i '/\[ipv4\]/a dhcp-send-hostname=false' /etc/NetworkManager/system-connections/Wired\ connection\ 1
            echo "Success!"
            hidding_you
            ;;
        3)
            read -p "Enter a value for preferred TTL: " ttl
            echo "Changing TTL to $ttl"
            sysctl -w net.ipv4.ip_default_ttl="$ttl"
            echo "Success!"
            hidding_you
            ;;
        4)
            echo -n "Disabling NTP... "
            systemctl stop systemd-timesync
            echo "Success!"
            hidding_you
            ;;
        5)
            echo -n "Disabling ICMP redirect... "
            sysctl -w net.ipv4.conf.all.accept_redirects=0
            sysctl -w net.ipv6.conf.all.accept_redirects=0
            echo "Success!"
            hidding_you
            ;;
        6)
            hiding_hardware
            ;;
        *)
            echo "Invalid option. Please try again."
            hidding_you
            ;;
    esac
}

hiding_hardware() {
    # Create a backup of the original /proc/cpuinfo file
    cp /proc/cpuinfo /root/cpuinfo.backup

    # Create a new /etc/cpuinfo file with modified contents
    cat > /root/cpuinfo <<EOL
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 63
model name      : Intel(R) Xeon(R) CPU @ 2.30GHz
stepping        : 0
microcode       : 0x1
cpu MHz         : 2300.000
cache size      : 6144 KB
physical id     : 0
siblings        : 1
core id         : 0
cpu cores       : 1
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm fsgsbase bmi1 avx2 smep bmi2 erms invpcid xsaveopt
bugs            : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit
bogomips        : 4600.00
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:
EOL

    # Mount the new /etc/cpuinfo file to the original /proc/cpuinfo file
    mount --bind /root/cpuinfo /proc/cpuinfo

    # Make the changes persistent by adding the mount command to /etc/fstab
    echo "/root/cpuinfo /proc/cpuinfo none bind" >> /etc/fstab

    echo "#####################################################"

    while true; do
        read -p "Reboot system now? (y/n): " choice
        case $choice in
            y)
                reboot
                break;;
            n)
                echo "Goodbye"
                break;;
            *)
                echo "Please enter 'y' or 'n'."
                ;;
        esac  
    done
}

hidding_you
