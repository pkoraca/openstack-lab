# Configure the Packet Provider
provider "packet" {
  auth_token = "1H2wpGbGzmSWANqKhFMqPGQhKKaopR9v"
}

# Create a device and add it to tf_project_1
resource "packet_device" "fueldev" {
  plan             = "baremetal_1"
  facility         = "ewr1"
  hostname         = "testsrv"
  operating_system = "ubuntu_16_04_image"
  billing_cycle    = "hourly"
  project_id       = "fda8fb57-6c7f-4296-ae8d-87a3d0ac41f8"

  connection {
    type        = "ssh"
    user        = "root"
    port        = 22
    timeout     = "1200"
    private_key = "${file("id_rsa_packet_net")}"
  }

  provisioner "file" {
    source      = "./openstack-lab"
    destination = "/opt"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/openstack-lab; bash lab-setup.sh"
    ]
  }
}

