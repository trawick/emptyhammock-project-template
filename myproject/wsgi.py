"""
WSGI config

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.11/howto/deployment/wsgi/
"""

from pathlib import Path

from django.core.wsgi import get_wsgi_application
import dotenv

dotenv.read_dotenv(str(Path(__file__).resolve().parents[1] / '.env'))
application = get_wsgi_application()
