PYTHON = uv run
DB = pp.db


all:

init: tables

tables: .create-db

reload-data:
	rm -f $(DATA)
	make all

.create-db:
	$(PYTHON) ppxml2db-init --recreate $(DB)
	touch $@

clean:
	-rm -f .create-db $(DB)

# It appears that sqlite3 dump CSV by default with CRLF line
# endings. Use ".separator" directive to override that.
dump:
	for db in `echo ".tables" |  sqlite3 $(DB)`; do \
	    echo -e ".mode csv\n.separator , \\\n\n select * from $$db;" | sqlite3 $(DB) >$$db.csv; \
	done
