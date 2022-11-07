module repl;
import std.stdio;
import std.algorithm;
import std.array;
import std.conv;

import repl;
import errors;
import eval: eval;
import parser;
import types;

void handleErrors(lazy void exec) {
    try
        exec;
    catch (Exception e)
        stderr.writeln(typeid(e).text.split('.')[$ - 1], ": ", e.message);

}

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
            .writeln
            .handleErrors;
    }
}
