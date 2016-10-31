#!/usr/bin/python

import yaml
import subprocess

def create_vm(name, ram, vcpus, disk):
	bash_command="virt-install --virt-type kvm --name %s --ram %s --vcpus %s \
       --disk path=slaves/%s.qcow2,size=%s,format=qcow2,sparse=true \
       --network network=ostlab-mgmt \
       --network network=ostlab-internal --pxe \
       --graphics vnc,listen=0.0.0.0 --noautoconsole \
       --os-type=linux --os-variant=rhel7 --check all=off" % (name, ram, vcpus, name, disk)

	subprocess.call(bash_command.split())

with open("slave-setup.yaml", 'r') as ymlfile:
	cfg = yaml.load(ymlfile)

for role in cfg['roles']:
	name = role['name']
	num = role['num']
	ram = role['ram']
	vcpus = role['vcpus']
	disk = role['disk']

	for i in range(1, num+1):
		
		vm_name = name+"-"+str(i)
		create_vm(vm_name, ram, vcpus, disk)
