## Making it your own project

* Remove `compare.py`; that's a script to use from this repo to try to compare
  with a consuming project.
* Remove `docs/your_project.md` and the link to it in `README.md` (in the table
  of contents).
* Create and activate your deployment virtualenv (described later), so that
  you can encrypt your Ansible vault files.
* Change "myproject" to your project name or other project-specific value,
  everywhere!  File names and contents!
* `git init`
* `git add --dry-run .`
  Ensure that your deploy key or other unencrypted secrets are NOT listed.  Then add 
  anything else unexpected to `.gitignore`, or just delete the file.
* `git add .`
* `git commit -a`
* Push to a new repo in Github.
* Fill in the "Deviations" and "Project-specific details" sections of `README.md`.
