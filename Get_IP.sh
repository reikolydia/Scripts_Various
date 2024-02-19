#!/bin/bash

Ipv4=$(wget "http://ipinfo.io/ip" -qO-)
Ipv6_get=$(wget "http://ip6.me/api" -qO- | cut -c6-)

Ipv6_corrected=${Ipv6_get::-44}

if [[ "$Ipv6_corrected" = "$Ipv4" ]]; then
    echo "Your IPv4 is: $Ipv4"
    echo "You do not have an IPv6 address at this time."
else
    echo "Your IPv4 is: $Ipv4"
    echo "Your IPv6 is: $Ipv6_corrected"
fi
