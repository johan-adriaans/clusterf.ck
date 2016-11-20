# clusterf.ck demo

## Start
````
git clone --recursive https://github.com/johan-adriaans/clusterf.ck
cd clusterf.ck
make start
make bootstrap-cluster
make log
````

## Status
HAProxy dasboard: http://clusterf.ck.driaans.nl:1000
User: admin
Pass: demo

````
vagrant status
vagrant ssh cluster-member-1
etcdctl cluster-health
fleetctl list-machines
fleetctl list-units
````

## Create subdomains
Create folders in /mnt/data/user_data with httpdocs subfolders for [foldername].clusterf.ck.driaans.nl subdomains. (currently forces index.php as index)

## Cleanup

````
make clean
````
