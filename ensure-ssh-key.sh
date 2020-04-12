#!/usr/bin/env bash

if [[ ! -f ${NONROOT_HOME}/.ssh/id_rsa ]]; then
    ssh-keygen -A

    mkdir -p ${NONROOT_HOME}/.ssh/
    chmod 700 ${NONROOT_HOME}/.ssh

    ssh-keygen -t rsa -b 4096 -f ${NONROOT_HOME}/.ssh/id_rsa -N '' -C "nonroot@x2go-thunderbird"
    chmod 400 ${NONROOT_HOME}/.ssh/*

    cat ${NONROOT_HOME}/.ssh/id_rsa.pub >> ${NONROOT_HOME}/.ssh/authorized_keys
    chown -R ${NONROOT_UID}:${NONROOT_GID} ${NONROOT_HOME}/.ssh
fi