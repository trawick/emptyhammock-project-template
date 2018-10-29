from .base import *

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

ALLOWED_HOSTS = [os.environ['DOMAIN']]
SECRET_KEY = os.environ.get('SECRET_KEY', '')
STATIC_ROOT = os.environ.get('STATIC_DIR')
ADMINS = (
    ('myproject admin', 'myproject@myproject.com'),
)
SERVER_EMAIL = 'root@myproject.com'

if os.environ['SERVER_TYPE'] == 'vagrant':
    LOGGING['handlers'][MAIL_HANDLER] = {
        'level': 'ERROR',
        'class': 'logging.FileHandler',
        'filename': str(Path(os.environ['LOG_DIR']) / 'emailed-errors.log'),
    }

SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = True
