# lotus-automation for ansible
This is an experimental port of lotus-automation to Ansible.

## Requirements
- A modern version of Ansible and Python3 (a specific minimum version will be specified at a later date).
- All requirements specified in the [lotus-automation README](../README.md#requirements).
- Passwordless sudo enabled on your Lotus node (alternatively, add the flags --become and --ask-become-pass when running ansible-playbook)
- If you are using Secure Boot on your Lotus node, please read [the note on Secure Boot](#note-on-secure-boot).

## Usage
- Clone this repository and `cd` into it
```
git clone https://github.com/Zorlin/lotus-automation.git && cd lotus-automation
```
- Run the setup script to symlink Ansible Galaxy roles into place. This will not be needed once we make the roles available via Galaxy.
```
./setup_ansible_roles.sh
```
- Copy `ansible/inventory.example` to `ansible/inventory` and edit it to suit your needs.
```
cp ansible/inventory.example ansible/inventory && editor ansible/inventory
```
- Copy `ansible/group_vars/all.example` to `ansible/group_vars/all` and edit it to suit your needs.
```
cp ansible/group_vars/all.example ansible/group_vars/all && editor ansible/group_vars/all
```
- Change into the `ansible` directory.
```
cd ansible
```
- If this is your first time running lotus-automation for Ansible on this machine, run the Ansible Galaxy install process.
```
ansible-galaxy install -r roles/requirements.yml ; ansible-galaxy install -r collections/requirements.yml
```
- Now run the playbook and deploy your Lotus node.
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
This Ansible playbook will attempt rudimentary wallet management for you. This depends on the owner wallet being in position #0 in `lotus wallet list`, and the worker wallet being in position #1. Please let us know if you have special requirements that conflict with this, and we'll help you work around this dependency.

If you are deploying Boost, this will also depend on the storage deals wallet being in position #2 and the collateral wallet being in position #3.

### General notes
- This is a work in progress and is not yet ready for use.
- Ansible Molecule + Podman is to be used for testing and developing the individual roles.
