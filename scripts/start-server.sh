#!/bin/bash
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

echo "---Checking if external IP is specified---"
if [ ! -z "${EXTERNAL_IP}" ]; then
	echo "---Setting external IP to: ${EXTERNAL_IP}---"
	EXTERNAL_IP="--external-ip ${EXTERNAL_IP}"
else
	echo "---No external IP set---"
fi

echo "---Checking if Static AUTH is set---"
if [ "${STATIC_AUTH}" != "true" ]; then
	echo "---Database AUTH instead of Static AUTH enabled---"
	echo "---Please don't forget to set your users in the---"
	echo "---database: /stun-turn/database.sql -------------"
	AUTHENTICATION="--lt-cred-mech \
	--userdb ${DATA_DIR}/database.sql"
else
	echo "---Static AUTH is set!---"
	echo "---Checking if secret is specified---"
	if [ -z "${SECRET}" ]; then
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
	AUTHENTICATION="	--use-auth-secret \
	--static-auth-secret ${SECRET}"
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
fi

echo "---Starting Server---"
echo
echo "-------------------------------------------------------------------------------------------------"
echo "---Please ignore the following socket errors if you don't have configured IPv6 on your server!---"
echo "-------------------------------------------------------------------------------------------------"
echo
turnserver --tls-listening-port ${PORT} \
	--fingerprint \
	${AUTHENTICATION} \
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
	--listening-ip ${LISTENING_IP} \
	--cli-password=${CLI_PASSWORD} \
	${EXTERNAL_IP} \
	${EXTRA_PARAMS}