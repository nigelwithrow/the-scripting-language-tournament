solution:
	ocamlopt -output-obj -o solutioncaml.o solution.ml
	ocamlc -c stub.c
	cp $OCAMLLIB/libasmrun.a libsolution.a
	chmod +w libsolution.a
	ar r libsolution.a solutioncaml.o stub.o

tic-tac-boom: solution
	cargo build --release -F ocaml
