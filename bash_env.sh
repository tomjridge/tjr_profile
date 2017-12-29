set -a # export all vars
#set -x # debug

libname="tjr_profile"
required_packages="core"
description="Very simple profiling library"


function clean() {
	rm -f *.cmi *.cmo *.cmx *.o *.x *.a *.cma *.cmxa
}



# generic from here ----------------------------------------------------

# was in bash_env.common

PKGS="-package $required_packages"
SYNTAX=""

WARN=""

# -thread needed for core
  ocamlc="$DISABLE_BYTE ocamlfind ocamlc   -thread -g $WARN $PKGS $SYNTAX"
ocamlopt="$DISABLE_NTVE ocamlfind ocamlopt -thread -g $WARN $PKGS $SYNTAX"
ocamldep="ocamlfind ocamldep $PKGS"

mk_cma="$DISABLE_BYTE ocamlfind ocamlc"
mk_cmxa="$DISABLE_NTVE ocamlfind ocamlopt"

mls=`ocamldep -sort -one-line *.ml`
cmos="${mls//.ml/.cmo}"
cmxs="${mls//.ml/.cmx}"

natives="
"

branch=`git symbolic-ref --short HEAD` 
v=`date +'%F'`
if [ "$branch" = "master" ]; then
    package_name="${libname}"
else 
    package_name="${libname}_${branch}"
fi


function mk_meta() {
cat >META <<EOF
name="$package_name"
description="$description"
version="$v"
requires="$required_packages"
archive(byte)="$libname.cma"
archive(native)="$libname.cmxa"
EOF
}
