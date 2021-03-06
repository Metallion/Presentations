#!/bin/bash
set -ue

. 00_base.sh

cat <<EOS
*****************************************************************
* Setting up OpenVNet virtual network: Two networks with router *
*****************************************************************
EOS

vnctl networks add --uuid "nw-vnet1" --display_name "vnet1" --ipv4_network "10.101.0.0" --ipv4_prefix "24" --domain_name "vnet1" --network_mode "virtual"
vnctl networks add --uuid "nw-vnet2" --display_name "vnet2" --ipv4_network "192.168.100.0" --ipv4_prefix "24" --domain_name "vnet2" --network_mode "virtual"

vnctl datapaths networks add dp-1 "nw-vnet1" --interface_uuid "if-dp1eth0" --mac_address "02:00:00:aa:00:01"
vnctl datapaths networks add dp-2 "nw-vnet1" --interface_uuid "if-dp2eth0" --mac_address "02:00:00:bb:00:01"
vnctl datapaths networks add dp-3 "nw-vnet1" --interface_uuid "if-dp3eth0" --mac_address "02:00:00:cc:00:01"

vnctl datapaths networks add dp-1 "nw-vnet2" --interface_uuid "if-dp1eth0" --mac_address "02:00:00:aa:00:02"
vnctl datapaths networks add dp-2 "nw-vnet2" --interface_uuid "if-dp2eth0" --mac_address "02:00:00:bb:00:02"
vnctl datapaths networks add dp-3 "nw-vnet2" --interface_uuid "if-dp3eth0" --mac_address "02:00:00:cc:00:02"

vnctl interfaces add --uuid "if-v1" --port_name "if-v1" --network_uuid "nw-vnet1" --mac_address "02:00:00:00:00:01" --ipv4_address "10.101.0.11"
vnctl interfaces add --uuid "if-v3" --port_name "if-v3" --network_uuid "nw-vnet1" --mac_address "02:00:00:00:00:03" --ipv4_address "10.101.0.13"
vnctl interfaces add --uuid "if-v5" --port_name "if-v5" --network_uuid "nw-vnet1" --mac_address "02:00:00:00:00:05" --ipv4_address "10.101.0.15"

vnctl interfaces add --uuid "if-v2" --port_name "if-v2" --network_uuid "nw-vnet2" --mac_address "02:00:00:00:00:02" --ipv4_address "192.168.100.12"
vnctl interfaces add --uuid "if-v4" --port_name "if-v4" --network_uuid "nw-vnet2" --mac_address "02:00:00:00:00:04" --ipv4_address "192.168.100.14"
vnctl interfaces add --uuid "if-v6" --port_name "if-v6" --network_uuid "nw-vnet2" --mac_address "02:00:00:00:00:06" --ipv4_address "192.168.100.16"

# DHCP services
vnctl interfaces add --uuid "if-dhcp1" --network_uuid "nw-vnet1" --mac_address "02:00:00:00:01:01" --ipv4_address "10.101.0.2" --mode "simulated"
vnctl network_services add --uuid "ns-dhcp1" --interface_uuid "if-dhcp1" --mode "dhcp"

vnctl interfaces add --uuid "if-dhcp2" --network_uuid "nw-vnet2" --mac_address "02:00:00:00:01:02" --ipv4_address "192.168.100.2" --mode "simulated"
vnctl network_services add --uuid "ns-dhcp2" --interface_uuid "if-dhcp2" --mode "dhcp"

# Router
vnctl interfaces add --uuid "if-router1" --network_uuid "nw-vnet1" --mac_address "02:00:00:00:02:01" --ipv4_address "10.101.0.1" --mode simulated --enable_routing true
vnctl interfaces add --uuid "if-router2" --network_uuid "nw-vnet2" --mac_address "02:00:00:00:02:02" --ipv4_address "192.168.100.1" --mode simulated --enable_routing true

vnctl route_links add --uuid "rl-1" --mac-address "02:00:10:00:00:01"

vnctl routes add --uuid "r-1" --interface-uuid "if-router1" --network-uuid "nw-vnet1" --ipv4-network "10.101.0.0" --route-link-uuid "rl-1"
vnctl routes add --uuid "r-2" --interface-uuid "if-router2" --network-uuid "nw-vnet2" --ipv4-network "192.168.100.0" --route-link-uuid "rl-1"

vnctl datapaths route_links add "dp-1" "rl-1" --interface_uuid "if-dp1eth0" --mac_address "02:00:10:aa:00:01"
vnctl datapaths route_links add "dp-2" "rl-1" --interface_uuid "if-dp2eth0" --mac_address "02:00:10:bb:00:01"
vnctl datapaths route_links add "dp-3" "rl-1" --interface_uuid "if-dp3eth0" --mac_address "02:00:10:cc:00:01"

cat <<EOS
**********************************************************************
* DONE setting up OpenVNet virtual network: two networks with router *
**********************************************************************
EOS
