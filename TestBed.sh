#!/bin/bash

# Install virtual switch and create bridge
sudo apt-get update
sudo apt-get install -y openvswitch-switch
BRIDGE=nfvbridge
sudo ovs-vsctl add-br $BRIDGE

# Install needed tools
sudo apt-get install -y vim net-tools iptables iproute2 iperf3 ethtool

# Add and enable TUNTAP interfaces
for i in {1..3}; do
  if sudo ip link show vport$i >/dev/null 2>&1; then
    echo "vport$i already exists"
  else
    sudo ip tuntap add mode tap vport$i
    sudo ip link set vport$i up
  fi
done

# Remove IP address from physical interface
sudo ip address flush dev eno1

# Enable bridge to get to the internet
sudo dhclient $BRIDGE

# Add interfaces to the bridge
sudo ovs-vsctl add-port $BRIDGE eno1
for i in {1..3}; do
  sudo ovs-vsctl add-port $BRIDGE vport$i
done

# Set virtual interface speeds with ethtool
for i in {1..3}; do
  sudo ethtool -s vport$i autoneg on speed 1000 duplex full
done

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
