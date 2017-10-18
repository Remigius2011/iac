
hosts
=====

this section describes the basic preparation of your hosts (typically management host and lxd hosts or hosts for the bare environment).
these can be either virtual (tested with VMware, other hypervisors most likely work as well) or metal.
this does not apply to cloud vms to be used as docker hosts, as these are to be provisioned using terraform.

os
--

all scripts are tested with the latest ubuntu LTS and stable ***server*** distributions. currently these are
*xenial* (16.04 LTS) and *zesty* (17.04), *artful* (17.10) to follow soon.

vm specs
--------

for vms, the following minimum specs are suggested:

* **virtual hardware:** only CD, network and display, remove audio, USB, printer
* **management host:** 1CPU, 1 core, 1GB RAM, 8GB disk
* **lxd/docker host:** 1CPU, 1 core, 1GB RAM, 8GB disk
* **settings:** time sync on, bridged networking, no VMware tools
* **os setup:** LVM, no automatic updates, standard system, utilities + OpenSSH server, grub
* **after first boot:** configure static IP + outer DNS, then reboot

for metal, any 64bit intel machine that meets at least the above specs will do (SSD strongly recommended).

notes
-----

* **use of vms:** especially while experimenting with the scripts, the use of VMs adds a lot of flexibility. create
  an initial snapshot after installing the vm to the above specs.
* **outer DNS:** has proven mandatory for adding PPAs on zesty. even when connecting via a proxy, gpg performs a DNS
  lookup for the key server before establishing the connection to the proxy which fails without a full DNS resolution.
  a work-around might be adding the key server to the hosts file, but this has not been tested yet.
* **time:** *lxd* performs its own sophisticated trust management by creating and exchanging keys fully under the hood.
  it has been observed on several occasions that this works flawlessly ***only if times between lxd clients and remotes
  are in sync***. this affects mainly the management host and the lxd hosts. if you encounter any problems, the best
  approach is to restart from scratch (there is an article on [lxd security](https://lxd.readthedocs.io/en/latest/security/)
  in the lxd doc which might help avoiding this).
