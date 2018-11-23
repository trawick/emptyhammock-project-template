# myproject

# Table of Contents

1. [Using the template for your project](docs/your_project.md)
1. [Overview](#overview)
1. [Deviations from project template](#project-deviations)
1. [Project-specific details](#project-specific-details)
1. [Creating virtual environments](#creating-virtual-environments)
1. [Your development environment](#your-development-environment)
1. [Vagrant server setup](docs/vagrant_server_setup.md)
1. [Cloud server setup](docs/cloud_server_setup.md)
1. [Server interactions](#server-interactions)

## Overview

This project template can be used to bootstrap a Django project which is
deployed to an Ubuntu 16.04 or 18.04 server.  It supports projects that run all
services on the same server, with the possible exception of a database that is
managed independently (e.g., Amazon RDS).  Components:

- Django
- uWSGI as the container for Django and process manager for Huey
- Huey as an optional task scheduler and queuing system
- Redis as a backend for Huey or for other features
- PostgreSQL as the relational database
- Apache httpd as the web server and reverse proxy to uWSGI
- Let's Encrypt for certificate management
- npm for installing JavaScript dependencies and serving as a wrapper for JS
  builds

## Project deviations

Differences between this project and the standard project template:

- *a particular project will list any non-standard aspects here*

## Project-specific details

- Ubuntu version for deploy environments: 18.04
- Server and development virtualenv Python version: 3.6
- Deployment virtualenv Python version: 2.7
- Vagrant host ssh port: 4567
- Vagrant host https port: 4568

## Creating virtual environments

A developer will need two separate virtual environments to manage all aspects
of the project.  One of these is for running the code locally; the other is to
deploy to a Vagrant or remote environment.  The dependencies for dev vs. deploy
are separated

- to support different versions of Python for the different roles
- because the Python requirements for the two roles are so different

The instructions throughout the README refer to `./env` and `./env-deploy` as
the locations of the virtual environments.  They can of course be created
elsewhere.

### Development virtualenv

```bash
$ virtualenv -p `which python3.6` ./env
$ . env/bin/activate
$ pip install -r requirements/local.txt
```

Run `. env/bin/activate` before running `./manage.py` or `./run_tests.sh`.

### Deployment virtualenv

The deployment virtualenv is used when deploying or transferring data from the
server or when running commands on the server.

```
$ virtualenv -p `which python2.7` ./env-deploy
$ . env-deploy/bin/activate
$ pip install -r deploy/requirements.txt
    ...
```

Your development environment
============================

## .env

The `manage.py` command reads the `.env` file at startup.  At a minimum, `.env`
must indicate which Django settings module to use.

```bash
echo `DJANGO_SETTINGS_MODULE=myproject.settings.local` > .env
```

## Database setup

As user `postgres`:

```bash
    $ createuser --createdb MYPROJECTNAME
    $ psql
    postgres=# alter user MYPROJECTNAME with password 'MYDBPASS';
    ALTER ROLE
    postgres=# \q
```

As developer:
```bash
    $ PGHOST=localhost createdb -U MYPROJECTNAME -E UTF-8 MYPROJECTNAME
    $ . env/bin/activate
    $ ./manage.py migrate
    $ ./manage.py createsuperuser
    ...
```

## Loading data from the cloud server

Once the cloud server is running, its database and media tree can be synced to
your development environment.

### Loading a copy of the server database

```bash
    $ . env-deploy/bin/activate
    $ ./get_db_dump.sh {production|staging|vagrant}
    $ ./refresh_db.sh
```

### Syncing with the server media tree

```bash
    $ . env-deploy/bin/activate
    $ ./get_media.sh {production|staging|vagrant}
```

Server interactions
===================

Activate the virtualenv for deployment before running any of the shell commands
described in this section.

Your user and ssh public key must be configured in
`deploy/environments/all/devs.yml`.  A version of the code with your information
must have been deployed by someone with access before you can interact with the
server.  Afterwards, you can run the commands in this section as well as log in
via `ssh`.  Ensure that the username in `devs.yml` matches the username on your
client system, as this is assumed by some of the commands.

Deploying
---------

```bash
$ . env-deploy/bin/activate
$ ./deploy.sh {production|staging|vagrant}
...
```

On the first run of `deploy.sh` after Ansible requirements have been updated,
you'll see a message like the following:

```bash
$ ./deploy.sh vagrant
- application (0.0.5) is already installed, skipping.
- httpd (0.0.2) is already installed, skipping.
- logging (0.0.2) is already installed, skipping.
- maintenance (0.0.5) is already installed, skipping.
- system_config (0.0.1) is already installed, skipping.
 [WARNING]: - system_packages (0.0.5) is already installed - use --force to change version to 0.0.6
- users_and_groups (0.0.3) is already installed, skipping.
- uwsgi (0.0.2) is already installed, skipping.
Out of date package:
 [WARNING]: - system_packages (0.0.5) is already installed - use --force to change version to 0.0.6
```

Manually remove the appropriate directory (`system_packages` in this case) under
`deploy/roles` then run `./deploy.sh` again.  The current version will then be
installed.

Running management commands
---------------------------

The `jq` command must be installed on the client system.  (`sudo apt install jq`)

Use ``remote_manage.sh``, as in the following examples:

```bash
    $ . env-deploy/bin/activate
    $ ./remote_manage.sh production showmigrations
    Running as user myproject...
    admin
     [X] 0001_initial
     [X] 0002_logentry_remove_auto_add
    auth
     [X] 0001_initial
     [X] 0002_alter_permission_name_max_length
     [X] 0003_alter_user_email_max_length
     [X] 0004_alter_user_username_opts
    ...
    $ ./remote_manage.sh vagrant shell
    Running as user myproject...
    Python 2.7.12 (default, Nov 19 2016, 06:48:10)
    [GCC 5.4.0 20160609] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    (InteractiveConsole)
    >>>
```
