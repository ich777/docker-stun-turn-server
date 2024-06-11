FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-stun-turn-server"

RUN apt-get update && \
	apt-get -y install --no-install-recommends coturn openssl && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/stun-turn"
ENV PORT=5349
ENV STATIC_AUTH="true"
ENV SECRET=""
ENV REALM="example.com"
ENV TOTAL_QUOTA=100
ENV MAX_BPS=0
ENV CIPHER_LIST="ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384"
ENV CERT_FILE="cert.pem"
ENV PRIVKEY_FILE="privkey.pem"
ENV CERT_LENGTH=2048
ENV CERT_VALID_DAYS=3650
ENV CA_COUNTRY="US"
ENV CA_STATE_PROV=""
ENV CA_LOCALITY=""
ENV CA_ORGANIZATION=""
ENV DH_FILE="dhparam.pem"
ENV DH_LENGTH=2048
ENV CLI_PASSWORD=""
ENV EXTRA_PARAMS=""
ENV DISPLAY_SECRETS="true"
ENV LISTENING_IP="0.0.0.0"
ENV EXTERNAL_IP=""
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

EXPOSE 5349
EXPOSE 5349/udp

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]