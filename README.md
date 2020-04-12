# danie1k/x2go-thunderbird
Thunderbird + x2go server @ Debian + Openbox

Volumes:
* `/home/nonroot/.thunderbird`

Exposes port `22`.

x2go client base config:
* login: `nonroot`
* no password, use private ssh key from `/home/nonroot/.ssh/id_rsa`
* command to run Thunderbird: `/home/nonroot/run-thunderbird`
