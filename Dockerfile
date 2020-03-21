FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends coturn openssl && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/stun-turn"
ENV PORT=5349
ENV SECRET=""
ENV REALM="example.com"
EVN TOTAL_QUOTA=100
EVN MAX_BPS=0
ENV CIPHER_LIST="ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384"
ENV CERT_FILE="cert.pem"
ENV PRIVKEY_FILE="privkey.pem"
ENV CERT_LENGTH=2048
ENV CERT_VALID_DAYS=3650
ENV CA_COUNTRY="US"
ENV CA_STATE_PROV="None"
ENV CA_LOCALITY="None"
ENV CA_ORGANIZATION="None"
ENV DH_FILE="dhparam.pem"
ENV DH_LENGTH=2048
ENV CLI_PASSWORD=""
ENV EXTRA_PARAMS=""
ENV DISPLAY_SECRETS="true"
ENV LISTENING_IP="0.0.0.0"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="stun-turn"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]