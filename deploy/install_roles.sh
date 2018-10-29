#!/usr/bin/env bash

cleanup() {
    exit_code=$?
    rm -f "${TEMPFILE}"
    exit $exit_code
}


TEMPFILE=$(mktemp /tmp/install_roles.XXXXXX)
trap "cleanup" INT TERM EXIT

if ls -l roles | grep ^l >/dev/null; then
    echo "**************************************************************************"
    echo "* At least one role is installed via symlink; skipping role installation *"
    echo "**************************************************************************"
    sleep 2
    exit 0
fi

if ! ansible-galaxy install -r requirements.yml 2>&1 | tee "${TEMPFILE}"; then
    exit 1
fi

if grep "WARNING" "${TEMPFILE}" >/dev/null 2>&1; then
    echo "Out of date package:" 1>&2
    grep "WARNING" "${TEMPFILE}"
    exit 1
fi
