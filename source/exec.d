module exec;

import eval: eval;
import parser;
import tokenizer;
import errors;
import hash;

import std.file;

void execFile(string fileName) {
    auto text = fileName.readText;

    text
        .tokenize(fileName)
        .parsePackage(combineHash(text, fileName))
        .eval
        .handleErrors;
}
