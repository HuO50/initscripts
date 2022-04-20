#!/bin/bash 
#Set Default GATEWAY to host
#
#20191118  Songqiao Tao <joeytao@tencent.com>
#-delete routes of 192 and 172 if only the eth1 exists
#
#20191010  Songqiao Tao <joeytao@tencent.com>
#-modify to support dhcp
#
#20190715  Songqiao Tao <joeytao@tencent.com>
#-add route for new network segment:11.0.0.0/8, 30.0.0.0/8
#
#20111122  lynnsong <lynnsong@tencent.com>
#version 2.1
#-modify to support suse, tlinux and xen	
#
#TENCENT DME OS TEAM: tlinux 
#version: 2.0
############GET GATEWAY FROM CONFIG FILE##################

if [ -f /etc/SuSE-release ]; then
	dir=/etc/sysconfig/network
elif [ -f /etc/tencentos-release -o -f /etc/tlinux-release -o -f /etc/redhat-release ]; then
	dir=/etc/sysconfig/network-scripts
fi
eth0="${dir}/ifcfg-eth0"
if [ -f $eth0 ];then
    if [ ! -z "`grep dhcp $eth0`" ];then
        GATEWAY0=`cat /var/lib/dhclient/dhclient--eth0.lease|grep 'option routers'|tail -1|awk '{print $3}'|sed 's/;//g'`
    else
        GATEWAY0=`awk -F= '/GATEWAY/{print $2}' $eth0 | sed "s/[\',\"]//g"`
    fi
fi

eth1="${dir}/ifcfg-eth1"
if [ -f $eth1 ];then
    if [ ! -z "`grep dhcp $eth1`" ];then
        GATEWAY1=`cat /var/lib/dhclient/dhclient--eth1.lease|grep 'option routers'|tail -1|awk '{print $3}'|sed 's/;//g'`
    else
        GATEWAY1=`awk -F= '/GATEWAY/{print $2}'  $eth1 | sed "s/[\',\"]//g"`
    fi
fi

if [ "$GATEWAY1" != "" ]
then
    ############SET local network route#######################
    /sbin/route add -net 192.168.0.0/16 gw ${GATEWAY1} eth1
    /sbin/route add -net 172.16.0.0/12 gw ${GATEWAY1} eth1
    /sbin/route add -net 10.0.0.0/8 gw ${GATEWAY1} eth1
    /sbin/route add -net 100.64.0.0/10 gw ${GATEWAY1} eth1
    /sbin/route add -net 9.0.0.0/8 gw ${GATEWAY1} eth1
    /sbin/route add -net 11.0.0.0/8 gw ${GATEWAY1} eth1
    /sbin/route add -net 30.0.0.0/8 gw ${GATEWAY1} eth1
fi

############SET default gateway###########################
if [ "$GATEWAY0" != "" ]
then
    ip route del default > /dev/null 2>&1
    /sbin/route add default gw $GATEWAY0

elif [ "$GATEWAY1" != "" ]
then
    ip route del default > /dev/null 2>&1
    /sbin/route add default gw $GATEWAY1
    /sbin/route del -net 172.16.0.0/12 gw ${GATEWAY1} eth1
fi
