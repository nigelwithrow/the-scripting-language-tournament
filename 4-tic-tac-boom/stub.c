#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <string.h>

int move(const char *board) {
  static const value *fib_closure = NULL;
  CAMLparam0();
  CAMLlocal1(ocaml_str);
  ocaml_str = caml_copy_string_of_os(board);
  if (fib_closure == NULL)
    fib_closure = caml_named_value("move");
  // return Int_val(caml_callback(*fib_closure, caml_copy_string_of_os(board)));
  return Int_val(caml_callback(*fib_closure, ocaml_str));
}
