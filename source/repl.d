module repl;
import std.stdio;

import args;
import repl;
import errors;
import eval: eval;
import parser;
import types;

void runRepl(string prompt = "*> ") {
    while (true) {
        write(prompt);
        auto line = stdin.readln;
        if (line == "exit\n")
            break;
        line
            .tokenize
            .parse
            .eval
            .writeln;
    }
}
