#!/bin/sh

# Crea interfaccia di rete tap0
tunctl -g netdev -t tap0
ifconfig tap0 200.0.0.1
ifconfig tap0 netmask 255.255.255.252
ifconfig tap0 broadcast 200.0.0.3
ifconfig tap0 up

# Crea regole di firewalling (cambiare wlp6s0 => enp0s5 con il nome della propria scheda di rete)
iptables -t nat -F
iptables -t nat -X
iptables -F
iptables -X
iptables -t nat -A POSTROUTING -o enp0s5 -j MASQUERADE
iptables -A FORWARD -i tap0 -j ACCEPT

# Abilita il forwarding su host locale 
sysctl -w net.ipv4.ip_forward=1

# Aggiunge le rotte alle varie subnets (DA AGGIUNGERE SOLO PER TESTARE LA VOSTRA RETE
route add -net 10.0.0.0/20 gw 200.0.0.2 dev tap0


