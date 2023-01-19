#!/bin/sh

iflag=false
rflag=false
FREERTR_INTF_LIST=""
FREERTR_HOSTNAME=""
FREERTR_BASE_DIR=$(pwd)

usage(){
        echo "Usage: `basename $0` -i <intf/port1/port2> -r <freertr-hostname> -h for help";
        echo "Example: $0 -i \"eth0/22705/22706 eth1/20010/20011\" -r freertr"
        exit 1
}

bindintf () {
 echo "bindintf: FREERTR_INTF_LIST=$FREERTR_INTF_LIST";
  FREERTR_INTF_LIST=$(echo $1 | tr -d '\"');
  ip link add veth0a type veth peer name veth0b

  export TOE_OPTIONS="rx tx sg tso ufo gso gro lro rxvlan txvlan rxhash"

  for VETH in veth0a veth0b; do
    ip link set dev $VETH up mtu 10240 promisc on
    for TOE_OPTION in $TOE_OPTIONS; do
      /sbin/ethtool --offload $VETH "$TOE_OPTION" off &> /dev/null
    done
  done

 DPDK_PORTS=$(dpdk-devbind.py -s 2> /dev/null | sed -n '/Network devices using DPDK-compatible driver/,/Network devices using kernel driver/p' | wc -l)
 export CPU_PORTS=$(($DPDK_PORTS - 4))

}

start_freertr () {
  FREERTR_BASE_DIR=$1
  FREERTR_HOSTNAME=$2
  cd "${FREERTR_BASE_DIR}/run"
  java -jar "${FREERTR_BASE_DIR}/bin/rtr.jar" routercs "${FREERTR_BASE_DIR}/run/${FREERTR_HOSTNAME}-hw.txt" "${FREERTR_BASE_DIR}/run/${FREERTR_HOSTNAME}-sw.txt"
}



if ( ! getopts ":hi:r:" opt); then
        usage
        exit $E_OPTERROR;
fi

while getopts ":hi:r:" opt;do
case $opt in
  i)
    FREERTR_INTF_LIST=$OPTARG
    echo "FREERTR_INTF_LIST: $FREERTR_INTF_LIST";
    iflag=true
  ;;
  r)
    FREERTR_HOSTNAME=$OPTARG
    echo "FREERTR_HOSTNAME: $FREERTR_HOSTNAME";
    rflag=true
  ;;
  \?)
     echo "Option not supported." >&2
     usage
     exit 1
  ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    usage
    exit 1
  ;;
  h|*)
   usage
   exit 1
  ;;
  esac
done

if $iflag && $rflag ;
then
   bindintf "${FREERTR_INTF_LIST}" "${FREERTR_BASE_DIR}"
   start_freertr "${FREERTR_BASE_DIR}" ${FREERTR_HOSTNAME}
else
   if ! $iflag; then echo "[-i] freertr interface list missing"
   usage
   fi
   if ! $rflag; then echo "[-r] router hostname missing"
   usage
   fi
fi
