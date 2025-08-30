solution.so: solution.ml
	ocamlopt -output-obj -o solutioncaml.o solution.ml
	# ocamlc -custom -output-obj -o solutioncaml.o solution.ml
	ocamlc -c stub.c
	cp libasmrun.a libsolution.a
	# cp /usr/lib/ocaml/libcamlrun.a libsolution.a
	chmod +w libsolution.a
	# gcc -shared -fPIC -o solution.so solutioncaml.o stub.o
	# gcc -shared -o solution.so -Wl,--whole-archive /usr/lib/ocaml/libcamlrun_shared.so -Wl,--no-whole-archive solutioncaml.o stub.o
	ar r libsolution.a solutioncaml.o stub.o

tic-tac-boom: Cargo.toml src/main.rs
	cargo build --release -j6
	cp ./target/release/tic-tac-boom .
