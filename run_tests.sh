#!/bin/sh
set -ex

MIN_COVERAGE=75

PROJECT=`ls */settings/dev.py | sed -e 's/\/.*$//'`

if test "$1" = "--new-db"; then
    DB_ACTION=""
    shift
else
    DB_ACTION="--keepdb"
fi

flake8 .

rm -f .coverage
coverage run manage.py test ${DB_ACTION} --noinput --settings=${PROJECT}.settings.dev "$@"
if ! coverage report --fail-under ${MIN_COVERAGE}; then
    echo 'FAILED!' 1>&2
    exit 1
fi

# Fail if any migrations need to be generated.
if ! python manage.py makemigrations --dry-run --noinput --settings=${PROJECT}.settings.dev | grep -q 'No changes detected'; then
    echo 'Migrations need to be generated.  Run "./manage.py makemigrations --dry-run"' 1>&2
    exit 1
fi
