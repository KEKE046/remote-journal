# Remote Journal Setup

Setup remote journal for better system audit

## On your own computer (or a vault computer)

Create CA file:

```bash
./script/create-ca.sh "KEKE's CA Authority"
```

Generate config for each server:

```bash
./script/sign.sh server.keke.ai
```

This command will generate a auto configure script in `certs` directory.

```bash
#!/bin/bash
mkdir -p /etc/certs
cat > /etc/certs/xxx.crt <<EOF
xxxxxx
EOF
cat > /etc/certs/xxx.key <<EOF
xxxxxx
EOF
cat > /etc/certs/xxx.ca.crt <<EOF
xxxxxx
EOF

sed -i.bak \
    -e 's#ServerKeyFile=.*#ServerKeyFile=/etc/certs/xxx.journal.key#g' \
    -e 's#ServerCertificateFile=.*#ServerCertificateFile=/etc/certs/xxx.journal.crt#g' \
    -e 's#TrustedCertificateFile=.*#TrustedCertificateFile=/etc/certs/xxx.ca.crt#g' \
    /etc/systemd/journal-upload.conf

sed -i.bak \
    -e 's#ServerKeyFile=.*#ServerKeyFile=/etc/certs/xxx.journal.key#g' \
    -e 's#ServerCertificateFile=.*#ServerCertificateFile=/etc/certs/xxx.journal.crt#g' \
    -e 's#TrustedCertificateFile=.*#TrustedCertificateFile=/etc/certs/xxx.ca.crt#g' \
    /etc/systemd/journal-remote.conf
```

## On the remote computer

First install systemd-journal-remote

```bash
apt install systemd-journal-remote
```

Then, copy and paste the auto configure script:

```bash
cat | bash
```

### Setup journal server

Change file owner and permissions:

```bash
chown systemd-journal-remote:systemd-journal-remote /etc/certs/*
chmod o-r /etc/certs/*
```

Edit `journal-remote.conf`, remove comments:

```bash
vim /etc/systemd/journal-remote.conf
```

Start `systemd-journal-remote`:

```bash
systemctl start systemd-journal-remote
systemctl status systemd-journal-remote
systemctl enable systemd-journal-remote
```

### Setup journal client

Change file owner and permissions:

```bash
useradd -r systemd-journal-upload
chown systemd-journal-upload:systemd-journal-upload /etc/certs/*
chmod o-r /etc/certs/*
```

Edit `journal-upload.conf`, setup server address and remove comments:

```bash
vim /etc/systemd/journal-upload.conf
```

Start `systemd-journal-upload`

```bash
systemctl start systemd-journal-upload
systemctl status systemd-journal-upload
systemctl enable systemd-journal-upload
```