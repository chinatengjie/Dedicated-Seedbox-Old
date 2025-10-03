#!/bin/bash
apt install sudo wget -y
## BBR
function Tweaked_BBR {
    # 定义颜色输出函数（如果不存在）
    if ! declare -f normal_1 > /dev/null; then
        normal_1() { echo -e "\033[1;32m$1\033[0m"; }
    fi
    if ! declare -f normal_2 > /dev/null; then
        normal_2() { echo -e "\033[1;34m$1\033[0m"; }
    fi
    
    ## Update Kernel
    normal_1 "Updating Kernel"
    distro_codename="$(source /etc/os-release && printf "%s" "${VERSION_CODENAME}")"
    
    if [[ $distro_codename = buster ]]; then
        echo "deb http://archive.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list
        apt-get -qqy update && apt -qqyt buster-backports upgrade
    elif [[ $distro_codename = bullseye ]]; then
        echo "deb http://archive.debian.org/debian bullseye-backports main" | sudo tee -a /etc/apt/sources.list
        apt-get -qqy update && apt -qqyt bullseye-backports upgrade
    else
        echo "Unsupported Debian version: $distro_codename"
        return 1
    fi
    
    # 下载 BBR 脚本
    wget -O /root/BBR.sh https://raw.githubusercontent.com/chinatengjie/chinatengjie-Seedbox-Components-Old/main/Miscellaneous/BBR/BBR.sh 
    if [[ $? -ne 0 ]]; then
        echo "Failed to download BBR script"
        return 1
    fi
    chmod +x /root/BBR.sh
    
    ## Install tweaked BBR automatically on reboot
    cat << EOF > /etc/systemd/system/bbrinstall.service
[Unit]
Description=BBRinstall
After=network.target

[Service]
Type=oneshot
ExecStart=/root/BBR.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable bbrinstall.service && bbrx=1
    
    normal_1 "BBR installation scheduled for next reboot"
    echo "System will install BBR on next boot. lsmod | grep bbr"

}

# 调用函数
Tweaked_BBR
