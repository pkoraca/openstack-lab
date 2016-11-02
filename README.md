# Scripts for automated Mirantis Openstack 9.0 Fuel Lab deploy.

### Prerequisites:
- Terraform on your workstation
- Packet.net account - must copy Auth Token to env.cf file

### Procedure:

Build Lab environment:
- ```git clone https://github.com/pkoraca/openstack-lab```
- ```cp env.tf.example env.tf```
- ```terraform apply openstack-lab```

When Fuel master provisions, connect to it via SSH (```ssh root@10.20.0.2``` with r00tme pwd).
Configure local mirrors for faster deployment: fuel-createmirror

### Slaves:

Slave provisioning is done separately. Slaves are described in slave-setup.yaml. You can add your sections, ie. Ceph nodes.

```
roles:
  - name: controller
    num: 3
    vcpus: 2
    ram: 4096
    disk: 120
  - name: compute
    num: 2
    vcpus: 2
    ram: 4096
    disk: 120
  - name: cinder
    num: 2
    vcpus: 1
    ram: 2048
    disk: 120
```

### Note:
- All passwords are default - make sure you change it
