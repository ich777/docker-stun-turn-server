#!/bin/bash
echo "---Checking if secret is specified---"
if [ "${SECRET}" == "" ]; then
	echo "---No secret specified searching for existing...---"
	if [ ! -f ${DATA_DIR}/secret.txt ]; then
		echo "---No secret found, creating---"
		touch ${DATA_DIR}/secret.txt
		openssl rand -hex 32 >> ${DATA_DIR}/secret.txt
		SECRET="$(head ${DATA_DIR}/secret.txt)"
	else
		echo "---Secret found!---"
		SECRET="$(head ${DATA_DIR}/secret.txt)"
	fi
else
	echo "---Secret manually specified, continuing---"
fi

echo "---Checking if CLI password is specified---"
if [ -z "${CLI_PASSWORD}" ]; then
	echo "---No CLI password found, creating---"
	CLI_PASSWORD="$(</dev/urandom tr -dc '12345@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c20; echo "")"
else
	echo "---CLI password manually specified, continuing---"
fi

echo "---Checking if certificate is in place---"
if [ ! -f ${DATA_DIR}/${CERT_FILE} ]; then
	echo "---No certificate found, creating---"
	openssl req -newkey rsa:${CERT_LENGTH} -new -nodes -x509 -days ${CERT_VALID_DAYS} -subj "/C=${CA_COUNTRY}/ST=${CA_STATE_PROV}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/CN=${REALM}" -keyout ${DATA_DIR}/${PRIVKEY_FILE} -out ${DATA_DIR}/${CERT_FILE}
else
	echo "---Certificate found, continuing---"
fi

echo "---Checking if private key is in place---"
if [ ! -f ${DATA_DIR}/${PRIVKEY_FILE} ]; then
	echo "---No private key found, creating---"
	openssl req -newkey rsa:${CERT_LENGTH} -new -nodes -x509 -days ${CERT_VALID_DAYS} -subj "/C=${CA_COUNTRY}/ST=${CA_STATE_PROV}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/CN=${REALM}" -keyout ${DATA_DIR}/${PRIVKEY_FILE} -out ${DATA_DIR}/${CERT_FILE}
else
	echo "---Private key found, continuing---"
fi

echo "---Checking if Diffie–Hellman key file is in place---"
if [ ! -f ${DATA_DIR}/${DH_FILE} ]; then
	echo "---No Diffie–Hellman key file found, creating---"
	openssl dhparam -out ${DATA_DIR}/${DH_FILE} ${DH_LENGTH}
else
	echo "---Diffie–Hellman key file found, continuing---"
fi

echo "---Preparing server---"
chmod -R ${DATA_PERM} ${DATA_DIR}

if [ "${DISPLAY_SECRETS}" == "true" ]; then
	echo "----------------------------------------------------------------------------------------"
	echo
	echo "AUTH-Secret: ${SECRET}"
	echo "CLI-Password: ${CLI_PASSWORD}"
	echo
	echo "----------------------------------------------------------------------------------------"
    sleep 10
fi

echo "---Starting Server---"
turnserver --tls-listening-port ${PORT} \
	--fingerprint \
	--use-auth-secret \
	--static-auth-secret ${SECRET} \
	--realm ${REALM} \
	--total-quota ${TOTAL_QUOTA} \
	--max-bps ${MAX_BPS} \
	--stale-nonce \
	--cert ${DATA_DIR}/${CERT_FILE} \
	--pkey ${DATA_DIR}/${PRIVKEY_FILE} \
	--cipher-list ${CIPHER_LIST} \
	--no-multicast-peers \
	--dh-file ${DATA_DIR}/${DH_FILE} \
	--no-tlsv1 \
	--no-tlsv1_1 \
	--userdb ${DATA_DIR}/database.sql \
	--listening-ip ${LISTENING_IP} \
	--cli-password=${CLI_PASSWORD} \
	${EXTRA_PARAMS}