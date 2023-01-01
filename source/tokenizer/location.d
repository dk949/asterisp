module tokenizer.location;
import tokenizer.utils;

import std.algorithm;

struct Loc {
    ulong line;
    ulong col;
    string file;

    this(const(string) slice, string filename) {
        line = slice.count('\n') + 1;
        col = 1;
        foreach_reverse (ch; slice) {
            col++;
            if (ch == '\n') {
                col--;
                break;
            }
        }
        file = filename;
    }

    this(ulong line, ulong col, string filename) {
        this.line = line;
        this.col = col;
        this.file = filename;
    }
}
