#!/usr/bin/env python
import sys

from django.core.management import execute_from_command_line
import dotenv

if __name__ == "__main__":
    dotenv.read_dotenv()
    execute_from_command_line(sys.argv)
