from django.apps import AppConfig
from django.db.models.signals import post_migrate


def _update_schema_file(sender, **kwargs):
    """After every migrate, refresh schema.sql. It must never break migrate."""
    try:
        from .schema_export import export_schema
        export_schema()
    except Exception as error:
        print(f"(schema.sql was not updated: {error})")


class ReportsConfig(AppConfig):
    name = "reports"

    def ready(self):
        post_migrate.connect(_update_schema_file, sender=self)
