DUNE:=dune

build:
	$(DUNE) build @install
#	$(DUNE) build bin/tjr_kv_test.exe bin/test.exe

install:
	$(DUNE) install

uninstall:
	$(DUNE) uninstall

clean:
	$(DUNE) clean

all:
	$(MAKE) clean
	$(MAKE) build
	$(MAKE) install
	$(MAKE) docs


SRC:=_build/default/_doc/_html
DST:=docs
DST2:=/tmp/tjr_profile
docs: FORCE
	$(DUNE) build @doc
	@if [ ! -z "$$PROMOTE_DOCS" ]; then rm -rf $(DST)/* ; cp -R $(SRC)/* $(DST); echo "docs built and promoted to docs/"; else \
	  rsync -vaz $(SRC)/* $(DST2); echo "docs built in $(DST2) but not promoted to docs/"; fi

promote_docs: FORCE
	PROMOTE_DOCS=true $(MAKE) docs


view_doc:
	google-chrome  _build/default/_doc/_html/index.html



FORCE:
