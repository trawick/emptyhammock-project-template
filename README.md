# myproject

# Table of Contents

1. [Using the template for your project](docs/your_project.md)
1. [Overview](#overview)
1. [Deviations from project template](#project-deviations)
1. [Project-specific details](#project-specific-details)
1. [Development system requirements](#development-system-requirements)
1. [Creating virtual environments](#creating-virtual-environments)
1. [Your development environment](#your-development-environment)
1. [Common server setup](docs/common_server_setup.md)
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
- Out of the box, it assumes that
  [emptyhammock-maintenance](https://github.com/trawick/emptyhammock-maintenance)
  will be used for various maintenance tasks.

## Project deviations

Differences between this project and the standard project template:

- *a particular project will list any non-standard aspects here*

## Project-specific details

(edit this)

- Ubuntu version for deploy environments: 18.04
- Server and development virtualenv Python version: 3.X
- Deployment virtualenv Python version: 3.X
- Vagrant host ssh port: 4567
- Vagrant host https port: 4568

## Development system requirements

- Python 3.X
- `jq` command, for running `./manage.py` on the server
  - Ubuntu: `sudo apt install jq`
- PostgreSQL server and CLI, for your development and test database
- Vagrant 1.8.7 or later, for testing a Vagrant-managed server
  - This is typically used when testing new Ansible deployment logic.

Recommendation: Use `pyenv` to manage Python interpreters.  Fill in `.python-version`
in the root directory of the project.

## Creating virtual environments

A developer will need two separate virtual environments to manage all aspects
of the project.  One of these is for running the code locally; the other is to
deploy to a Vagrant or remote environment.  (The dependencies for dev vs. deploy
are independent.)

The instructions throughout the README refer to `./env` and `./env-deploy` as
the locations of the virtual environments.  They can of course be created
elsewhere.

### Development virtualenv

```bash
$ python3 -m venv ./env
$ . env/bin/activate
$ pip install -r requirements/local.txt
```

Run `. env/bin/activate` before running `./manage.py` or `./run_tests.sh`.

### Deployment virtualenv

The deployment virtualenv is used when deploying or transferring data from the
server or when running commands on the server.

```bash
$ python3 -m venv ./env-deploy
$ . env-deploy/bin/activate
$ pip install -r deploy/requirements.txt
    ...
```

Run `. env-deploy/bin/activate` before running any of the following:

- `./deploy.sh`
- `./get_db_dump.sh`
- `./refresh_db.sh`
- `./get_media.sh`
- `./remote_manage.sh`

Your development environment
============================

## .env

The `manage.py` command reads the `.env` file at startup.  At a minimum, `.env`
must indicate which Django settings module to use.

```bash
echo `DJANGO_SETTINGS_MODULE=myproject.settings.local` > .env
```

You can also define any other environment variables which are read by the
server.

## Database setup

As user `postgres`:

```bash
    $ createuser --createdb MYPROJECT
    $ psql
    postgres=# alter user MYPROJECT with password 'MYDBPASS';
    ALTER ROLE
    postgres=# \q
```

As developer:
```bash
$ PGHOST=localhost createdb -U MYPROJECT -E UTF-8 MYPROJECT
$ . env/bin/activate
$ ./manage.py migrate
...
```

## Creating a superuser

(standard Django)

```bash
$ . env/bin/activate
$ ./manage.py createsuperuser
```

## Running the development server

(standard Django)

```bash
$ . env/bin/activate
$ ./manage.py runserver 8000
```

## Running tests and `flake8`

```bash
$ . env/bin/activate
$ ./run_tests.sh
```

## Loading data from the cloud server

Once the cloud server is running, its database and media tree can be synced to
your development environment with the following commands, described under
[Server interactions](#server-interactions):

- `./get_db_dump.sh`
- `./refresh_db.sh`
- `./get_media.sh`

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

Optional: Create file `.vault_pass` to store your Ansible vault password.  This
will avoid password prompts when deploying or running other commands that need
access to the secrets file for an environment.

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

Loading a copy of the server database into your dev database
------------------------------------------------------------

```bash
$ . env-deploy/bin/activate
$ ./get_db_dump.sh {production|staging|vagrant}
$ ./refresh_db.sh
```

Syncing your dev media tree with the server media tree
------------------------------------------------------

```bash
$ . env-deploy/bin/activate
$ ./get_media.sh {production|staging|vagrant}
```
