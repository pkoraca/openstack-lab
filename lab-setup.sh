#!/bin/bash

MOS="http://9f2b43d3ab92f886c3f0-e8d43ffad23ec549234584e5c62a6e24.r60.cf1.rackcdn.com/MirantisOpenStack-9.0.iso"

download_mos_image(){

    if [ ! -f MirantisOpenStack-9.0.iso ]; then

        echo "Downloading MOS image"
        wget -q $MOS -o /dev/null
        echo "Downloaded MOS image"
    fi

}

install_packages(){
    export DEBIAN_FRONTEND="noninteractive"
    apt-get update && apt-get upgrade -y
    apt install qemu-kvm libvirt-bin virtinst qemu-utils -y
}

set_up_kvm(){
    systemctl start libvirtd
    systemctl enable libvirtd
    systemctl start virtlogd.socket
    systemctl enable virtlogd.socket

cat <<EOF >ostlab-mgmt.xml
<network>
  <name>ostlab-mgmt</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <domain name='ostlab-mgmt'/>
  <ip address='10.20.0.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat <<EOF >ostlab-internal.xml
<network>
  <name>ostlab-internal</name>
  <forward mode='nat'/>
  <bridge name='virbr2' stp='on' delay='0'/>
  <domain name='ostlab-internal'/>
  <ip address='10.20.203.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

    virsh net-destroy default
    virsh net-undefine default
    virsh net-create ostlab-mgmt.xml
    virsh net-create ostlab-internal.xml
}


configure_iptables(){

    # Expose Fuel
    MYIP=$(curl -s checkip.amazonaws.com)
    iptables -I FORWARD -m state -d 10.20.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
    iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport 8443 -j DNAT --to-destination 10.20.0.2:8443
    iptables -t nat -A POSTROUTING -j MASQUERADE -s  10.20.0.0/24 ! -d 10.20.0.0/24

    # Expose Controller
    iptables -I FORWARD -m state -d 172.16.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
    for i in 80 443 5000 6080 8000 8004 8080 8082 8386 8773 8774 8776 8777 9292 9696; do 
      iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport $i -j DNAT --to-destination 172.16.0.3:$i; 
    done
    iptables -t nat -A POSTROUTING -j MASQUERADE -s  172.16.0.0/24 ! -d 172.16.0.0/24

}

set_up_master(){

    virt-install --connect qemu:///system --virt-type kvm --name fuel-master --ram 2048 \
    --disk path=fuel-master.qcow2,size=60 --graphics vnc --network network=ostlab-mgmt \
    --cdrom ./MirantisOpenStack-9.0.iso &2> /dev/null

    sleep 10

    # insert keystrokes on boot to append showmenu=no
    virsh send-key fuel-master KEY_TAB KEY_SPACE KEY_S KEY_H KEY_O KEY_W KEY_M KEY_E KEY_N KEY_U KEY_EQUAL KEY_N KEY_O KEY_ENTER

}

set_up_env(){

    download_mos_image
    install_packages
    set_up_kvm
    configure_iptables
    set_up_master

}

while true; do
    echo "This script will set up Openstack Fuel environment"
    read -p "Do you wish to reconfigure?" yn
    case $yn in
        [Yy]* ) set_up_env ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
