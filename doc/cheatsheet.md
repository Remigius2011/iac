
cheat sheet
===========

this cheat sheet lists useful commands to work with shell and lxd.
for docker, you might find the [docker cheat sheet](https://dockercheatsheet.painlessdocker.com/) useful.
for ansible and terraform, refer to the respective sections in the [resources](resources.md).

shell
-----

for several of these commands, you must be root. the commands tell you, if they don't like to serve you
as a non-privileged user.

**disclaimer:** I'm not a shell wizard! my wisdom comes mainly from stackoverflow and other internet resources
that popped up during my extensive google searches. if there are enhancements that go beyond just being a
matter of taste, then please let me know.

very essential bash shortcuts in alphabetical order (there are many more...)

* **ctrl+A** - got to start of line
* **ctrl+C** - terminate current command
* **ctrl+D** - logout (or leave root session) - only when line is empty
* **ctrl+E** - got to end of line
* **ctrl+K** - clear command line from cursor to end
* **ctrl+L** - clear screen
* **ctrl+R** - search in command history (ctrl+G to escape)
* **ctrl+U** - clear command line from cursor to begin of line

edit a file (or use `nano` if available and you are afraid of `vi`)

```bash
$ vi <file>
```

become root (or just prefix `sudo` to all commands that require root privileges)

```bash
$ sudo -s
```

display network configuration

```bash
$ ifconfig
$ ip addr
$ cat /etc/network/interfaces
$ ip route list
$ route -n
```

display firewall configuration (root only)

```bash
$ ufw status
$ ufw status verbose
$ ufw status numbered
```

display active processes

```bash
$ ps aux
$ ps aux | grep <name>
```

display listening services (as root you also get process names)

```bash
$ netstat -tulpn
$ netstat -tulpn | grep <name>
$ netstat -tulpn | grep <port>
```

restart services - systemd (only as root)

```bash
$ systemctl restart <service>
$ systemctl restart networking
```

display system information

```bash
$ lsb_release -a
$ uname -a
```

avoid having to type `./` as prefix for all scripts in the current directory (this can also be added to your
`~.bashrc` - best using ansible)

```bash
export PATH=$PATH:.
```

lxd
---

the command line client of `lxd` is `lxc` (not to be confused with the container daemon of the same name).
therefore, most commands given here start with `lxc`, although these are lxd CLI commands.

this assumes lxd hosts have been added using ansible or `lxc remote add`.

`lxc` commands can be executed with the management user, which has been added to the group `lxd`.

display the version, get help

```bash
$ lxd --version
$ lxc --version
$ lxc --help
```

get info and config

```bash
$ lxc info
$ cat /etc/init/lxd.conf
```

ssh into a remote container

```bash
$ lxc exec <remote>:<container> bash
```

show lxd log (press ctrl+C to exit from `tail -f`)

```bash
$ tail -100 /var/log/lxd/lxd.log
$ tail -f /var/log/lxd/lxd.log
```

list images

```bash
$ lxc image alias list <remote>:
$ lxc image alias list ubuntu:
$ lxc image alias list ubuntu-daily:
$ lxc image alias list images:
$ lxc image alias list images: | grep amd64
$ lxc image list ubuntu-daily: | grep "17\.10" | grep amd64
$ lxc image list -c dsu ubuntu-daily: | grep "17\.10" | grep amd64
```

list remote hosts that have been added

```bash
$ lxc remote list
```

list running containers

```bash
$ lxc list
$ lxc list <remote>:
```

manage profiles

```bash
$ lxc profile list <remote>:
$ lxc profile show <remote>:<profile>
$ lxc profile edit <remote>:<profile>
```

manage containers

```bash
$ lxc info <remote>:<container>
$ lxc config show <remote>:<container> --expanded
$ lxc config edit <remote>:<container>
```

manage files in a container

```bash
$ lxc file --help
$ lxc file pull <remote>:<container>/<path> <targetpath>
$ lxc file push <path> <remote>:<container>/<targetpath>
$ lxc file delete <remote>:<container>/<path>
$ lxc file edit <remote>:<container>/<path>
```
