module exec;

import eval: eval;
import parser;
import tokenizer;
import hash;
import errors;

import std.file;

void execFile(string fileName) {
    auto text = fileName.readText;

    text
        .tokenize(fileName)
        .parsePackage((text ~ fileName).makeHash)
        .eval
        .handleErrors;
}
