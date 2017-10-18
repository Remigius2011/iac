
digital ocean master data
=========================

the files in this directory contain the value ranges for distribution images, sizes and regions in the do (digital ocean) cloud.
they have been obtained oct 4 2017 by issuing the following curl commands:

images-p1.json and images-p1.json
---------------------------------

```bash
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DO_API_TOKEN" "https://api.digitalocean.com/v2/images?type=distribution"
```

```bash
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DO_API_TOKEN" "https://api.digitalocean.com/v2/images?page=2&type=distribution"
```

regions.json
------------

```bash
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DO_API_TOKEN" "https://api.digitalocean.com/v2/regions"
```

sizes.json
----------

```bash
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DO_API_TOKEN" "https://api.digitalocean.com/v2/sizes"
```

digital ocean api
-----------------

normally, in the context of this project, only terraform talks to the do api, but e.g. here, to obtain the value ranges,
it makes sense to issue a few curl commands. Here's the [link to the api documentation](https://developers.digitalocean.com/documentation/v2/).
