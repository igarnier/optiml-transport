(lang dune 2.8)

(name optiml-transport)
(version 0.0.1)
(generate_opam_files true)
(source (uri git+https://github.com/igarnier/optiml-transport))
(bug_reports http://github.com/igarnier/optiml-transport)
(homepage http://github.com/igarnier/optiml-transport)
(authors "Ilias Garnier")
(maintainers "igarnier@protonmail.com")
(use_standard_c_and_cxx_flags true)

(package
 (name optiml-transport)
 (synopsis "Solve optimal transportation problems using the network simplex algorithm")
 (description "This library provides bindings to the fast optimal transportation library by Nicolas Bonneel, available here: https://perso.liris.cnrs.fr/nicolas.bonneel/FastTransport/ and originally extracted from the LEMON C++ library. Part of the C++ wrapper is copied from https://github.com/PythonOT/POT")
 (depends (ocaml (>= 4.08)))
 (license MIT)
)
