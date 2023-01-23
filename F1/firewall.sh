#!/bin/sh

## Reset catene

iptables -F
iptables -X

iptables -t nat -F
iptables -t nat -X

## Policy default

iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

## Creo catene

iptables -N inetgreen
iptables -N inetall
iptables -N greenall
iptables -N greeninet
iptables -N allgreen
iptables -N allinet

## Aggiungo le nuove catene

iptables -A FORWARD -i eth0 -o eth1 -j inetgreen
iptables -A FORWARD -i eth0 -o eth2 -j inetall
iptables -A FORWARD -i eth1 -o eth0 -j greeninet
iptables -A FORWARD -i eth1 -o eth2 -j greenall
iptables -A FORWARD -i eth2 -o eth0 -j allinet
iptables -A FORWARD -i eth2 -o eth1 -j allgreen

## Regole

# Da internet a green
iptables -A inetgreen ! -d 10.0.8.0/24 -j DROP
iptables -A inetgreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# Da internet ad all (red e dmz)
iptables -A inetall ! -d 10.0.0.0/22 -j DROP # accetta solo per l'area dmz
iptables -A inetall -p tcp --dport 53 -j ACCEPT #porta dns
iptables -A inetall -p tcp --dport 25 -j ACCEPT #porta smtp
iptables -A inetall -p tcp --dport 21 -j ACCEPT #porta ftp
iptables -A inetall -p tcp -d 10.0.2.2 --dport 80 -j ACCEPT #porta http
iptables -A inetall -p tcp -d 10.0.0.2 --dport 23 -j ACCEPT #porta telnet
iptables -A inetall -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Da green a internet
iptables -A greeninet ! -s 10.0.8.0/24 -j DROP
iptables -A greeninet -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Da green ad all
iptables -A greenall ! -s 10.0.8.0/24 -j DROP
iptables -A greenall ! -d 10.0.0.0/21 -j DROP #supernet Red+DMZ
iptables -A greenall -p tcp -d 10.0.0.0/22 --dport 53 -j ACCEPT
iptables -A greenall -p tcp -d 10.0.0.0/22 --dport 25 -j ACCEPT
iptables -A greenall -p tcp -d 10.0.0.0/22 --dport 21 -j ACCEPT
iptables -A greenall -p tcp -d 10.0.2.2 --dport 80 -j ACCEPT
iptables -A greenall -p tcp -d 10.0.0.2 --dport 23 -j ACCEPT
iptables -A greenall -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Da all ad internet

iptables -A allinet ! -s 10.0.0.0/22 -j DROP
iptables -A allinet -m state --state ESTABLISHED,RELATED -j ACCEPT

# Da all a green

iptables -A allgreen ! -d 10.0.8.0/24 -j DROP
iptables -A allgreen ! -s 10.0.0.0/21 -j DROP
iptables -A allgreen -m state --state ESTABLISHED,RELATED -j ACCEPT
