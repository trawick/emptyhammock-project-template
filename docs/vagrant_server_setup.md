Initial setup for Vagrant
-------------------------

#### ssh port configuration

`Vagrantfile` has a command like the following which sets the ssh port
(4567 in this example):

```
config.vm.network :forwarded_port, guest: 22, host: 4567, id: "ssh"
```

If necessary, assign a unique ssh host port number that is different
from all the other Vagrant configurations on your development system.

Edit `deploy/inventory/vagrant` and set `ansible_ssh_port` to the same value.

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

If necessary, assign a unique https host port number that is different
from all the other Vagrant configurations on your development system.

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

```bash
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
