
step-by-step instructions
=========================

this doc helps you to execute the scripts in this repo. the following prerequisites must be met:

* [get some linux hosts (metal/vm)](hosts.md)
* [adjust the configuration](configuration.md)

overview
--------

the operations are organized as steps, as follows:

* **step 1:** set up the *management* host
* **step 2:** set up the *lxd* hosts
* **step 3:** *provision* docker hosts (lxd/do)
* **step 4:** set up the *docker* hosts
* **step 5:** *spin up* docker containers and services

the following table shows a cross-reference of the applicability of the steps
to the environments:

| environment | step 1 | step 2 | step 3 | step 4 | step 5 |
| ----------- | :----: | :----: | :----: | :----: | :----: |
| bare        |   x    |   x    |   x    |   x    |   x    |
| lxd         |   x    |        |   x    |   x    |   x    |
| do          |   x    |        |        |   x    |   x    |

in addition to this, the non-provisioned hosts (management host, lxd host and bare docker hosts) have tp be prepared
for ansible. the remaining sections of this document describe the steps in more detail and give instructions on how
to execute them.

in the remainder of this guide it is assumed that you have prepared your [hosts](hosts.md), forked and cloned
the repo into `~/iac` (which should now be your current working directory - verify by executing `pwd`)
and adjusted the [configuration](configuration.md).

the scripts
-----------

the scripts that are used to execute the steps are contained in the root directory of the repo. when you clone it,
they are already executable, but as long as the current directory is not in the `PATH`, you have to prefix them with
`./` to invoke them. to fix this, see the [cheat sheet](cheatsheet.md)

preparation for ansible
-----------------------

**ansible playbooks:** `init-ansible.yml` and `update-known-hosts.yml`

this consists of the following tasks:

* set initial proxy environment for apt
* install python2
* copy the current user's ssh public key to the remote host
* add the host to the `known_hosts` file

all hosts that are not provisioned using terraform must be prepared for ansible.
this can be achieved using one the following command simultaneously for all environments:

```bash
$ ./prepare-for-anisble.sh mgt bare etc/lxd/hosts-inventory
```

or individually:

```bash
$ ./prepare-for-anisble.sh mgt
$ ./prepare-for-anisble.sh bare
$ ./prepare-for-anisble.sh etc/lxd/hosts-inventory
```

step 1: set up the *management* host
------------------------------------

**ansible playbook:** `mgmt.yml`

this consists of the following tasks:

* proxy configuration
* install common packages
* install and configure ufw
* setup time synchronization
* install git and other utilities
* install upstream ansible and lxd-client packages
* download terraform and terraform-lxd-provider
* copy ssh key pair

before using the later steps, you must setup a management host.
this is achieved using the following commands
(assuming you have already invoked `./prepare-for-anisble.sh mgt`):

```bash
$ ./s1-mgt.sh
```

or, if you have copied or renamed the `mgt` directory:

```bash
$ ./s1-mgt.sh <env>
```

step 2: set up the *lxd* hosts
------------------------------

**ansible playbooks:** `lxd-hosts.yml` and `lxd-clients.yml`

this consists of the following tasks:

* proxy configuration
* install common packages
* install and configure ufw
* setup time synchronization
* push ssh public key
* remove password access
* install lxd
* initialize lxd
* download some images (xenial, zesty)
* add lxd remotes and routes to the management host

this step sets up the lxd hosts.
this is achieved using the following commands
(assuming you have already prepared a management host and invoked `./prepare-for-anisble.sh lxd`):

```bash
$ ./s2-lxd.sh
```

or, if you have copied or renamed the `mgt` directory:

```bash
$ ./s2-lxd.sh <env>
```

verify the installation using the following commands starting on the management host:

```bash
$ lxc remote list
$ ssh -l <management-user> <host>
$ lxd --version
$ (press ctrl+D to get back to the management host)
```

step 3: *provision* docker hosts (lxd/do)
-----------------------------------------

***terraform script:*** `<env>/tf/<env>.tf` (where `<env>` is the given environment - e.g. `lxd` or `do`)

**ansible playbooks:** `init-ansible.yml` and `update-known-hosts.yml`

this consists of the following tasks:

* provision the hosts (lxd or digitalocean)
* create management user
* install OpenSSH (lxd only - do images already have it)
* push ssh public key
* install python
* create inventory and ansible variables (in environment subdirectory)
* add the new hosts to known_hosts on the management host

before provisioning docker hosts in the cloud using the `do` environment, you must sign up on
digitalocean [with referral](https://m.do.co/c/4d082f0c649f) / [without referral](https://www.digitalocean.com/)
and configure the api token and the fingerprint of an uploaded public key as described [here](configuration.md)

otoh, you must prepare lxd hosts in order to provision docker hosts as lxd containers.

to provision the hosts, execute the following command:

```bash
$ ./s3-prov.sh <env>
```

where `<env>` is the given environment - e.g. `lxd` or `do`, i.e. one of:

```bash
$ ./s3-prov.sh lxd
$ ./s3-prov.sh do
```

verify the provisioning using the following commands starting on the management host:

```bash
$ ssh -l <management-user> <host>
$ (press ctrl+D to get back to the management host)
```

for lxd:

```bash
$ lxc remote list
$ lxc list <lxd-host-name>:
$ lxc exec <lxd-host-name>:<lxd-container-name>
$ (press ctrl+D to get back to the management host)
```

for do: look into the droplets list in your digitalocean profile.

step 4: set up the *docker* hosts
---------------------------------

**ansible playbooks:** `docker.yml` and `swarm.yml`

this consists of the following tasks:

* proxy configuration
* install common packages
* install and configure ufw
* setup time synchronization
* push ssh public key
* remove password access
* install docker upstream (ubuntu package possible but currently not tested)
* adjust ufw configuration
* set up swarm cluster

to setup docker hosts, execute the following command:

```bash
$ ./s4-docker.sh <env>
```

where `<env>` is the given environment - e.g. `lxd` or `do`, i.e. one of:

```bash
$ ./s4-docker.sh lxd
$ ./s4-docker.sh do
$ ./s4-docker.sh bare
```

verify the docker installation and swarm state using these commands on each docker host:

```bash
$ docker --version
$ docker info
$ docker info | grep Swarm
```

step 5: *spin up* docker containers and services
------------------------------------------------

**ansible playbooks:** `spinup.yml`

this consists of the following task:

* spin up containers, services and stacks

to spin up, execute the following command:

```bash
$ ./s5-spinup.sh <env>
```

where `<env>` is the given environment - e.g. `lxd` or `do`, i.e. one of:

```bash
$ ./s5-spinup.sh lxd
$ ./s5-spinup.sh do
$ ./s5-spinup.sh bare
```

check the running containers/services/stacks e.g. by issuing:

```bash
$ curl <host>:<port>
```

appendix: quickly get rid of provisioned hosts
----------------------------------------------

terraform can also destroy what terraform has provisioned! this can either be achieved by issuing

```bash
$ terraform destroy
```

in the respective `tf` directory, or by executing again `s3-prov.sh` as follows:

```bash
$ ./s3-prov.sh <env> destroy
```

where `<env>` is the given environment - e.g. `lxd` or `do`, i.e. one of:

```bash
$ ./s3-prov.sh lxd destroy
$ ./s3-prov.sh do destroy
```

don't forget to verify the destruction using `lxc list <remote>:` or by looking into the droplet list on
digitalocean!

***have fun!!!***
