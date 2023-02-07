# freertr-docker
A basic FreerTr docker container

## Prerequisite
- Install docker on Dockerhost with the method of your choice
- Make sure that docker the container inherit from docker host DNS configuration
- Check this by issuing: 
```shell
sudo docker run busybox nslookup www.google.com
```
   
## How to build freerTr container
```shell
git clone https://github.com/marcosfsch/freertr-container.git
cd ./freertr-docker
sudo docker build --tag freertr/freertr:latest .
```
## How to configure FreerTr before running the container
There are 2 files in ./freertr-docker/run :
```shell
./freertr-hw.txt  
./freertr-sw.txt
```

These files are in the format <freerouter-hostname>-hw.txt and <freerouter-hostname>-sw.txt

As a start use the sample provided and replace eth2 by your NIC device (usually eth0)

### freertr-hw.txt:
In this sample file you'll indicate which Dockerhost interface will be bind to FreerTr container. <br>
The line use to attach an interface to FreerTr container is: <br>
```shell
int <network-device> eth <mac@> <bind_ip@> <tx_port> <bind_ip@> <rx_port> <br>
```

```shell
...
int eth2 eth 0000.1111.2222 127.0.0.1 22706 127.0.0.1 22705
int eth3 eth 0000.1111.3333 127.0.0.1 20011 127.0.0.1 20010
...
```

For more detail please refer to FreerTr homepage: http://www.freertr.org/ <br>

### freertr-sw.txt
It is the FreerTr router configuration.  <br>
For more detail please refer to FreerTr homepage: http://www.freertr.org/ <br>

## How to run FreerTr container
There is 2 processes that is run inside this container: <br>
- A "control plane" process: This process is written in Java and can be run in user space
- A "data plane" process: This process is written in C run in kernel space and need thus more priviledges
  => This explain why we use --privileged flag. In addition

In addition FreerTr will manipulate the network interface attached to it. <br>
=> This explain why we use --network host flag. In addition
```shell
FREERTR_INTF_LIST="0000:19:00.0;0000:19:00.1"
export IFS=";"
ARGS=()
for FREERTR_INTF in $FREERTR_INTF_LIST; do
  sudo dpdk-devbind.py -b vfio-pci $FREERTR_INTF
  ARGS+=( --device /dev/vfio/$(readlink -e /sys/bus/pci/devices/$FREERTR_INTF/iommu_group | xargs basename) )
done
docker run -it -e "FREERTR_INTF_LIST=$FREERTR_INTF_LIST" -e "FREERTR_HOSTNAME=freertr" -v "`pwd`/run:/opt/freertr/run" --name freertr-001 --device /dev/vfio/vfio "${ARGS[@]}" -v /dev/hugepages:/dev/hugepages --cap-add IPC_LOCK --cap-add NET_ADMIN --cap-add SYS_ADMIN --cap-add SYS_NICE freertr/freertr-dpdk:latest
```

## Acknowledgement
I would like to thank the original maintainer of FreerTr for this awesome piece of code. <br>
If you need to understand networking protocol. Read the source, it is exceptionnally well written. <br>
If you like reading IETF RFCs you will enjoy studying this code. (You'll save tons of sleeping pills ;-) )<br>

Kudos to <a href=http://mc36.nop.hu/cv.html>Csaba MATE</a> then... all credits goes to him ! <br>

