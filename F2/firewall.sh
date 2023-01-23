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

iptables -N alldmz
iptables -N dmzall

## Aggiungo le nuove catene

iptables -A FORWARD -i eth0 -o eth1 -j alldmz
iptables -A FORWARD -i eth1 -o eth0 -j dmzall

## Regole

# Da all (internet,red,green) a dmz

iptables -A alldmz ! -d 10.0.0.0/22 -j DROP
iptables -A alldmz -p tcp -d 10.0.0.0/22 --dport 53 -j ACCEPT #porta dns
iptables -A alldmz -p tcp -d 10.0.0.0/22 --dport 25 -j ACCEPT #porta smtp
iptables -A alldmz -p tcp -d 10.0.0.0/22 --dport 21 -j ACCEPT #porta ftp
iptables -A alldmz -p tcp -d 10.0.2.2 --dport 80 -j ACCEPT #porta http
iptables -A alldmz -p tcp -d 10.0.0.2 --dport 23 -j ACCEPT #porta telnet
iptables -A alldmz -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# da dmz ad all

iptables -A dmzall ! -s 10.0.0.0/22 -j DROP
iptables -A dmzall -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT #le nuove connessioni verrano accettate solo per l'area red perchè l'altro firewall bloccherà il resto


