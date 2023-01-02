module repl;

import errors;
import eval: eval;
import parser;
import tokenizer;
import utils;

import std.stdio;

void runRepl(string prompt = "*> ") {
    // FIXME: trailing text does not cause error
    // FIXME: Add newline when exiting repl
    while (stdin.isOpen) {
        write(prompt);
        auto line = stdin.readln;
        if (line == "exit\n" || line == "")
            break;

        line
            .tokenize("REPL")
            .parse
            .eval
            .writeln
            .handleErrors;
    }
}
