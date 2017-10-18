
configuration
=============

this section gives a guide on adapting the configuration to your environmental requirements, which are basically:

* **secrets:** passwords, keys etc.
* **network:** ip addresses and host names
* **os versions:** where to use xenial or zesty during provisioning (not much choice for now)
* **docker landscape:** swarms, containers, services, stacks

**note:** while care has been taken to stay as ***dry*** as possible, the configuration given here is not guaranteed to be
entirely free of redundancy. for example, there is some overlap between terraform and ansible variables, which has been
mitigated to some extend by using ***jq*** to generate ansible inventories and variables from a specially prepared
terraform output.

overview
--------

the following files contain configuration variables for ansible and terraform

* **ansible-vault:** secrets used in ansible and terraform
* **ansible-local-vars.yml:** variables for local environment (proxy etc.)
* **env/bare/group_vars/all.yml:** variables for ansible configuration of docker hosts on bare os (metal/vm)
* **env/do/group_vars/all.yml:** variables for ansible configuration of digitalocean droplets
* **env/do/tf/terraform.tfvars:** variables for terraform provisioning of digitalocean droplets
* **env/lxd/group_vars/all.yml:** variables for ansible configuration of lxd hosts and containers
* **env/lxd/tf/terraform.tfvars:** variables for terraform provisioning of lxd containers
* **env/mgt/id_rsa:** private key to be deployed on the management host (optional)
* **env/mgt/id_rsa.pub:** public key to be deployed on all hosts (optional)

please look into ech of these files (at least for the environments you like to use) and adapt them to your needs.
locations to change are marked with `# todo` for optional changes or `# todo (mandatory)` for mandatory changes
in the respective files. of course, you are also welcome change any line in the terraform or ansible scripts
at your discretion.

files with the `.yml` extension are in [YAML](http://yaml.org/) and contain ansible variables, files with
`.tfvars` extension contain [terraform variables](https://www.terraform.io/intro/getting-started/variables.html).

the files in the respective `group_vars` directory contain variables to be applied to hosts in the
respective group. the available files `all.yml` are applied to all hosts of an inventory.
it is also possible to create a subdirectory in `group_vars` that can contain multiple files to be
applied to the group.
note that files called `docker-hosts.yml` are created after terraform provisioning and contain
variables for the group `docker-hosts` which is contained in the inventory file that is also created
after terraform provisioning.

the files that require particular attention are documented here in separate sections.
all other files contain comments on how to configure the required values.

ansible-vault
-------------

the file `ansible-vault` contains secret values. the sample given here is unencrypted (see below how to encrypt it),
but typically it is encrypted and can only be edited using the program
`ansible-vault`. when the vault is encrypted, it can safely be added even to a public repository
(just keep the vault password safe).

see also the following resources about ansible vaults:

* [ansible vault](http://docs.ansible.com/ansible/latest/vault.html)
* [using vaults in playbooks](http://docs.ansible.com/ansible/latest/playbooks_vault.html)

the vault must contain the following name - value pairs:

* **management_user:** username of user that is used in all ansible and terraform operations
* **ansible_vault_password:** password with which the vault is encrypted (optional)
* **ansible_ssh_pass:** password for ansible and terraform ssh access
* **ansible_become_pass:** password for ansible sudo
* **lxd_trust_password:** trust password for lxd clients (only for lxd environment)
* **digitalocean_api_token:** api token of your digitalocean account (only for do environment)
* **digitalocean_key_fingerprint:** md5 fingerprint of the ssh key used to access the digitalocean droplets (only for do environment)

before provisioning docker hosts in the cloud using the `do` environment, you must sign up on
digitalocean [with referral and initial 10$ credit](https://m.do.co/c/4d082f0c649f) / [without referral](https://www.digitalocean.com/).
in order to use key based ssh access (which is endorsed here), you must upload the public key of the management
user to your digitalocean profile. to obtain the public key fingerprint, you can either look it up in your
digitalocean profile once it is uploaded or execute the following command:

```bash
$ ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | cut -d ' ' -f 2 | cut -b 5-
```

to manipulate a vault file, you can use the following commands:

```bash
$ ansible-vault --help
$ ansible-vault create <vault-file>
$ ansible-vault edit <vault-file>
$ ansible-vault view <vault-file>
$ ansible-vault encrypt <vault-file>
$ ansible-vault decrypt <vault-file>
```

the command `ansible-vault encrypt` can be used to encrypt any other files, e.g. private keys for ssh.
if these are referenced from ansible (e.g. in a `copy` task), they are automatically decrypted before
being copied to the target.

the vault password can either be given interactively, via the parameter `--vault-password-file=<file>`
or using the environment variable `DEFAULT_VAULT_PASSWORD_FILE`, which must point to a text file containing the password.
see also [providing vault passwords](http://docs.ansible.com/ansible/latest/vault.html#providing-vault-passwords)

note that the `ansible-vault`is also used to stored secret values passed to terraform (see script `s3-prov.sh`).

key pair in env/mgt/id_rsa and env/mgt/id_rsa.pub
-------------------------------------------------

these files are optional. if present (of course, this only makes sense if both files are present),
the private key is copied onto the management host and the public keys are distributed ot all hosts.

to create a key pair, follow e.g. these [instructions](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).

note that the private key can (and should!!!) easily be encrypted using ansible-vault:

```bash
$ ansible-vault encrypt env/mgt/id_rsa
```

it is then automatically decrypted by ansible when copying it to the management host. the public key can obviously be
left unencrypted.

when the key pair is used to access digitalocean droplets, just add the content of the public key file to your
digitalocean profile (section security).
