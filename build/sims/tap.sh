#!/bin/sh

HOSTIP=`/sbin/ifconfig enp3s0 | gawk -- '/inet/{ print substr($2,6) }'`
HOSTNM=`/sbin/ifconfig enp3s0 | gawk -- '/inet/{ print substr($4,6) }'`
HOSTBR=`/sbin/ifconfig enp3s0 | gawk -- '/inet/{ print substr($3,7) }'`
HOSTGW=`/sbin/route -n | gawk -- '/^0.0.0.0/{ print $2 }' | head -n 1`

#
echo "Host Addr ${HOSTIP}"
echo "Netmask ${HOSTNM}"
echo "Broadcast ${HOSTBR}"
echo "Default GW ${HOSTGW}"
#
/usr/sbin/tunctl -t tap0 -u rich
/sbin/ifconfig tap0 up

#
# Now convert eth0 to a bridge and bridge it with the TAP interface
/sbin/brctl addbr br0
/sbin/brctl addif br0 enp3s0
/sbin/brctl setfd br0 0
/sbin/ifconfig enp3s0 0.0.0.0
/sbin/ifconfig br0 $HOSTIP netmask $HOSTNM broadcast $HOSTBR up
# set the default route to the br0 interface
/sbin/route add -net 0.0.0.0/0 gw $HOSTGW
# bridge in the tap device
/sbin/brctl addif br0 tap0
/sbin/ifconfig tap0 0.0.0.0
echo "nameserver $HOSTGW" `>>/etc/resolv.conf`
