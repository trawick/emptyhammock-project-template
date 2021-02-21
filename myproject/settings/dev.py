from .base import *

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# No logging to e-mail in development
for logger_name in LOGGING['loggers'].keys():
    logger = LOGGING['loggers'][logger_name]
    logger['handlers'] = list(filter(
        lambda x: x != MAIL_HANDLER,
        logger['handlers']
    ))

# Instead of trying to send emails through SMTP, write them to the console.
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
