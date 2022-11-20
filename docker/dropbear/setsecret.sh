#!/bin/bash
flyctl secrets set WG_CONFIG="$(cat wg0.conf|base64|tr -d '\n')"
