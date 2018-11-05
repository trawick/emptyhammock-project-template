#!/usr/bin/env bash

ENVIRONMENT="$1"
shift

if test -z ${ENVIRONMENT}; then
    echo "Specify environment (\"vagrant\", \"staging\", etc.) as the first argument" 1>&2
    exit 1
fi

if ! test -d deploy/environments/${ENVIRONMENT}; then
    echo "\"${ENVIRONMENT}\" is not a valid environment" 1>&2
    exit 1
fi

USER="$1"
shift

if test -z ${USER}; then
    echo "Specify user (\"root\", \"ubuntu\", etc.) as the second argument" 1>&2
    exit 1
fi

PRIVATE_KEY="$1"
shift

if ! test -z ${PRIVATE_KEY}; then
    PRIVATE_KEY_ARGS="-e ansible_ssh_private_key_file=${PRIVATE_KEY}"
    USER_PASS_ARGS=""
else
    PRIVATE_KEY_ARGS=""
    read -s -p "${USER} password on server: " USERPASS
    echo ""
    USER_PASS_ARGS="-e ansible_ssh_pass=${USERPASS}"
fi

cd deploy

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

INVENTORY="inventory/${ENVIRONMENT}"

exec ansible-playbook \
    ${VAULT_ARGS} \
    $* \
    -i ${INVENTORY} \
    -e @environments/all/vars.yml \
    -e @environments/all/devs.yml \
    -e @environments/${ENVIRONMENT}/vars.yml \
    -e @environments/${ENVIRONMENT}/secrets.yml \
    -e ansible_ssh_user=${USER} \
    ${USER_PASS_ARGS} \
    ${PRIVATE_KEY_ARGS} \
    playbooks/bootstrap.yml
