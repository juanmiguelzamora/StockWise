from django.apps import AppConfig


class ProductConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'product_app'

    def ready(self):
        import product_app.signals  # noqa