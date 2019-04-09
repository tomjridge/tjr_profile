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
docs: FORCE
	$(DUNE) build @doc
	rm -rf $(DST)/*
	cp -R $(SRC)/* $(DST)

view_doc:
	google-chrome  _build/default/_doc/_html/index.html



FORCE:
