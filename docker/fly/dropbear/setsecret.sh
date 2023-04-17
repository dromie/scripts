#!/bin/bash
#flyctl secrets set WG_CONFIG="$(cat wg0.conf|base64|tr -d '\n')"
DNSMASQ_CONFIG="$(tar cz -C secrets dnsmasq.d|base64|tr -d '\n')"
WG_CONFIG="$(cat secrets/wg0.conf|base64|tr -d '\n')"

flyctl secrets set WG_CONFIG="$WG_CONFIG" DNSMASQ_CONFIG="$DNSMASQ_CONFIG"
