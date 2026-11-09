# PPDB — Portfolio Performance XML ↔ database tools

Convert [Portfolio Performance](https://github.com/portfolio-performance/portfolio) (PP) data
files (XML) into a real database (SQLite or PostgreSQL) and back — with a nearly perfect
round-trip.

> **Forked from [ppxml2db](https://github.com/pfalcon/ppxml2db)** — the project has been
> renamed to **ppdb**. The old `ppxml2db`, `ppxml2db-init`, and `db2ppxml` commands still
> work as thin, deprecation-warned shims that forward to the new commands
> (`ppdb-import`, `ppdb-init`, `ppdb-export`).

## Table of contents

- [PPDB — Portfolio Performance XML ↔ database tools](#ppdb--portfolio-performance-xml--database-tools)
  - [Table of contents](#table-of-contents)
  - [Why this exists](#why-this-exists)
  - [What you can do with it](#what-you-can-do-with-it)
  - [Installation](#installation)
  - [Quick start](#quick-start)
    - [1. Get a sample PP file](#1-get-a-sample-pp-file)
    - [2. Import, export, and verify the round-trip](#2-import-export-and-verify-the-round-trip)
    - [3. Query your data](#3-query-your-data)
    - [Handy extras](#handy-extras)
  - [Repository contents](#repository-contents)
  - [Status and known issues](#status-and-known-issues)
  - [References](#references)

## Why this exists

Portfolio Performance is an OpenSource, advanced, full-featured portfolio/asset tracker.
It can do a lot of things, but not everything you may want. Given that it stores data in
an XML file, accessing or modifying that data — e.g. to produce a custom report, add new
transactions, or automatically categorize assets — *seems* easy. In practice it's not:
the XML format is just an internal serialization format of the
[XStream](https://x-stream.github.io/) library. It was never intended to be human
readable, writable, or easy to process with 3rd-party tools.

ppdb addresses this by providing Python scripts that:

1. Parse the (effectively proprietary) PP XML format.
2. Store the data in a database (SQLite or PostgreSQL).
3. Export the data back to PP XML — with as perfect a round-trip as possible.

Round-tripping matters because it lets you **review the changes** you made in the database
before writing them back: import → modify → export, and verify that only your intended
changes appear in the new XML.

While 3rd-party tooling is the primary use case, the project also serves as a **proof of
concept** for storing PP data in a database. The database schema is designed to match
PP's internal object model closely — this may mean a few extra hops when writing SQL,
but it lays groundwork for potentially integrating a database backend directly into PP.

## What you can do with it

The database gives you (and AI agents) actionable data that can be queried
via SQL — much easier than working with the raw XStream XML. Broadly, there are two
directions:

* **Read-only access** — produce various stats and reports.
* **Write access** — modify data, for example:
  * write a custom statement importer (much easier in your favorite scripting language
    than Java, which PP is written in);
  * add a custom price feed handler; or
  * add/update data about your assets, e.g. market capitalization or next earnings date.
  * ...

## Installation

ppdb is written in [Python 3](https://www.python.org). It requires the **XML with 'id' attributes** XML variant
of Portfolio Performance, introduced in PP 0.70.3.

The project uses [uv](https://docs.astral.sh/uv/) for dependency and virtual environment
management. After cloning the repository, run:

```
uv sync
```

to create the virtual environment and install dependencies
(run `uv sync --extra pgsql` for PostgreSQL support).

> **Tip:** you can skip this step entirely — all `make` targets use `uv run`, which sets
> everything up automatically on first use.

## Quick start

All operations are conveniently wrapped in `make` targets (run `make help` to list them).

The database and XML files are configurable via the `DB` and `XML` `make` variables,
which default to `pp.db` and `kommer.xml`. Override them on the `make` command line
(or as environment variables) — either per target:

```
make import DB=main.db XML=main.xml
make export DB=main.db XML=main.xml
```

or once for the whole session:

```
export DB=main.db XML=main.xml
make all
```

Note that `make export` always writes to `<XML>.out` (here `main.xml.out`), and
`make diff` compares that file against the original `$(XML)`.

### 1. Get a sample PP file

1. Start Portfolio Performance and make sure you see the "Welcome" page.
2. On the "Welcome" page, click **Open the Kommer sample file**.
3. `kommer.xml` will open in a new tab.
4. In the application menu, choose: **File → Save as → XML with "id" attributes**.
5. Copy the file to this project's directory for easy access.

### 2. Import, export, and verify the round-trip

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `make init` | Create an empty database with all the needed tables |
| 2 | `make import` | Import the XML into the database |
| 3 | `make export` | Export the database to a new XML file |
| 4 | `make diff` | Ensure the new file matches the original character-by-character |

### 3. Query your data

Now let's do something simple yet useful — something PP itself doesn't do: count the
securities in a portfolio.

```
echo "SELECT COUNT(*) FROM security;" | sqlite3 pp.db
16
```

### Handy extras

* **Start over from scratch:** `make reload-data` — removes the database and re-runs
  `make all`.
* **Per-table CSV dumps** for further analysis: `make dump`.
* **Package for distribution:** `make wheel` — creates `dist/ppdb-*.whl`, installable
  via `pip install dist/ppdb-*.whl` (add the `pgsql` extra for PostgreSQL support).

## Repository contents

| Path | Description |
|------|-------------|
| `schema/*.sql` | Database schema, one table per file |
| `ppdb_init.py` | Create tables in an empty database (installed as `ppdb-init`; old name `ppxml2db-init` still works as a deprecation shim) |
| `ppdb_import.py` | Import an XML file into a database (installed as `ppdb-import`; old name `ppxml2db` still works as a deprecation shim) |
| `ppdb_export.py` | Export a database to an XML file (installed as `ppdb-export`; old name `db2ppxml` still works as a deprecation shim) |
| `ppdb_shim.py` | Thin backward-compatibility shims that forward the old command names to the new ones and print a deprecation warning |
| `pyproject.toml` | Project metadata and dependencies, managed with [uv](https://docs.astral.sh/uv/) |
| `Makefile` | Convenient targets wrapping the commands described above (`make help` for the full list) |

## Status and known issues

ppdb is an experimental project and a work in progress. The current status, known issues,
and TODOs are documented in [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md).

## References

* ["anybody interested in PP with a database?"](https://github.com/portfolio-performance/portfolio/issues/2216)
* [Criticism of PP XML format](https://github.com/portfolio-performance/portfolio/issues/3417)
