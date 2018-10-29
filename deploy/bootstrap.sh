#!/usr/bin/env bash

ENVIRONMENT=production

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

read -s -p "root password on server: " ROOTPASS
echo ""

exec ansible-playbook \
    ${VAULT_ARGS} \
    $* \
    -i ${INVENTORY} \
    -e @environments/all/vars.yml \
    -e @environments/all/devs.yml \
    -e @environments/${ENVIRONMENT}/vars.yml \
    -e @environments/${ENVIRONMENT}/secrets.yml \
    -e ansible_ssh_user=root \
    -e ansible_ssh_pass=${ROOTPASS} \
    playbooks/bootstrap.yml
