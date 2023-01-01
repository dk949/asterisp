module repl;

import errors;
import eval: eval;
import parser;
import tokenizer;
import utils;

import std.stdio;

void runRepl(string prompt = "*> ") {
    while (stdin.isOpen) {
        write(prompt);
        auto line = stdin.readln;
        if (line == "exit\n" || line == "")
            break;

        line
            .tokenize
            .parse
            .eval
            .writeln
            .handleErrors;
    }
}
