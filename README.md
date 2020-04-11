# danie1k/x2go-thunderbird
Thunderbird + x2go server @ Debian + Openbox

Includes two volumes:
* `/home/docker/.ssh`
* `/thunderbird-profile`

Exposes port `22`.

x2go client base config:
* login: `docker`
* no password, use private ssh key from `/home/docker/.ssh/id_rsa`
* command to run Thunderbird: `/usr/local/bin/thunderbird`
