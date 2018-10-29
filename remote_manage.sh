#!/usr/bin/env bash

usage="Usage: $0 {production|vagrant|...} manage.py-arguments"
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

if test ${ENVIRONMENT} == "vagrant"; then
    PORT=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_port"]')
    HOST=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_host"]')
else
    PORT=22
    HOST=$(ansible-inventory  -i ${INVENTORY} --list | jq -r '.["webservers"]["hosts"][0]')
fi

SCRIPT_DIR=$(ansible \
    -i deploy/inventory/${ENVIRONMENT} \
    webservers \
    -e @deploy/environments/all/vars.yml \
    -e @deploy/environments/${ENVIRONMENT}/vars.yml \
    -m debug \
    -a "var=script_dir" | \
    sed -e 's/^.*SUCCESS => //' | \
    jq -r '.["script_dir"]' \
)

ssh -tt -p ${PORT} ${HOST} ${SCRIPT_DIR}/manage.sh "$@"
