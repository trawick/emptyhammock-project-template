#!/usr/bin/env bash

usage="Usage: $0 {production|vagrant|...}"
if test $# -lt 1; then
    echo ${usage} 1>&2
    exit 1
fi

ENVIRONMENT=$1
shift

INVENTORY="deploy/inventory/${ENVIRONMENT}"

if ! test -f ${INVENTORY}; then
    echo "Environment \"${ENVIRONMENT}\" is not valid." 1>&2
    echo ${usage} 1>&2
    exit 1
fi

cd deploy

INVENTORY="inventory/${ENVIRONMENT}"

VAULT_PASS=../.vault_pass
if test -f ${VAULT_PASS}; then
    if test "$(stat -c "%a" ${VAULT_PASS})" != "600"; then
        echo "Permissions of ${VAULT_PASS} should be 600!" 1>&2
        exit 1
    fi
    VAULT_ARGS="--vault-password-file ${VAULT_PASS}"
else
    VAULT_ARGS=--ask-vault-pass
fi

if test ${ENVIRONMENT} == "vagrant"; then
    PORT=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_port"]')
    HOST=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_host"]')
else
    PORT=22
    HOST=$(ansible-inventory  -i ${INVENTORY} --list | jq -r '.["webservers"]["hosts"][0]')
fi

DUMPNAME=/tmp/project.sql.gz

if ! ssh -p ${PORT} ${HOST} sudo rm -f ${DUMPNAME}; then
    exit 1
fi

if ! ansible-playbook \
    ${VAULT_ARGS} \
    $* \
    -i ${INVENTORY} \
    -e @environments/all/vars.yml \
    -e @environments/all/devs.yml \
    -e @environments/${ENVIRONMENT}/vars.yml \
    -e @environments/${ENVIRONMENT}/secrets.yml \
    -e dumpname=${DUMPNAME} \
    playbooks/dump_db.yml; then
    exit 1
fi

scp -P ${PORT} ${HOST}:${DUMPNAME} ..

if ! ssh -p ${PORT} ${HOST} sudo rm -f ${DUMPNAME}; then
    exit 1
fi
