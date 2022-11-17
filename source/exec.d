module exec;

import eval: eval;
import parser;
import tokenizer;

import std.file;

void execFile(string fileName) {
    fileName
        .readText
        .tokenize
        .parsePackage
        .eval;
}
