import std.file;
import std.stdio;
import std.array;
import std.string;
import std.range;

enum {
    ARGS,
    IO
}

string format(string inp, int TAB = 4) {
    string[] txt;
    int[] open;
    int[] closed;

    int cntr = 0;
    foreach (line; inp.lineSplitter) {
        txt ~= line.strip;
        open ~= cast(int) txt[$ - 1].count('(');
        closed ~= cast(int) txt[$ - 1].count(')');
    }
    int[] indents;
    foreach (i, line; txt.enumerate) {
        if (i == 0)
            indents ~= 0;
        else {
            int netOpenPrev = open[i - 1] - closed[i - 1];
            int netCurr = open[i] - closed[i];
            writeln(line, ": net prev = ", netOpenPrev, " netCurr = ", netCurr);
            indents ~= indents[$ - 1];
            if (netCurr < 0)
                indents[$ - 1] += netCurr;
            else if (netOpenPrev > 0)
                indents[$ - 1] += netOpenPrev;
            if (indents[$ - 1] < 0) {
                writeln("indents[$-1] = ", indents[$ - 1]);
                indents[$ - 1] = 0;
            }
        }
    }
    auto a = appender!string;
    foreach (ind, t; indents.zip(txt)) {
        a.put(' '.repeat(TAB * ind));
        a.put(t);
        a.put('\n');
    }
    return a.data;
}

int die(int code, Str...,)(Str msg) {
    string pre;
    switch (code) {
        case ARGS:
            break;
        case IO:
            pre = "I/O: ";
            break;
        default:
            pre = "Internal: ";
    }
    stderr.writeln(pre, msg);
    return code;
}

string usage(string progname) {
    return "Usage: " ~ progname ~ " FILE";
}

int main(string[] args) {
    if (args.length != 2)
        return die!ARGS(args[0].usage);
    string text;
    try
        text = args[1].readText;
    catch (Exception e)
        return die!IO("Could not read file `", args[1], "`: ", e.message);

    writeln(text.format);
    return 0;
}
