(lang dune 2.0)
(name tjr_profile)

;; for opam
(authors              "Tom Ridge <tom.j.ridge@googlemail.com>")
(maintainers          "Tom Ridge <tom.j.ridge@googlemail.com>")
(source               (github tomjridge/tjr_profile))
(homepage             https://github.com/tomjridge/tjr_profile)
(documentation        https://tomjridge.github.io/ocamldocs/)
(generate_opam_files  true)


(package 
 (name tjr_profile)
 (synopsis "A simple profiling library")
 (depends 
core ;; for TSC
tjr_lib_core
))

