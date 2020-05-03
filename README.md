# danie1k/x2go-thunderbird

[![Docker Hub Build Type](https://img.shields.io/docker/cloud/automated/danie1k/x2go-thunderbird)][1]
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/danie1k/x2go-thunderbird)][1]
[![MIT License](https://img.shields.io/github/license/danie1k/docker-x2go-thunderbird)][2]
[![Docker Hub](https://img.shields.io/badge/hub-x2go--thunderbird-660198.svg)][3]

Thunderbird + x2go server @ Debian + Openbox

Volumes:
* `/home/nonroot/.thunderbird`

Exposes port `22`.

x2go client base config:
* login: `nonroot`
* no password, use private ssh key from `/home/nonroot/.ssh/id_rsa`
* command to run Thunderbird: `/usr/bin/thunderbird --profile /home/nonroot/.thunderbird`

[1]: https://hub.docker.com/r/danie1k/x2go-thunderbird
[2]: https://github.com/danie1k/danie1k/docker-x2go-thunderbird/blob/master/LICENSE
[3]: https://hub.docker.com/r/danie1k/x2go-thunderbird/builds
