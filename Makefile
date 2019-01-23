DUNE:=opam exec dune

build:
	$(DUNE) build @install
#	$(DUNE) build bin/tjr_kv_test.exe bin/test.exe

install:
	$(DUNE) install

uninstall:
	$(DUNE) uninstall


doc: FORCE
	$(DUNE) build @doc

view_doc:
	google-chrome  _build/default/_doc/_html/index.html

clean:
	$(DUNE) clean


FORCE: