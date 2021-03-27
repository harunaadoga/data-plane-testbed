#!/bin/bash

#Install virtual switch and create bridge
sudo apt-get update
sudo apt-get install opensvswitch-switch
ovs-vsctl add-br nfvbridge

#install tools
sudo apt-get install vim net-tools iptable-services iproute iperf3 ethtool

#Add and enable TUNTAP interfaces
sudo ip tuntap add mode tap vport1
sudo ip tuntap add mode tap vport2
sudo ip tuntap add mode tap vport3

ifconfig vport1 up
ifconfig vport2 up
ifconfig vport3 up

sudo ifconfig eno1 0 #drop IP
sudo dhclient nfvbridge #for bridge to get to the internet

sudo ovs-vsctl add-port nfvbridge eno1 #replace eno1 with own interface

sudo ovs-vsctl add-port nfvbridge vport1
sudo ovs-vsctl add-port nfvbridge vport2
sudo ovs-vsctl add-port nfvbridge vport3

#Set virtual interface speeds with ethtool
sudo ethtool -s vport1 autoneg on speed 1000 duplex full
sudo ethtool -s vport2 autoneg on speed 1000 duplex full
sudo ethtool -s vport3 autoneg on speed 1000 duplex full

echo 1 > /proc/sys/net/ipv4/ip_forward #enable ip forwarding










