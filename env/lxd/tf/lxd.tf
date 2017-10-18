
# see https://github.com/sl1pm4t/terraform-provider-lxd

# injected via command line / environment

variable "management_user"           {}
variable "management_password"       {}

# from terraform.tfvars

variable "proxy_url"                 {}

variable "container_params"          { type = "map" }
variable "container_count"           {}

variable "index_name"                {}
variable "index_image"               {}
variable "index_remote"              {}
variable "index_ip"                  {}

# lxd provider

provider "lxd" {
}

# lxd containers

resource "lxd_container" "container" {
  count = "${var.container_count}"

  name = "${element(split("|", lookup(var.container_params, count.index)), var.index_name)}"
  image = "${element(split("|", lookup(var.container_params, count.index)), var.index_image)}"

  remote = "${element(split("|", lookup(var.container_params, count.index)), var.index_remote)}"
  ephemeral = false
  profiles = ["default"]

  config {
    security.nesting = "true"
    security.privileged = "true"
# the following parameters are necessary in some constellations (os/networking/services/volumes/whatnot)
# experiment at your own discretion
    linux.kernel_modules = "overlay,nf_nat,ip_tables,br_netfilter,xt_conntrack,nf_conntrack,ip_vs,vxlan"
    raw.lxc = "lxc.apparmor.profile=unconfined"
  }

# the following device may be omitted at least in easy conditions if the container is xenial on a zesty host
  device {
    name = "aadisable"
    type = "disk"

    properties {
      path = "/sys/module/apparmor/parameters/enabled"
      source = "/dev/null"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties {
      ipv4.address = "${element(split("|", lookup(var.container_params, count.index)), var.index_ip)}"
      nictype = "bridged"
      parent  = "lxdnat0"
    }
  }

  # set http proxy for apt and environment
  # echo "Acquire::http::Proxy \"${var.proxy_url}\";" > /etc/apt/apt.conf
  # todo: handle empty proxy_url
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"echo \\\"Acquire::http::Proxy \\\\\\\"${var.proxy_url}\\\\\\\";\\\" > /etc/apt/apt.conf\""
  }
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"echo \\\"http_proxy=\\\\\\\"${var.proxy_url}\\\\\\\"\\\" >> /etc/environment\""
  }
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"echo \\\"https_proxy=\\\\\\\"${var.proxy_url}\\\\\\\"\\\" >> /etc/environment\""
  }

  # add management_user user with password and add it to group sudo
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"adduser --disabled-password --gecos \\\"\\\" ${var.management_user}\""
  }
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"echo \\\"${var.management_user}:${var.management_password}\\\" | chpasswd\""
  }
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"usermod -aG sudo ${var.management_user}\""
  }

  # install openssh-server
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"apt-get -y install openssh-server\""
  }

  # add the management user's public key and the container's host key
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"mkdir --mode=0700 /home/${var.management_user}/.ssh\""
  }
  provisioner "local-exec" {
    command = "lxc file push --mode=0600 ~/.ssh/id_rsa.pub ${self.remote}:${self.name}/home/${var.management_user}/.ssh/authorized_keys"
  }
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"chown -R ${var.management_user}:${var.management_user} /home/${var.management_user}/.ssh\""
  }

  # install python-simplejson (for ansible)
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"apt-get -y install python-simplejson\""
  }

  # create file /.dockerenv to signal docker it is running inside a container
  provisioner "local-exec" {
    command = "lxc exec ${self.remote}:${self.name} -- bash -c \"touch /.dockerenv\""
  }
}

data "template_file" "inventory_item_json" {
  template = "{ \"ip\": \"$${ip}\", \"privateIp\": \"$${ip}\", \"name\": \"$${name}\" }"
  count = "${var.container_count}"

  vars {
    ip = "${element(split("|", lookup(var.container_params, count.index)), var.index_ip)}"
    name = "${lxd_container.container.*.name[count.index]}"
  }
}

output "inventory-json" {
  value = "[\n  ${join(",\n  ", data.template_file.inventory_item_json.*.rendered)}]"
}
