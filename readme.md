
infrastructure as code
======================

_provisioning docker hosts and containers using terraform, ansible and lxd on metal and in the cloud_

this repo accompanies my talk held at [BaselOne17](http://baselone.ch/), which is
also available on [slideshare](https://www.slideshare.net/remigius-stalder/iac-baselone17).
of course, you can also use the content of it if you have missed the conference.

**disclaimer:** you use the content of this repo at your sole and only risk - 
no explicit or implied warranties are made. the author of these artifacts cannot
under any circumstances be held liable for any damage arising from the use, misuse,
abuse or abstinence to use artifacts in this repo.

**digitalocean referral:** as ***digitalocean*** (sometimes abbreviated as ***do*** here) is used
as the primary sample of a cloud environment (***aws*** possibly to follow), it is likely
some users of this repo might want to sign up for a ***do*** account. I provide links to ***do***
always twofold: as a link with a referral tag and as a link without the referral. if you
choose to use the referral, ***you*** get immediately a 10$ credit on your digitalocean account
and I will eventually get some credit, too, when you have converted to a paying customer
(namely after you having spent 25$ above the initial credit). I make this transparent here,
which gives you the choice of using the referral or not. Here are the links:
[digitalocean with referral](https://m.do.co/c/4d082f0c649f)
and [digitalocean without referral](https://www.digitalocean.com/)

of course, I would appreciate if you support my work by using the referral to sign up...

tl;dr
-----

* prepare some [hosts](doc/hosts.md)
* fork and clone this repo
* adjust [configuration](doc/configuration.md) (vault + all .yml and .tfvars files)
* follow the [step-by-step instructions](docs/steps.md)
* if necessary, consult the [resources](doc/resources.md) or the [cheat sheet](cheatsheet.md)
* some typical errors are described [here](doc/errors.md)

overview
--------

the concept of ***infrastructure as code*** (or short ***iac***)  consists of
automating your whole infrastructure provisioning and configuration as a set of
code artifacts that are kept in a code repo.

the content of this repo can serve as a starting point for your own experiments
or even the management of your own productive docker infrastructure or as a set of
examples.

the following open source tools are used (some having a vendor behind providing a
commercial edition and/or support):

* [terraform](https://www.terraform.io/)
* [ansible](https://www.ansible.com/)
* [lxd](https://linuxcontainers.org/lxd/)
* [docker](https://www.docker.com/)
* [jq](https://stedolan.github.io/jq/)

in addition to this readme, a presentation is available on slideshare
(currently only in german).

although the concepts presented in this repo could be used for arbitrary runtime
environments, the use of docker is an opinionated choice, as containerization can serve
as a natural boundary between generic infrastructure as a commodity (which gives the acronym
iac another meaning) and application specific environmental features that are to be bundled
together with the application runtimes in their container or as a set of containers (aka a stack).

repo content
------------

the content of this repo is organized as follows:

* **root:** this readme, the license, scripts and some general configuration files
* **ansible:** ansible playbooks and roles
* **doc:** some more documentation
* **env:** files for the target environments: `bare`, `do` and `lxd` (the subdirectory `tf` contains
  the terraform script and variables where applicable)
* **jq:** [jq](https://stedolan.github.io/jq/) templates to generate ansible inventories and variables
  from terraform output

environments
------------

the current state of this repo supports the following environments / usage scenarios:

* **bare:** bare os on metal/vm as docker hosts
* **lxd:** lxd hosts that have lxd containers as docker hosts
* **do:** cloud vms on digitalocean as docker hosts

in addition to these docker host environments, an environment called **mgt** is provided
that is used to set up a management host from which most of the artifacts in this repo
are used.

getting started
---------------

the following actions are necessary to use the content of this repo:

1. have a linux host with git and ansible (>= 2.4.0.0) ready - check with `ansible --version`
1. create a fork and clone the forked repo
1. adapt configuration (commit and push changes)
1. execute the steps

these actions are outlined right here and explained in more detail in separate docs on
[hosts](doc/hosts.md), [configuration](doc/configuration.md) and the [steps](doc/steps.md).

prerequisites
-------------

**hosts:** to use the code in this repo you will need a set of hosts (virtual or metal)
on which a ubuntu server distribution is installed.
the code is more or less regularly tested on the latest LTS and stable ubuntu
versions. other ubuntu versions may work but are never tested.

**cloud:** for digital ocean provisioning you need (obviously) a digital ocean account and its api keys.

**management host:** initially a management host is prepared. this host is subsequently used for all
further provisioning and configuration.

**bootstrap:** to bootstrap the whole ***iac*** repo, you need a linux system with git and ansible installed.
assuming the linux at hand is a mode or less current ubuntu distribution, you
can install ubuntu packages of these tools with the following command:

```bash
$ sudo apt-get install git ansible
```

you should then be able to determine the version of them as follows:

```bash
$ git --version
$ ansible --version
```

if your ansible version is less than 2.4.0.0, please follow the instructions given
[here](http://docs.ansible.com/ansible/latest/intro_installation.html)
to install a newer version.

later, you will use the upstream versions of ansible, which is highly likely
to be more current. you can verify this by executing the same command on your
management host once it is prepared.

create a fork and clone the forked repo
---------------------------------------

just create a fork of this repo in github. the fork is necessary because
you will have to adapt the configuration to your own needs (see below).
to profit of the concept of ***iac***, you will need to commit cour changes
and push them to your fork, as you are (hopefully) not able to push them to
the original repo.

to clone the repo you have to execute the following commands
(proxy configuration only if necessary - don't forget to adapt the proxy url):

```bash
$ git config --global http.proxy http://proxyuser:proxypwd@proxy.server.com:8080
$ git clone https://remigius_stalder@bitbucket.org/my_github_account/iac.git
```

execute the steps
-----------------

the following steps must be performed:

* one time preparation for ansible
* set up management vm (ansible)
* prepare lxd host (ansible)
* provision lxd containers/cloud instances (terraform)
* configure lxd containers/cloud instances (ansible)
* spin up docker containers on lxd containers (ansible)

the first step must be executed on each metal host of your infrastructure to enable it
for ansible. it is automatically executed during provisioning of lxd containers
ans cloud vms in the corresponding terraform scripts.

once the management host is available, all scripts (i.e. steps >= 2) are directly executed there.

your participation
==================

if your have noteworthy observations or enhancements, please post an issue
or a pr (currently formless - rules may be imposed if their digestion amounts to
serious effort).
