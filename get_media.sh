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

if test ${ENVIRONMENT} == "vagrant"; then
    PORT=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_port"]')
    HOST=$(ansible-inventory -i ${INVENTORY} --list | jq -r '.["_meta"]["hostvars"]["default"]["ansible_ssh_host"]')
else
    PORT=22
    HOST=$(ansible-inventory  -i ${INVENTORY} --list | jq -r '.["webservers"]["hosts"][0]')
fi

if test -z "${HOST}"; then
    echo "HOST wasn't found.  Is ansible-inventory in PATH?" 1>&2
    exit 1
fi

cd ..

MEDIA_DIR=$(ansible \
    -i deploy/inventory/${ENVIRONMENT} \
    webservers \
    -e @deploy/environments/all/vars.yml \
    -e @deploy/environments/${ENVIRONMENT}/vars.yml \
    -m debug \
    -a "var=media_dir" | \
    sed -e 's/^.*SUCCESS => //' | \
    jq -r '.["media_dir"]' \
)

# Ensure MEDIA_DIR has trailing slash (fun with rsync!)
case "${MEDIA_DIR}" in
    */)
        ;;
    *)
        MEDIA_DIR=${MEDIA_DIR}/
        ;;
esac

mkdir -p ./media/
if ! rsync -arvz -delete -e "ssh -p ${PORT}" ${HOST}:${MEDIA_DIR} ./media/; then
    exit 1
fi
