# The Scripting Language Tournament by [InfiniteCoder01](https://github.com/infiniteCoder01)
This is a merged tree of all of the solutions.
See releases for "Lost in files" master tarball

# Contestants
## OCaml
![OCaml image](pictures/ocaml.png)
Homepage: https://ocaml.org/
Tools Available: ocamlc (native compiler), ocaml (bytecode interpreter) , js_of_ocaml (javascript compiler), opam (package manager), dune (build system)

Why its the best scripting language:
The design of ocaml lends a lot of support for interactive & incremental programming, including:
Top-down evaluation
Static typing without explicit type annotation, most everything can be inferred
Type information visible in the REPL (both the bytecoder interpreter and the enhanced repl 'utop')

```caml
print_endline "Hello, World"
```

### Scoring
1. Portability - 7/10 (Runs almost everywhere, can technically be dynamically compiled and linked in runtime, but lacks on embedding otherwise (please, tell me if I'm wrong here). So no embedable JITs (although work is being done?)  or interpreters, which is crucial for part of scripting)
2. Ecosystem - 9/10 (Has a package manager (opam) & build system (dune), allows for bytecode and native, supports C interop. Also has a REPL (called top), has a bunch of packages. A little bit lacking in docs for packages, aforementioned lack of embedding tools)
3. Average development time - 8/10 (PLEASE, correct me, because I never used it. Because of ecosystem and tooling, it is fairly quick to start. Language looks pretty safe, static typing and things like optional type also help. Although I have no idea how functional and multi-paradigm aspect impacts this)
