
# todo
# configure your proxy url here or remove proxy configuration from the terraform script lxd.tf, e.g.
# proxy_url = "http://<ip>:<port>/"
proxy_url = ""

# todo (mandatory)
# configure a map of numbers to droplet parameters here
# each line contains a pipe separated list of:
# name: the host / container name of the lxd container
# image: the image short name of the lxd container
# remote: the name of the remote host on which the container is created
# ip: the static ip address for the container (should be inside the network range configured for the lxd host)
# e.g.
container_params = {
  "0" = "lxd00|xenial|host00|<ip00>"
  "1" = "lxd01|xenial|host00|<ip01>"
  "2" = "lxd02|xenial|host00|<ip02>"
  "3" = "lxd03|xenial|host00|<ip03>"
}

# todo (mandatory)
# the count of droplets to be created (number of lines of the above)
container_count = 4

# dont modify these variable values
index_name = 0
index_image = 1
index_remote = 2
index_ip = 3
