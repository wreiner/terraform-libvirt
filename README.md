# terraform and libvirt

Using this resources it is possible to create VMs using libvirt and terraform.

Mainly cloud images are used but every image with cloud-init should be possible to use.
The VMs can be created on the host where terraform is run or via SSH on remote hosts.

When run a cloud-init disk will be created and attached to the VM through virtual CD-ROM.

## Usage

- please see following sections to configure
- set the libvirt uri if needed
- set parameters in terraform.tfvars
- run terraform to deploy VM

  ```
  terraform init
  terraform plan
  terrafrom apply
  ```

- run terraform do delete VM

  - !!ALL DISKS WILL BE REMOVED!!

  ```
  terraform destroy
  ```

### Prerequisites when using ssh

- ssh user part of libvirtd group
- ssh user able to login with key

### Connection strings

- use local system

  ```
  libvirt-uri = "qemu:///system"
  ```

- use remote system with ssh

  ```
  libvirt-uri = "qemu+ssh://<user-allowd-to-use-libvirt>@<host-or-ip-of-libvirtd-server>/system?no_verify=1"
  ```

### Cloud-init

- set the hostname
- set the timezone
- update packages
- install sudo and vim
- disable root login
- disable ssh pw auth
- create user ansible and grant sudo privileges without password
- ansible user will get uid/gid 3000
- deploy ssh key for ansible user
- extend / filesystem
- log IPv4/IPv6 addresses in /etc/issue
