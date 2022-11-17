module exec;

import tokenizer;
import parser;
import eval: eval;

import std.file;

void execFile(string fileName) {
    fileName
        .readText
        .tokenize
        .parsePackage
        .eval;
}
