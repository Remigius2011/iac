some common errors and their solutions
======================================

TASK [Gathering Facts]
----------------------

**symptom:** the task creates the following error message:
```json
fatal: [xx.xx.xx.xx]: FAILED! => {"failed": true, "msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
```
**solution:** execute `./prepare-for-ansible.sh <env/inv>` with the environment or inventory of the failing host(s)
if you haven't initialized it yet. it is also possible that the ssh key was not added yet to the list of known hosts,
then execute `./update-known-hosts.sh <env/inv>` or simply `ssh <ip>`, accept the key and quit.


TASK [common : install ufw] (or some other apt task)
----------------------------------------------------

**symptom:** the task creates the following error message:
```json
fatal: [xx.xx.xx.xx]: FAILED! => {"changed": false, "cmd": "apt-get update", "failed": true, "msg": "E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock directory /var/lib/apt/lists/", "rc": 100, "stderr": "E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock directory /var/lib/apt/lists/\n", "stderr_lines": ["E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)", "E: Unable to lock directory /var/lib/apt/lists/"], "stdout": "Reading package lists...\n", "stdout_lines": ["Reading package lists..."]}
```
**solution:** there is most likely an automated upgrade running. try to run `ps aux | grep [a]pt` and rerun the playbook
 once the result is empty. if the error persists, remove the lock using `rm -f` and retry.

"error: Get https://<lxd-host>:8443: Forbidden" when adding the lxd remotes
---------------------------------------------------------------------------

**solution:** most likely, you have a proxy configured on the management host. in this case, all lxd hosts must be added
to the `no_proxy` environment variable. this is best configured in the `ansible-local-vars.yml` of the management environment.
once the environment is fixed (in your session and in `/etc/environment`), you should be able to run the command
successfully.

certificate issues with lxc/lxd
-------------------------------

**solution:** most likely, there is a time synchronization problem between the client (mgt host) and the server (lxd host).
verify that all clocks are in sync. when using vmware, enable time sync for all vms by checking "Synchronize guest time with host"
in VM > settings > Options > WMware Tools. if the error persists, uninstall and reinstall lxd for all clients and hosts to be sure
certificates are regenerated (there may be a shortcut for this, but I haven't found it set). It might in some cases be necessary
to initially sync the time by issuing the following `timedatectl` commands:
```bash
$ timedatectl set-local-rtc true --adjust-system-clock
$ timedatectl set-local-rtc false
```

ssh connection to do cannot be established (infinite retries)
-------------------------------------------------------------

**solution:** make sure the private key you use on the management host matches the public key you uploaded to do
and the fingerprint you added to ansible-vault. the three must match. on any mismatch, you cannot connect to do.
to repair, perform the following steps:

* `terraform destroy` the do droplets in question
* upload the public key in `~/.ssh/id_rsa.pub` to your do account
* copy the fingerprint from do and update it in your ansible-vault
* commit and push to your git repo
* restart provisioning

slow progress on installing python in do droplets
-------------------------------------------------

**solution:** sometimes it looks like the connection from do droplets to the ubuntu package repos is dead slow, resulting
in total provisioning times of upt to 8-10 min and more instead of the usual about 1min 30s. If you are patient,
just let it progress slowly, it may succeed. if you don't like slow progress, `ctrl+c` the provisioning operation,
`terraform destroy` the droplets you have just created and do something completely different. chances are good
things are back to normal when you retry next time. 
