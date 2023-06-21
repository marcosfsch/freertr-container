# freertr-container-dpdk
A basic FreerTr docker container using dpdk backend

## Prerequisite
- Install docker on Dockerhost with the method of your choice
- Make sure that docker the container inherit from docker host DNS configuration
- Check this by issuing: 
```shell
sudo docker run busybox nslookup www.google.com
```
   
## How to build freerTr container
```shell
git clone -b dpdk https://github.com/marcosfsch/freertr-container.git
cd ./freertr-container
sudo docker build --tag freertr/freertr-dpdk:latest .
```
## How to configure FreerTr before running the container
There are 2 files in ./freertr-docker/run :
```shell
./freertr-hw.txt  
./freertr-sw.txt
```

These files are in the format <freerouter-hostname>-hw.txt and <freerouter-hostname>-sw.txt

As a start use the sample provided and replace 0000:19:00.0 by your NIC PCI-ID device

### freertr-sw.txt
It is the FreerTr router configuration.  <br>
For more detail please refer to FreerTr homepage: http://www.freertr.org/ <br>

## How to run FreerTr container
There is 2 processes that is run inside this container: <br>
- A "control plane" process: This process is written in Java and can be run in user space
- A "data plane" process: This process is written in C run in user space and needs more priviledges to access the DPDK interfaces
  => This explain why we use --privileged flag. In addition

In addition FreerTr will manipulate the network interface attached to it. <br>
=> This explain why we use --network host flag. In addition
```shell
FREERTR_INTF_LIST="0000:19:00.0 0000:19:00.1"
docker run -it -e "FREERTR_INTF_LIST=$FREERTR_INTF_LIST" -e "FREERTR_HOSTNAME=freertr" -v "`pwd`/run:/opt/freertr/run" --name freertr-001 -v /dev/hugepages:/dev/hugepages --privileged --net host freertr/freertr-dpdk:latest
```

## Preparing your NIC for DPDK
If you are using a Mellanox/Nvidia NIC follow the steps in: https://doc.dpdk.org/guides/platform/mlx5.html <br>
For other NICs use: https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html

## Acknowledgement
I would like to thank the original maintainer of FreerTr for this awesome piece of code. <br>
If you need to understand networking protocol. Read the source, it is exceptionnally well written. <br>
If you like reading IETF RFCs you will enjoy studying this code. (You'll save tons of sleeping pills ;-) )<br>

Kudos to <a href=http://mc36.nop.hu/cv.html>Csaba MATE</a> then... all credits goes to him ! <br>

