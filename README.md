# STUN-TURN in Docker optimized for Unraid
This is a Basic STUN & TURN server that was mainly created for Nextcloud Talk.

It is fully automated and will create all the necessary files and passwords so that the server can sucessfully start and run.

Please read all the discriptions from the Variables carefully and also look at the 'Show more settings' tab.

**ATTENTION:** Please ignore the socket errors after the server startup if you don't have IPv6 enabled on your server.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for configfiles and the application | /stun-turn |
| PORT | If you change this variable you have to create two new port forwardings with the corresponding ports one for TCP and one for UDP. | 5349 |
| SECRET | Create your own secret and enter it here or leave empty and the server creats a secret that is stored into 'secret.txt' in the main directory of the container (generate it for example in a linux terminal with the command 'openssl rand -hex 32' without quotes). | YOURSECRET |
| REALM | Your hostname (eg: 'example.org' without quotes). | yourdomain.org |
| CERT_FILE | Name of the certification file (leave empty if the server should create one or replace it with your own). | empty |
| PRIVKEY_FILE | Name of the private key file (leave empty if the server should create one or replace it with your own). | empty |
| DH_FILE | Name of the Diffie–Hellman key file (leave empty if the server should create one or replace it with your own - also plase look under the 'Show more settings' tab if you want to generate a bigger or smaller key default is: 2048). | empty |
| DISPLAY_SECRETS | Display your secrets in the log (set to 'true' or leave empty to disable it). | true |
| CA_COUNTRY | Country code for your certificate if the server should create one (two letters eg: 'US' without quotes - also plase look under the 'Show more settings' tab there are more settings for generating your certificate). | US |
| EXTRA_PARAMS | Here you can enter your Extra Startup Parameters if needed (you can get a full list of commands from here: https://github.com/coturn/coturn/wiki/turnserver) | empty |
| TOTAL_QUOTA | Total allocations quota: global limit on concurrent allocations (only change if you know what you are doing). | 100 |
| MAX_BPS | Max bytes-per-second bandwidth a TURN session is allowed to handle (input and output network streams are treated separately). Anything above that limit will be dropped or temporary suppressed - within the available buffer limits (only change if you know what you are doing). | 0 |
| CIPHER_LIST | Allowed OpenSSL cipher list for TLS/DTLS connections (only change if you know what you are doing). | ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384 |
| CERT_LENGTH | Enter your preferred key length (the higher the value the longer it takes to generate the certificate). | 2048 |
| CERT_VALID_DAYS | Specify how long that the certificate should be valid in days. | 3650 |
| CA_STATE_PROV | Specify your state or province. | YOURPROV |
| CA_LOCALITY | Specify your locality. | YOURLOC |
| CA_ORGANIZATION | Specify your organiszation. | YOURORG |
| DH_LENGTH | User Identifier | 2048 |
| CLI_PASSWORD | Enter your CLI password or leave empty if you want that the server creates a random one (please note that you have to manually enable the console with the '--cli-port PORT' - PORT stands for your preferred port - in the Extra Startup Parameters and create the corresponding port). | empty |
| LISTENING_IP | Specify the listening port (only change if you know what you are doing). | 0.0.0.0 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value for new created files | 0000 |
| DATA_PERMS | Data permissions for config folder | 770 |

## Run example
```
docker run --name Stun-Turn-Server -d \
	-p 5349:5349 -p 5349:5349/udp \
	--env 'PORT=5349' \
	--env 'SECRET=YOURSECRET' \
	--env 'REALM=yourdomain.org' \
	--env 'CERT_FILE=' \
	--env 'PRIVKEY_FILE=' \
	--env 'DH_FILE=' \
	--env 'DISPLAY_SECRETS=true' \
	--env 'CA_COUNTRY=US' \
	--env 'TOTAL_QUOTA=100' \
	--env 'MAX_BPS=0' \
	--env 'CIPHER_LIST=ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384' \
	--env 'CERT_LENGTH=2048' \
	--env 'CERT_VALID_DAYS=3650' \
	--env 'CA_STATE_PROV=YOURPROV' \
	--env 'CA_LOCALITY=YOURLOC' \
	--env 'CA_ORGANIZATION=YOURORG' \
	--env 'DH_LENGTH=2048' \
	--env 'CLI_PASSWORD=' \
	--env 'LISTENING_IP=0.0.0.0' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=0000' \
	--env 'DATA_PERMS=770' \
	--volume /path/to/stun-turn:/stun-turn \
	ich777/stun-turn-server
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!
 
#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/