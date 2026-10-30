from django.core.management.base import BaseCommand

from reports.schema_export import export_schema


class Command(BaseCommand):
    help = "Rewrite schema.sql from the current database."

    def handle(self, *args, **options):
        self.stdout.write(f"Wrote {export_schema()}")
