#!/usr/bin/env bash

#!/bin/bash

find ${THUNDERBIRD_PROFILE_PATH} -name "*.sqlite" -exec sh -c 'echo "$0"; sqlite3 "$0" vacuum; sqlite3 "$0" reindex' {} \;
