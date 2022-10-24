import errors;
import eval: eval;
import parser;
import types;

import std.stdio;

enum tmpSOurce = `
(*Def globalVar1 42)
(*Def globalVar2 "hello")
(*Module helloWorld
    (*Def modVar "world")
    (*Def AAAAA ($ var)
        (*Print var)
    )
    (*Def Main
        (*Print globalVar2 " " modVar " " AAAAA)
    )
)
`;

void main() {
    enum program =
        "
(begin
    (define r 10)
    (if (> 1000 (* pi (* r r)))
        1000
        0
    )
)
";
    program
        .tokenize
        .parse
        .eval
        .writeln;
}
