# general config
libvirt-uri = "qemu:///system"
ssh-public-key-file = "/home/someuser/.ssh/key.pub"

# vm basic config
vm-name = "exmaple"
vm-domain = "somedomain.tld"
vm-memory = 2048
vm-vcpu = 2

# vm disks
vm-size = 32212254720
pool = "default"

# base disk
base-img = "debian-11-generic-amd64.qcow2"

# vm networking
# if unset only default will be used
vm-network-interfaces = ["default"]
