from .settings import *
from .settings import env

# GENERAL
# ------------------------------------------------------------------------------
# https://docs.djangoproject.com/en/dev/ref/settings/#debug
DEBUG = env.bool("DJANGO_DEBUG", default=True)
ALLOWED_HOSTS = ["*"]