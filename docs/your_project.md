## Making it your own project

* Remove `compare.py`; that's a script to use from this repo to try to compare
  with a consuming project.
* Create and activate your deployment virtualenv (described later), so that
  you can encrypt your Ansible vault files.
* Change "myproject" to your project name or other project-specific value,
  everywhere!  File names and contents!
* Edit `Vagrantfile` and assign unique port numbers for ssh and https.
* Edit `deploy/inventory/vagrant` and set the ssh port number to the same value.
* Edit `deploy/inventory/production` and set the production IP address.
* Generate a deploy key.
  (Hint: `ssh-keygen -t rsa -b 4096 -C "email@example.com" -f project-deploy-key`)
* Edit `deploy/environments/vagrant/secrets.yml` to define these variables:
  * `SECRET_DB_PASSWORD`
  * `SECRET_DJANGO_SECRET_KEY`
  * `SECRET_GITHUB_DEPLOY_KEY_PRIVATE`
  * `SECRET_GITHUB_DEPLOY_KEY_PUBLIC` (not used on the server, but it helps to be
     able to find the corresponding public key)
* Provide values for the same variables in `deploy/environments/production/secrets.yml`.
* Run `ansible-vault encrypt deploy/environments/vagrant/secrets.yml`.
* Run `ansible-vault encrypt deploy/environments/production/secrets.yml`.
* `git init`
* `git add --dry-run .`
  Ensure that your deploy key or other unencrypted secrets are NOT listed.  Then add 
  anything else unexpected to `.gitignore`, or just delete it.
* `git add .`
* `git commit -a`
* Push to a new repo in Github.
* Configure the public deploy key in Github.
* Optional: Create file `.vault_pass` to store your Ansible vault password.

