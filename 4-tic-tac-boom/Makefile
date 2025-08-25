build-so:
	ocamlopt -output-obj -o solutioncaml.o solution.ml
	# ocamlc -custom -output-obj -o solutioncaml.o solution.ml
	ocamlc -c stub.c
	cp /usr/lib/ocaml/libasmrun.a libsolution.a
	# cp /usr/lib/ocaml/libcamlrun.a solution.a
	chmod +w libsolution.a
	ar r libsolution.a solutioncaml.o stub.o
