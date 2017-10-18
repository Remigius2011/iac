
# regions (as seen from bsl/swisscom):
# see http://speedtest-fra1.digitalocean.com/
# see http://www.bandwidthplace.com/
# europe
# ams2 (no storage, no c-2):
#  ping  22ms, dnl 116.14Mb/s, upl 67.12Mb/s
#  ping  20ms, dnl 112.74Mb/s, upl 84.04Mb/s
# ams3 (no storage):
#  ping  20ms, dnl 108.46Mb/s, upl 70.82Mb/s
#  ping  20ms, dnl 112.44Mb/s, upl 69.39Mb/s
# fra1:
#  ping  15ms, dnl 106.61Mb/s, upl 73.01Mb/s
#  ping  15ms, dnl 108.11Mb/s, upl 72.57Mb/s
# lon1:
#  ping  26ms, dnl 106.43Mb/s, upl 68.45Mb/s
#  ping  27ms, dnl 112.81Mb/s, upl 62.70Mb/s
# overseas
# blr1:
#  ping 152ms, dnl  57.94MB/s, upl 66.06Mb/s
# nyc1:
#  ping  98ms, dnl  60.69MB/s, upl 70.94Mb/s
# sfo1:
#  ping 166ms, dnl 104.83MB/s, upl 67.38Mb/s
# sgp1:
#  ping 225ms, dnl  59.85MB/s, upl 60.61Mb/s
# tor1:
#  ping 126ms, dnl  52.53MB/s, upl 65.60Mb/s

# ubuntu distros:
# ubuntu-14-04-x32, ubuntu-14-04-x64, ubuntu-16-04-x32, ubuntu-16-04-x64, ubuntu-17-04-x32, ubuntu-17-04-x64

# todo (mandatory)
# configure a map of numbers to droplet parameters here
# each line contains a pipe separated list of:
# name: the host name of the droplet
# image: the image short name of the droplet
# region: the region in which the droplet is created
# size: the disk size for the droplet
# e.g.
container_params = {
  "0" = "do00|ubuntu-16-04-x64|fra1|512mb"
  "1" = "do01|ubuntu-16-04-x64|fra1|512mb"
  "2" = "do02|ubuntu-16-04-x64|fra1|512mb"
  "3" = "do03|ubuntu-16-04-x64|fra1|512mb"
}

# todo (mandatory)
# the count of droplets to be created (number of lines of the above)
container_count = 4

# dont modify these variable values
index_name = 0
index_image = 1
index_region = 2
index_size = 3
