"""Local development settings."""
from .base import *  # noqa
from .base import env

DEBUG = True
SECRET_KEY = env("SECRET_KEY", default="django-insecure-local-dev-key-12345")
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "0.0.0.0"]

# Database - Use SQLite for now (no Docker needed)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": str(ROOT_DIR / "db.sqlite3"),
    }
}

# Email
EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

# Logging
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
    },
    "root": {
        "level": "INFO",
        "handlers": ["console"],
    },
}
