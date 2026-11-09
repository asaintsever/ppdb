.SILENT: ;               # No need for @
.ONESHELL: ;             # Single shell for a target (required to properly use all of our local variables)
.EXPORT_ALL_VARIABLES: ; # Send all vars to shell
.DEFAULT: help # Running Make without target will run the help target

.PHONY: help init clean all import export diff dump reload-data tables .create-db wheel

# Run commands via `uv run`, which sets up the virtual environment
# and dependencies on demand, so `uv sync` can be skipped.
PYTHON = uv run

# SQLite database file used for all operations.
DB = pp.db

# $(DATA) is simply the database file ($(DB)): reload-data removes it
# first so that `make all` recreates it and re-imports everything
# from scratch.
DATA = $(DB)

# Source Portfolio Performance XML file (the "XML with 'id'
# attributes" variant, as produced by PP >= 0.70.3).
XML = kommen.xml

# Output XML file produced by the `export` target.
OUT = $(XML).out

help: ## Show Help
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: init import ## Create the database and import the XML data

init: tables ## Create an empty database with all the needed tables ($(DB))

# Alias for init.
tables: .create-db

reload-data: ## Recreate the database ($(DATA)) and re-import the XML data
	rm -f $(DATA)
	make all

import: ## Import $(XML) into the database ($(DB))
	$(PYTHON) ppdb_import.py $(XML) $(DB)

export: ## Export the database ($(DB)) to a new XML file ($(OUT))
	$(PYTHON) ppdb_export.py $(DB) $(OUT)

diff: ## Verify round-trip: diff original XML ($(XML)) vs exported ($(OUT))
	diff -u $(XML) $(OUT)

# Build a Python wheel in dist/ for easy distribution and install.
# (Note: `uv build` runs in an isolated build environment, so it is
# called directly instead of via `$(PYTHON)`.)
wheel: ## Build a Python wheel (dist/ppdb-*.whl)
	uv build --wheel

# Prerequisite of init: actually runs the schema creation,
# guarded by the .create-db stamp file.
.create-db:
	$(PYTHON) ppdb_init.py --recreate $(DB)
	touch $@

clean: ## Remove the database ($(DB)), the build stamp and build artifacts
	-rm -f .create-db $(DB)
	-rm -rf dist build ppdb.egg-info ppxml2db.egg-info

# It appears that sqlite3 dump CSV by default with CRLF line
# endings. Use ".separator" directive to override that.
dump: ## Dump all tables of $(DB) to CSV files (<table>.csv)
	for db in `echo ".tables" |  sqlite3 $(DB)`; do \
	    echo -e ".mode csv\n.separator , \\\n\n select * from $$db;" | sqlite3 $(DB) >$$db.csv; \
	done
