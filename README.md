# SP Automation Stack for Ansible
The SP Automation Stack, based on earlier work on a set of Bash scripts called `lotus-automation`, is a set of Ansible playbooks and tools that deploys and manages a complete Filecoin Storage Provider installation, including wallet management and bootstrapping.

It is intended to be able to be run against the same SP over and over again, bringing the SP into alignment with where it should be.

At the moment the SP Automation Stack is targeting new and small-sized SPs, as well as larger SPs who wish to experiment - over time, a Porting Guide will be published and improved which allows existing SPs to begin using the Stack and manage their existing deployments.

## Requirements
- Ansible (2.12 or newer)
- Python3 (3.9 or newer)
- Passwordless sudo enabled on your Lotus node (alternatively, add the flags --become and --ask-become-pass when running ansible-playbook)
- If you are using Secure Boot on your Lotus node, please read [the note on Secure Boot](#note-on-secure-boot).

## Upgrading
Once we have begun publishing releases for SP Automation, please read the release notes *every time you upgrade!* 

We may release breaking changes over time you need to be aware of, and your group_vars/ files in particular may need changes over time to keep up with the playbook.

## Usage
- Clone this repository and `cd` into it
```
git clone https://github.com/filecoin-project/sp-automation.git && cd sp-automation
```
- Run the setup script to symlink Ansible Galaxy roles into place. This will not be needed once we make the roles available via Galaxy.
```
./setup_ansible_roles.sh
```
- Copy `inventory.example` to `inventory` and edit it to suit your needs.
```
cp inventory.example inventory && editor inventory
```
- Copy the global configuration - `ansible/group_vars/all.example` to `ansible/group_vars/all` and edit it to suit your needs.
```
cp group_vars/all.example group_vars/all && editor group_vars/all
```
- Copy the YugabyteDB configuration - `group_vars/yugabytedb.example` to `group_vars/yugabytedb` and edit it to suit your needs.
```
cp group_vars/yugabytedb.example group_vars/yugabytedb && editor group_vars/yugabytedb
```
- Copy the Boost configuration - `group_vars/boost.example` to `group_vars/boost` and edit it to suit your needs.
```
cp group_vars/boost.example group_vars/boost && editor group_vars/boost
```
- If this is your first time running lotus-automation for Ansible on this machine, run the Ansible Galaxy install process.
```
ansible-galaxy install -r roles/requirements.yml ; ansible-galaxy install -r collections/requirements.yml
```
- Now run the playbook and deploy your Storage Provider. (Note: If any of your nodes do not have **passwordless sudo** enabled, add --ask-become-pass to the command below)
```
ansible-playbook deploy.yml
```
- The playbook will automatically deploy everything, and ask you questions if it needs any more information from you. If you run into any issues, please let us know by opening an issue on this repository.

## Things to note
There are some important things you should know while using this playbook.

### NVIDIA support and Secure Boot
Set `install_nvidia_driver: true` in `group_vars/all` if you want to have the playbook handle installing the NVIDIA drivers for you.

It will also handle figuring out your GPU's details and ask the compiler to take that into account while building Lotus.

If you are using Ubuntu with Secure Boot enabled (likely if you are on a modern UEFI machine), due to a bug in the NVIDIA driver packages (or possibly their Ansible role), you may find yourself unable to use the NVIDIA driver after installation. 

If you run into this, please run `sudo dpkg-reconfigure nvidia-dkms-525-server` (replacing 525 with your driver version - for example, 515 on Ubuntu 20.04) and follow the steps, then reboot and select "Enroll MOK", then reboot one last time, then re-run the playbook.

### Wallet management
This Ansible playbook will perform basic wallet management for you. This utilises Ansible facts (via `facts.d` in `/etc/ansible/facts.d`) and is still undergoing improvements.
