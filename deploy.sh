#!/usr/bin/env bash

usage="Usage: $0 {production|vagrant|...} [ansible-options]"
if test $# -lt 1; then
    echo ${usage} 1>&2
    exit 1
fi

ENVIRONMENT=$1
shift

cd deploy

if ! ./install_roles.sh; then
    exit 1
fi

INVENTORY="inventory/${ENVIRONMENT}"

if ! test -f ${INVENTORY}; then
    echo "Environment \"${ENVIRONMENT}\" is not valid." 1>&2
    echo ${usage} 1>&2
    exit 1
fi

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

if ! ansible-playbook \
    ${VAULT_ARGS} \
    $* \
    -i ${INVENTORY} \
    -e @environments/all/vars.yml \
    -e @environments/all/devs.yml \
    -e @environments/${ENVIRONMENT}/vars.yml \
    -e @environments/${ENVIRONMENT}/secrets.yml \
    playbooks/deploy.yml; then
    exit 1
fi

if test -f ./test_deploy.py; then
    export TESTED_ENVIRONMENT=${ENVIRONMENT}
    exec ./test_deploy.py
fi
