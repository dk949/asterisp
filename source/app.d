import args;
import repl;
import errors;
import eval: eval;
import tokenizer;
import parser;

import std.stdio;
import std.file;

void main(string[] argv) {
    auto parsedArgs = Args(argv);

    if (parsedArgs.fileName)
        parsedArgs
            .fileName
            .readText
            .tokenize
            .parse
            .eval;
    else
        runRepl();
}
