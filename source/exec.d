module exec;

import eval: eval;
import parser;
import tokenizer;
import hash;

import std.file;

void execFile(string fileName) {
    auto text = fileName.readText;

    text
        .tokenize
        .parsePackage(text.makeHash)
        .eval;
}
