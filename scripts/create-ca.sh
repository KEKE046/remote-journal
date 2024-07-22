#!/bin/bash

cn=$1

if [ -z "$cn" ]; then
    echo "Usage: $0 <common-name>"
    exit 1
fi

openssl req -newkey rsa:2048 -days 3650 -x509 -nodes \
    -out ca/ca.pem -keyout ca/ca.key -subj "/CN=$cn/"
cat > ca.conf <<EOF
[ ca ]
default_ca    = this
[ this ]
new_certs_dir = ./temp
certificate   = ./ca/ca.pem
database      = ./ca/index
private_key   = ./ca/ca.key
serial        = ./ca/serial
default_days  = 3650
default_md    = default
policy        = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
EOF
touch ca/index
echo 0001 > ca/serial
