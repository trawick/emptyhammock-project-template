# Common server setup

This setup needs to be performed before setting up Vagrant or cloud servers.

## Deploy key for the repository

Generate a deploy key.

(Hint: `ssh-keygen -t rsa -b 4096 -C "email@example.com" -f project-deploy-key`)

Configure the public deploy key in Github.

## Secrets files

If you have a separate staging server, create the directory
`deploy/environments/staging` and copy the files from
`deploy/environments/production` to that directory.

Edit each of the `deploy/environments/*/secrets.yml` files to define these variables:
  * `SECRET_DB_PASSWORD`
  * `SECRET_DJANGO_SECRET_KEY`
  * `SECRET_GITHUB_DEPLOY_KEY_PRIVATE`
  * `SECRET_GITHUB_DEPLOY_KEY_PUBLIC` (not used on the server, but it helps to be
     able to find the corresponding public key)

Encrypt all of these `secrets.yml` files before committing using `ansible-vault`:
```bash
$ . env-deploy/bin/activate
$ ansible-vault encrypt deploy/environments/vagrant/secrets.yml
$ ansible-vault encrypt deploy/environments/production/secrets.yml
```
If staging exists:
```bash
$ ansible-vault encrypt deploy/environments/staging/secrets.yml
```

Optional: Create file `.vault_pass` to store your Ansible vault password.  This
will avoid password prompts when deploying or running other commands that need
access to the secrets file for an environment.
