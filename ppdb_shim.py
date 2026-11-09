"""Thin backward-compatibility shims for the old ppxml2db command names.

The project has been renamed to ppdb. The old entry points
(``ppxml2db``, ``ppxml2db-init`` and ``db2ppxml``) are kept so that existing
scripts and muscle memory keep working, but they now just forward to the new
``ppdb-*`` commands.
"""
import sys


def _deprecate(old, new):
    print(
        f"Warning: '{old}' is deprecated, please use '{new}' instead.",
        file=sys.stderr,
    )


def main():
    """ppxml2db -> ppdb-import"""
    _deprecate("ppxml2db", "ppdb-import")
    from ppdb_import import main as real_main
    real_main()


def init_main():
    """ppxml2db-init -> ppdb-init"""
    _deprecate("ppxml2db-init", "ppdb-init")
    from ppdb_init import main as real_main
    real_main()


def export_main():
    """db2ppxml -> ppdb-export"""
    _deprecate("db2ppxml", "ppdb-export")
    from ppdb_export import main as real_main
    real_main()