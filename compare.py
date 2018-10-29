#!/usr/bin/env python3

import os
import re
import subprocess
import sys


def get_project_name(project_dir):
    with open(os.path.join(project_dir, 'deploy', 'environments', 'all', 'vars.yml')) as f:
        for l in f.readlines():
            m = re.match('^project_name: (.*)$', l)
            if m:
                return m.group(1)
    raise Exception('Could not find PROJECT_NAME in Ansible variables!')


def compare(template_dir, project_dir):
    project_name = get_project_name(project_dir)
    # stop ignoring templates if project template starts including that dir
    assert not os.path.exists(os.path.join(template_dir, 'templates'))
    subprocess.call([
        'diff', '-ru',
        '--exclude', project_name,
        '--exclude', 'apps',
        '--exclude', 'compare.py',
        '--exclude', '.coverage',
        '--exclude', 'docs',
        '--exclude', '.env',
        '--exclude', 'env',
        '--exclude', 'env-deploy',
        '--exclude', '.git',
        '--exclude', '.idea',
        '--exclude', '*.log',
        '--exclude', 'media',
        '--exclude', 'myproject',
        '--exclude', 'node_modules',
        '--exclude', 'package.json',
        '--exclude', 'project.sql.gz',
        '--exclude', '__pycache__',
        '--exclude', '*.pyc',
        '--exclude', '*.retry',
        '--exclude', 'secrets.yml',
        '--exclude', '*.sql',
        '--exclude', 'standalone_tests',
        '--exclude', '.vagrant',
        '--exclude', '.vault_pass',
        '--exclude', 'webpack.config.js',
        '--exclude', 'webpack-stats.json',
        template_dir, project_dir])
    subprocess.call([
        'diff', '-ru',
        '--exclude', '__pycache__',
        '--exclude', '*.pyc',
        os.path.join(template_dir, 'myproject'),
        os.path.join(project_dir, project_name)
    ])


def main():
    if len(sys.argv) != 2:
        print('Usage: %s path-to-other-project' % sys.argv[0], file=sys.stderr)
        sys.exit(1)
    compare('.', sys.argv[1])


if __name__ == '__main__':
    main()
