"""Writes backend/schema.sql from the REAL database, so the file can never
get out of date. It runs by itself after every `python manage.py migrate`."""
from datetime import datetime

from django.apps import apps
from django.conf import settings
from django.db import connection

HEADER = """-- Campus Care database schema (SQLite)
-- AUTO-GENERATED on {when} by `python manage.py migrate`.
-- Do not edit by hand: it is rewritten every time the database changes.
-- You do NOT need to run this file; Django builds the tables for you.
-- It is for documentation, or to open in DB Browser for SQLite.

"""


def _pretty(sql):
    """Put each column on its own line so it is easy to read."""
    head, _, rest = sql.partition("(")
    body = rest.rstrip().rstrip(")")
    body = body.replace(', "', ',\n    "')
    return f"{head}(\n    {body}\n);"


def export_schema():
    tables = [m._meta.db_table for m in apps.get_app_config("reports").get_models()]
    tables.append("authtoken_token")
    parts = [HEADER.format(when=datetime.now().strftime("%Y-%m-%d %H:%M"))]
    with connection.cursor() as cur:
        for table in tables:
            cur.execute(
                "SELECT type, sql FROM sqlite_master "
                "WHERE tbl_name = %s AND sql IS NOT NULL ORDER BY type DESC, name",
                [table],
            )
            for kind, sql in cur.fetchall():
                parts.append(_pretty(sql) if kind == "table" else sql + ";")
            parts.append("")
    path = settings.BASE_DIR / "schema.sql"
    path.write_text("\n".join(parts), encoding="utf-8")
    return path
