(lang dune 2.8)

(name camlot)
(version 0.0.1)
(generate_opam_files true)
(source (uri git+https://github.com/igarnier/camlot))
(bug_reports http://github.com/igarnier/camlot)
(homepage http://github.com/igarnier/camlot)
(authors "Ilias Garnier")
(maintainers "igarnier@protonmail.com")
(use_standard_c_and_cxx_flags true)

(package
 (name camlot)
 (synopsis "Solve optimal transportation problems using the FastTransport library")
 (description "This library provides binding to the FastTransport library by Nicolas Bonneel, available here: https://perso.liris.cnrs.fr/nicolas.bonneel/FastTransport/.
Part of the C++ wrapper is copied from https://github.com/PythonOT/POT")
 (license MIT)
)
