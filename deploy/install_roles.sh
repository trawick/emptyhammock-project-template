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
    echo "" 1>&2
    echo "Out of date packages:" 1>&2
    echo "" 1>&2
    grep "WARNING" "${TEMPFILE}" 1>&2
    echo "" 1>&2
    echo "Unless you have made local changes to the role, remove those directories" 1>&2
    echo "from ./deploy/roles and try again." 1>&2
    exit 1
fi
