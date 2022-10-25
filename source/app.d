import args;
import repl;
import errors;
import eval: eval;
import parser;

import std.stdio;
import std.file;

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

void main(string[] argv) {
    auto parsedArgs = Args(argv);

    if (parsedArgs.fileName)
        parsedArgs
            .fileName
            .readText
            .tokenize
            .parse
            .eval
            .writeln;
    else
        runRepl();
}
