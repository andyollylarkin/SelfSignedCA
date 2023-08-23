#!/usr/bin/env bash

set -e


DAYS=3000;
CA_KEY_PATH=./rootCA.key;
CA_CRT_PATH=./rootCA.crt;

if [[ $1 == "-h" ]]; then
	echo -e "Usage:\n genca <ca_key_pass>\n" \
	"gencert <ca_cert_path> <ca_key_path> <ca_cert_password> <domain_name>";
	exit 0;
fi

if [ "$#" -lt 2 ]; then
	echo $#
	echo -e "Usage:\n genca <ca_key_pass>\n" \
	"gencert <ca_cert_path> <ca_key_path> <ca_cert_password> <domain_name>";
	exit 1;
fi

if [[ $1 == "genca" && $2 == "" ]]; then
	echo "Invalid usage. Please provide password for CA key!";
	exit 1;
fi

if [[ $1 == "gencert" && $# > 5 ]]; then
	echo "Invalid usage. Please provide <ca_cert_path> <ca_key_path> <ca_cert_password> <domain_name>!";
	exit 1;
fi

if [[ $1 == "genca" ]]; then
	echo "Generate root CA key ...";
	openssl genrsa -des3 -out $CA_KEY_PATH -passout pass:$2 2048;
	echo "Generate root CA certificate ...";
	openssl req -x509 -new -nodes -key $CA_KEY_PATH -sha256 -days $DAYS -out $CA_CRT_PATH -passin pass:$2 -config ./root.cnf;
	exit 0;
fi

if [[ $1 == "gencert" ]]; then
	CA_CERT="$2";
	CA_KEY="$3";
	CA_PASS="$4";
	OUT_FILE_NAME="$5";

	echo "Generate client key ...";
	openssl genrsa -out "${OUT_FILE_NAME}.key" 2048;

	echo "Generate client csr ...";
	openssl req -new -key "${OUT_FILE_NAME}.key" -out "${OUT_FILE_NAME}.csr" -config client.cnf;

	echo "Generate client certificate ...";
	openssl x509 -req -in ${OUT_FILE_NAME}.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out "${OUT_FILE_NAME}.crt" -days \
	$DAYS -sha256 -extfile client.cnf -passin pass:$CA_PASS;

	echo "Done.";
	exit 0;
fi
