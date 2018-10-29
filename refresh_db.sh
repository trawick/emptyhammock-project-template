#!/usr/bin/env bash

. .env

ENVIRONMENT=production
PROJECT_NAME=$(ansible \
    -i deploy/inventory/${ENVIRONMENT} \
    webservers \
    -e @deploy/environments/all/vars.yml \
    -e @deploy/environments/${ENVIRONMENT}/vars.yml \
    -m debug \
    -a "var=project_name" | \
    sed -e 's/^.*SUCCESS => //' | \
    jq -r '.["project_name"]' \
)

# defaults should match those in <projectname>.settings.base
export PGUSER=${DB_USER:-${PROJECT_NAME}}
export PGPASSWORD=${DB_PASSWORD:-${PROJECT_NAME}}
export PGHOST=${DB_HOST:-localhost}
export PGPORT=${DB_PORT:-5432}

if ! dropdb --if-exists ${PROJECT_NAME}; then
    exit 1
fi

if ! createdb -E UTF-8 ${PROJECT_NAME}; then
    exit 1
fi

if ! zcat project.sql.gz | psql ${PROJECT_NAME}; then
    exit 1
fi
