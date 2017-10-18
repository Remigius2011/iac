
# see also https://www.terraform.io/docs/providers/do/index.html
# see also https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean

# injected via command line / environment

variable "management_user"           {}
variable "management_password"       {}
variable "do_api_token"              {}
variable "do_key_fingerprint"        {}

# from terraform.tfvars

variable "container_params"          { type = "map" }
variable "container_count"           {}

variable "index_name"                {}
variable "index_image"               {}
variable "index_region"              {}
variable "index_size"                {}

provider "digitalocean" {
  token = "${var.do_api_token}"
}

resource "digitalocean_droplet" "dockerhost" {
  count = "${var.container_count}"

  name = "${element(split("|", var.container_params[count.index]), var.index_name)}"
  image = "${element(split("|", var.container_params[count.index]), var.index_image)}"
  region = "${element(split("|", var.container_params[count.index]), var.index_region)}"
  size = "${element(split("|", var.container_params[count.index]), var.index_size)}"

  private_networking = true
  ssh_keys = [
    "${var.do_key_fingerprint}"
  ]

  connection {
    user = "root"
    type = "ssh"
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      # add management_user user with password and add it to group sudo
      "adduser --disabled-password --gecos \"\" ${var.management_user}",
      "echo \"${var.management_user}:${var.management_password}\" | chpasswd",
      "usermod -aG sudo ${var.management_user}",

      # add the management user's public key and the container's host key
      "mkdir --mode=0700 /home/${var.management_user}/.ssh",
      "touch /home/${var.management_user}/.ssh/authorized_keys",
      "chmod 0600 /home/${var.management_user}/.ssh/authorized_keys",
      "chown -R ${var.management_user}:${var.management_user} /home/${var.management_user}/.ssh",
      "echo \"${file("~/.ssh/id_rsa.pub")}\" >> /home/${var.management_user}/.ssh/authorized_keys",

      # install python-simplejson (for ansible) - delay necessary for apt-get update to succeed
      "sleep 10",
      "apt-get update",
      "apt-get -y install python-simplejson"
    ]
  }
}

data "template_file" "inventory_item_json" {
  template = "{ \"ip\": \"$${ip}\", \"privateIp\": \"$${privateIp}\", \"name\": \"$${name}\", \"region\": \"$${region}\" }"
  count = "${var.container_count}"

  vars {
    ip = "${digitalocean_droplet.dockerhost.*.ipv4_address[count.index]}"
    privateIp = "${digitalocean_droplet.dockerhost.*.ipv4_address_private[count.index]}"
    name = "${digitalocean_droplet.dockerhost.*.name[count.index]}"
    region = "${digitalocean_droplet.dockerhost.*.region[count.index]}"
  }
}

output "inventory-json" {
  value = "[\n  ${join(",\n  ", data.template_file.inventory_item_json.*.rendered)}]"
}
