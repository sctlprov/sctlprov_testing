
all:
	ocamlopt res.ml
	ocamllex lexer.mll
	ocamlyacc parser.mly
	ocamlopt -c parser.mli
	ocamlopt -c lexer.ml
	ocamlopt -c parser.ml
	ocamlopt -c main.ml 
	ocamlfind ocamlopt -o run -linkpkg -g unix.cmxa str.cmxa res.cmx lexer.cmx parser.cmx main.cmx


clean:
	rm -f *.cm[ioxa]
	rm -f interpreter*
	rm -f run
	rm -f a.out
	rm -f *.o
	rm -f lexer.ml
	rm -f parser.mli
	rm -f parser.ml
	rm -f *.bak
