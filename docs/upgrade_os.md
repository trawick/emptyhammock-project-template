# Upgrading the OS

When a new Ubuntu Server LTS is available, you'll be able to run `do-release-upgrade`
on the server to upgrade to the next LTS version.  Some planning and testing is
required before taking that step.

The next version of Ubuntu will contain newer versions of many things.  Those of
particular interest are:

- Python 3 version (e.g., 3.5->3.6)
- PostgreSQL version
- Native libraries used by some of your Python packages
- Node if applicable

Here are the typical steps for the upgrade, to be amended as appropriate for your
application:

- Check application dependencies for support of the next version of Python,
  PostgreSQL, and libraries.
- Upgrade dependencies to versions that support your current and future Ubuntu/Python
  versions and test.
- Test the application locally using the new Python version and, if applicable, the
  new Node version.
- Make sure the level of files in your project from emptyhammock-project-template
  support the new version of Ubuntu.  Changes are nearly always required to support
  a new version.  This is a great time to upgrade all Emptyhammock Ansible roles to
  the latest versions, checking `CHANGES` along the way.
- Use Vagrant or a temporary server to create a system equivalent to production
  then run `do-release-upgrade` and test the application and deployment logic
  in that environment, working out the database migration steps.
- Backup data and OS environment on normal staging and production environments.
- Update normal staging environment and test.
- Update production environment.

An alternative to running `do-release-upgrade` and working out upgrade steps
is to provision new servers using the newer Ubuntu level, and migrating data
after the environments have been tested.

Some details you can expect to find when testing the upgrade:

- The node repo as declared in `/etc/apt/sources.list.d` will have been upgraded,
  but a different version of node was installed from the OS repository if the OS
  repository has a newer version.  You can't easily use an older version of the OS
  repository.  (You have to manipulate repository priorities outside of
  `emptyhammock-role-system-packages`.)
- If the node version changes, you'll probably need to remove the `node_modules`
  directory and let it be rebuilt during a deploy.
- The PostgreSQL cluster will need to be migrated to the new version, after which
  the system packages for the old version can be removed.
  Hints/explanation: https://www.paulox.net/2020/04/24/upgrading-postgresql-from-version-11-to-12-on-ubuntu-20-04-focal-fossa/
- The old virtualenv created by deploy won't work because of dependencies on the
  old Python version, so you'll need to remove the virtualenv directory and
  deploy again.
