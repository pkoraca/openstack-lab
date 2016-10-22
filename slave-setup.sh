#!/bin/bash

CONTROLLER_NO=3
CONTROLLER_RAM=2048
CONTROLLER_CPU=2
CONTROLLER_DISK=120

COMPUTE_NO=2
COMPUTE_RAM=4096
COMPUTE_CPU=2
COMPUTE_DISK=120

CINDER_NO=3
CINDER_RAM=2048
CINDER_CPU=1
CINDER_DISK=120

create_disk(){
	qemu-img create -f qcow2 slaves/${NAME}-$i.qcow2 ${DISK}G
}

create_vm(){
virt-install --virt-type kvm --name ${NAME}-$i --ram $RAM --vcpus $CPU \
       --disk path=slaves/${NAME}-${i}.qcow2,size=$DISK,format=qcow2,sparse=true \
       --network network=ostlab-mgmt \
       --network network=ostlab-internal --pxe \
       --graphics vnc,listen=0.0.0.0 --noautoconsole \
       --os-type=linux --os-variant=rhel7 --check all=off
}

#################
# CONTROLLER
#################

NO=$CONTROLLER_NO
RAM=$CONTROLLER_RAM
CPU=$CONTROLLER_CPU
DISK=$CONTROLLER_DISK
NAME="slave-controller"

for i in $(seq 1 $NO); do

	create_disk
	create_vm

done


#################
# COMPUTE
#################

NO=$COMPUTE_NO
RAM=$COMPUTE_RAM
CPU=$COMPUTE_CPU
DISK=$COMPUTE_DISK
NAME="slave-compute"

for i in $(seq 1 $NO); do

        create_disk
        create_vm

done


#################
# CINDER
#################

NO=$CINDER_NO
RAM=$CINDER_RAM
CPU=$CINDER_CPU
DISK=$CINDER_DISK
NAME="slave-cinder"

for i in $(seq 1 $NO); do

        create_disk
        create_vm

done
