#!/bin/bash
domain=$1

if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi


if [ -z "$domain" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

openssl req -newkey rsa:2048 -nodes -out temp/$domain.csr -keyout certs/$domain.key -subj "/CN=$domain/"
openssl ca -batch -config ca.conf -notext -in temp/$domain.csr -out certs/$domain.pem
rm ca/index && touch ca/index

key_file=$(cat certs/$domain.key)
crt_file=$(cat certs/$domain.pem)
ca_file=$(cat ca/ca.pem)

crt_save=/etc/certs/$domain.journal.crt
key_save=/etc/certs/$domain.journal.key
ca_save=/etc/certs/$domain.ca.crt

cat > certs/$domain.setup.sh <<E_O_F
#!/bin/bash
mkdir -p /etc/certs
cat > $crt_save <<EOF
$crt_file
EOF
cat > $key_save <<EOF
$key_file
EOF
cat > $ca_save <<EOF
$ca_file
EOF

sed -i.bak \\
    -e 's#ServerKeyFile=.*#ServerKeyFile=/etc/certs/$domain.journal.key#g' \\
    -e 's#ServerCertificateFile=.*#ServerCertificateFile=$crt_save#g' \\
    -e 's#TrustedCertificateFile=.*#TrustedCertificateFile=/etc/certs/$domain.ca.crt#g' \\
    /etc/systemd/journal-upload.conf

sed -i.bak \\
    -e 's#ServerKeyFile=.*#ServerKeyFile=/etc/certs/$domain.journal.key#g' \\
    -e 's#ServerCertificateFile=.*#ServerCertificateFile=$crt_save#g' \\
    -e 's#TrustedCertificateFile=.*#TrustedCertificateFile=/etc/certs/$domain.ca.crt#g' \\
    /etc/systemd/journal-remote.conf

E_O_F