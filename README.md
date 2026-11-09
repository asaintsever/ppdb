# PPDB — Portfolio Performance XML ↔ database tools

> **Forked from [ppxml2db](https://github.com/pfalcon/ppxml2db)** — the project has been renamed to **ppdb**.
The old `ppxml2db`, `ppxml2db-init`, and `db2ppxml` commands still work
as thin, deprecation-warned shims that forward to the new commands
(`ppdb-import`, `ppdb-init`, `ppdb-export`).

[Portfolio Performance](https://github.com/portfolio-performance/portfolio)
or "PP" for short, is an OpenSource, advanced, full-featured portfolio/asset
tracker. It can
do a lot of things, but definitely not all that you may want. Given that
it stores data in an XML file, it may seem that it would be easy to access
data in it, e.g. to produce a custom report, or modify it, e.g. add new
transactions or automatically categorize assets. But turns out, that's not
the case, as the XML format used by PP is nothing but internal serialization
format of 3rd-party library [XStream](https://x-stream.github.io/). This
format never was intended to be human readable, writable, easy to process
by 3rd-party tools, or anything like that.

This project tries to address this problem, by providing Python
scripts to parse this, effectively proprietary, XML format, store the
data into a database (SQLite or PostgreSQL), and perform a reverse operation - export
data from such a database back to the XML format, while achieving
as perfect round-trip as possible (meaning that if you import data and
immediately export, you will get almost no differences comparing to the
original XML file, and if you change some things in the database, then in
general, only these changes will be propagated to XML file). Round-tripping
is important, because it will allow you to review the changes made to the
data in the database, and ensure they correspond to your expectations.

While developing 3rd-party tools is the primary usecase behind this project,
it also tries to be a "proof of concept" of the idea of storing
Portfolio Performance data in the database. To that end, database schema
is intended to match internal PP object schema pretty well. This means
that while writing data manipulation scripts you may need to jump
thru some extra hops, but potentially opens a possibility to integrate
database backend directly into PP (by making at least a first step -
providing a realisitic database schema for that).

## What can be done with the resulting database?

Anything you want. One goal of the database is to give AI agents an
actionable input they can query easily via SQL, since the original PP
XML file (its XStream serialization format) is hard to deal with
directly. Broadly, there are two directions:

* **Read-only access** - to produce various stats and reports.
* **Write access** - to modify data, e.g.
  * write a custom statement importer (much easier in your favorite
    scripting language than Java, which PP is written in);
  * add a custom price feed handler; or
  * add/update data about your assets, e.g. market capitalization or
    next earnings date.

Possibilities are limitless.

## What's in the repository

* `schema/*.sql` - Database schema, one table per file.
* `ppdb_init.py` - Script to create tables in an empty database
  (installed as the `ppdb-init` command; old name `ppxml2db-init`
  still works as a deprecation shim).
* `ppdb_import.py` - Script to import XML file into a database
  (installed as the `ppdb-import` command; old name `ppxml2db`
  still works as a deprecation shim).
* `ppdb_export.py` - Script to export database to XML file
  (installed as the `ppdb-export` command; old name `db2ppxml`
  still works as a deprecation shim).
* `ppdb_shim.py` - Thin backward-compatibility shims that forward the
  old command names to the new ones and print a deprecation warning.
* `pyproject.toml` - Project metadata and dependencies, managed with
  [uv](https://docs.astral.sh/uv/).
* `Makefile` - Convenient targets wrapping the commands described
  below (run `make help` to see the full list).

The project uses [uv](https://docs.astral.sh/uv/) for dependency and
virtual environment management. After cloning the repository, run:

```
uv sync
```

to create the virtual environment and install dependencies (run
`uv sync --extra pgsql` if you also want PostgreSQL support).
Alternatively, you can skip this step - all `make` targets use
`uv run`, which sets everything up automatically on first use.

## Example usage

The ppdb tools are written in [Python3](https://www.python.org),
any modern version should work, at the time of writing, it was tested
with Python 3.8-3.12.

ppdb requires "XML with 'id' attributes" XML variant of
Portfolio Performance, as introduced in Portfolio Performance 0.70.3.

All operations are conveniently wrapped in `make` targets
(run `make help` to list them). The database and XML files are
configurable, e.g. to use `kommer.db` instead of the default `pp.db`,
run `make DB=kommer.db ...` on the corresponding targets.

1. Start Portfolio Performance. Make sure you see "Welcome" page.
2. On the "Welcome" page, click "Open the Kommer sample file".
3. "kommer.xml" will open in a new tab.
4. In the application menu, choose: File -> Save as -> XML with "id" attributes.
4. Copy the file to this project's directory for easy access.
5. Create an empty database with all the needed tables:
   `make init`
6. Import the XML into the database:
   `make import`
7. Export the database to a new XML file:
   `make export`
8. Ensure that the new file matches the original character-by-character:
   `make diff`

Now let's do something pretty simple, yet useful, and already something
which PP itself doesn't do: show how many securities are in a portfolio:

```
echo "SELECT COUNT(*) FROM security;" | sqlite3 pp.db
16
```

To start over with a completely fresh database, use `make reload-data`
(it removes the database and re-runs `make all`).

To get per-table CSV dumps of the database for further analysis,
use `make dump`.

To package the project for distribution, use `make wheel`, which
creates `dist/ppdb-*.whl` installable via
`pip install dist/ppdb-*.whl` (add the `pgsql` extra for
PostgreSQL support).

## Status and known issues

ppdb is an experimental project and a work in progress. The current status,
known issues and TODOs are documented in
[`KNOWN_ISSUES.md`](KNOWN_ISSUES.md).

## References

* ["anybody interested in PP with a database?"](https://github.com/portfolio-performance/portfolio/issues/2216)
* [Criticism of PP XML format](https://github.com/portfolio-performance/portfolio/issues/3417)
