# Clusterf.ck demo cluster

## Start
````
git clone --recursive https://github.com/johan-adriaans/clusterf.ck
cd clusterf.ck
make start
make bootstrap-cluster
````

## Status

Check cluster for problems with:
````
vagrant status
--
vagrant ssh cluster-member-1
etcdctl cluster-health
fleetctl list-machines
fleetctl list-units
````

Tail centralized log:
````
make log
````

HAProxy dasboard:
 - http://clusterf.ck.driaans.nl:1000
 - User: admin
 - Pass: demo

## Create subdomains
Create folders in /mnt/data/user_data with httpdocs subfolders for [foldername].clusterf.ck.driaans.nl subdomains. (currently forces index.php as index)
````
mkdir -p /mnt/data/user_data/example/httpdocs
echo '<?php phpinfo();' > /mnt/data/user_data/example/httpdocs/index.php
````

## Cleanup

````
make clean
````
