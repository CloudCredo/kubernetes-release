#!/bin/bash

# Adapted from https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md

ADDRS=$@
if [ -z "${ADDRS}" ]; then
  echo 'Usage: ./generate-certificates.sh $(prips 10.9.30.128/25)'
  exit 1
fi

which cfssl > /dev/null 2>&1 || {
  echo 'Aborted. Please install cfssl by following https://github.com/cloudflare/cfssl#installation' 1>&2
  exit 1
}

which cfssljson > /dev/null 2>&1 || {
  echo 'Aborted. Please install cfssljson by following https://github.com/cloudflare/cfssl#installation' 1>&2
  exit 1
}

# Create the CA configuration file
cat << EOF > ca-config.json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

# Generate the CA certificate and private key
cat << EOF > ca-csr.json
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

# Generate the CA certificate and private key
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Generate the single Kubernetes TLS Cert
cat << EOF > kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
$(for ADDR in $ADDRS; do
  echo "    \"$ADDR\","
done)
    "kubernetes.default.svc.cluster.local",
    "kubernetes.default.svc",
    "127.0.0.1",
    "10.0.0.1"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Cluster",
      "ST": "Oregon"
    }
  ]
}
EOF

# Generate the Kubernetes certificate and private key
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
