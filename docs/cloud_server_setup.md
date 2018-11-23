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
