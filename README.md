# myproject

# Table of Contents

1. [Making it your own project](docs/your_project.md)
1. [Deviations from project template](#deviations)
1. [Project-specific details](#project-specific-details)
1. [Creating virtual environments](#creating-virtual-environments)
1. [Your development environment](#your-development-environment)

## Deviations

Differences between this project and the standard project template:

- *list any non-standard aspects here*

## Project-specific details



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
$ virtualenv -p /usr/bin/python3.5 ./env
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

```
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

## Loading a copy of the server database

```bash
    $ . env-deploy/bin/activate
    $ ./get_db_dump.sh {production|staging|vagrant}
    $ ./refresh_db.sh
```

## Syncing with the server media tree

```bash
    $ . env-deploy/bin/activate
    $ ./get_media.sh {production|staging|vagrant}
```

Managing Vagrant and production servers
=======================================

General preparation
-------------------

Activate the virtualenv for deployment before running any of the shell commands
described in this section.

Configure your user and ssh public key in `deploy/environments/all/devs.yml`.  After the next
deploy to a server, you'll be able to log in via `ssh`.  Ensure that the
username in `devs.yml` matches the username on your client system.

Initial setup for Vagrant
-------------------------

Install Vagrant 1.8.7 or later in order to test a Vagrant-managed server.

#### ssh port configuration

`Vagrantfile` has a command like the following which sets the ssh port
(4567 in this example):

```
config.vm.network :forwarded_port, guest: 22, host: 4567, id: "ssh"
```

This must match the value of `ansible_ssh_port` in `deploy/inventory/vagrant`.

Thus, use `ssh -p 4567 127.0.0.1` when connecting to the Vagrant-managed
server.

#### https domain and port configuration

You can interact with the application running on the Vagrant-managed server
using a web browser on your client system, but some preparation is needed.

The host name which the application expects is configured in the
`target_address` variable in `deploy/environments/vagrant/vars.yml`.  This
documentation assumes that it is `vagrant-MYPROJECTNAME.com.`  Add an entry like
the following to `/etc/hosts` on your client system:

```
127.0.0.1 vagrant-MYPROJECTNAME.com
```

Find the port on the client for 443 on a command like the following in
`Vagrantfile`:

```
config.vm.network :forwarded_port, guest: 443, host: 4568
```

(In this example, the port is 4568.)

The URL for accessing the application in the Vagrant-managed server is
thus `https://vagrant-myproject.com:4568/`.  This uses a self-signed certificate,
so expect to get the normal browser warning.

#### After you destroy and recreate your Vagrant-managed server

A deploy may fail with a message like

```
fatal: [default]: UNREACHABLE! => {"changed": false, "msg": "SSH Error: data could not be sent to remote host \"127.0.0.1\". Make sure this host can be reached over ssh", "unreachable": true}
```

When you ssh directly like Ansible would have done, you'll see the issue.  Remove
the old host key as instructed.

```
$ ssh -i .vagrant/machines/default/virtualbox/private_key -p 4577 vargrant@127.0.0.1
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:4b5jX9+MLi5lNcJOQ2Z1AQoHVkEmRB6/xUy8sriswIQ.
Please contact your system administrator.
Add correct host key in /home/trawick/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/trawick/.ssh/known_hosts:211
  remove with:
  ssh-keygen -f "/home/trawick/.ssh/known_hosts" -R [127.0.0.1]:4577
ECDSA host key for [127.0.0.1]:4577 has changed and you have requested strict checking.
Host key verification failed.
$ ssh-keygen -f "/home/trawick/.ssh/known_hosts" -R [127.0.0.1]:4577
# Host [127.0.0.1]:4577 found: line 211
/home/trawick/.ssh/known_hosts updated.
Original contents retained as /home/trawick/.ssh/known_hosts.old
```

Initial setup for VPS
---------------------

### EC2 hints

- Create a new EC2 instance.  You'll need the key pair for the instance,
  whether you reuse an existing one or create a new one.  Use Ubuntu 18.04.
  - The Ubuntu user used for bootstrapping (below) will be `ubuntu`, not
    `root`.
- Get the public key from the `.pem` file using a command-line trick, or
  copy it from the `authorized_keys` file in the instance.

#### ssh-ing with the `.pem` file

Make sure the permissions of the `.pem` file are `0400`.

`$ ssh -i /path/my-key-pair.pem ubuntu@FOO.COM`

where `FOO.COM` is the AWS-assigned domain name.

### General instructions

The `sshpass` command must be installed on the client system.
(`sudo apt install sshpass`)

On the new server:

Fix the hostname in `/etc/hosts`.  Add an alias for `127.0.0.1`, as in the
following example:

```
127.0.0.1 localhost my-shiny.com
```

Fix the hostname in `/etc/hostname`.  (The only line in the file should be
the FQDN.)

Next, using `sudo` if not logged in as `root`:

```bash
# apt update && apt install -y python-minimal && apt full-upgrade -y
# shutdown -r now
```

Code the IPv4 address in `deploy/inventory/production`, to control which server
Ansible deploys to.

For initial testing of the server, specify a self-signed certificate in
`deploy/environments/production/vars.yml`:

```
cert_source: "self-signed"
```

Normally this is `"certbot"`.  When initially bringing up the server, a
self-signed certificate is used.  After the domain name is changed, the
`obtain_certificate.sh` script is run to create a real certificate, then
`cert_source` is changed to start using it.

Normally, a certificate is requested for both the normal domain name as
well as the same domain name with a `www.` prefix.  Be sure to override
`certificate_domains` in the `vars.yml` files to omit that.

A bootstrap step is needed to define developer users on the machine.  Depending
on the VPS provider, either `root` or some other user will be used for
bootstrapping.

Run the bootstrap step as follows:

Only the `root` user will be available initially on a VPS, so 

```bash
$ ./deploy/bootstrap.sh {production|staging} {root|other_user} [PEM_file]
root password on server:
Vault password:
...
```

For EC2 instances, use `ubuntu` for the user and specify the PEM_file
representing the key pair for the instance.

For Linode and Digital Ocean, use `root` for the user and omit the PEM_file
parameter.

If the user's password isn't needed because an ssh key is used to log in,
simply press ENTER at the password prompt.

If `.vault_pass` has been created, you won't be prompted for the vault
password.

### When it doesn't work

ssh configuration can be tedious to debug.  Add `-vvv` to the end of the
`bootstrap.sh` commandline to see the exact `ssh` command issued by Ansible.
Try running the same command manually.

Log in to the server and run `sudo tail -f /var/log/auth.log` to see what
messages are written while running `bootstrap.sh`.

## Maintenance

Once the new server is operating properly, update the `maintenance` project
to include the server in regular maintenance tasks.

Deploying
---------

```bash
$ . env-deploy/bin/activate
$ ./deploy.sh vagrant
...
$ ./deploy.sh production
```

On the first run of `deploy.sh` after Ansible requirements have been updated,
you'll see a message like the following:

```
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

```
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
