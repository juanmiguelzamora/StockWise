from django.apps import AppConfig

class UsersConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.users"   # ✅ must match INSTALLED_APPS
    verbose_name = "Authentication and Authorization"   # ✅ human-readable name for the app

    def ready(self):
        # Import signals so they are registered when the app is loaded
        import apps.users.signals