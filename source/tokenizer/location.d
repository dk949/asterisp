module tokenizer.location;
import tokenizer.utils;
import utils;

import std.algorithm;
import std.conv;

struct Loc {
    ulong line = 0;
    ulong col = 0;
    string file = null;

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

    pure
    string toString() const {
        const filename = file.coal("UNKNOWN");
        const lineNo = line ? line.to!string : "UNKOWN";
        const colNo = col ? col.to!string : "UNKOWN";
        return filename ~ ":" ~ lineNo ~ ":" ~ colNo;
    }
}
