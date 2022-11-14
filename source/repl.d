module repl;
import std.stdio;
import std.algorithm;
import std.array;
import std.conv;

import repl;
import errors;
import eval: eval;
import tokenizer;
import parser;
import types;
import utils;

void handleErrors(lazy void exec) {
    try
        exec;
    catch (Exception e)
        stderr.writeln(typeid(e).userText, ": ", e.message);

}

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
