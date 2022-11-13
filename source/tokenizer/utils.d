module tokenizer.utils;
import std.traits;
import std.algorithm;
import std.uni;
import std.exception;

bool isSpaceStr(S)(S str) pure nothrow {
    return str.all!isWhite.assertNotThrown;
}

unittest {

    auto trueTests = [
        "empty": "",
        "one space": " ",
        "two spaces": "  ",
        "newline": "\n",
        "space and newline": " \n",
    ];

    auto falseTests = [
        "one char": "a",
        "two chars": "ab",
        "char and space": " b",
        "char and space 2": "b ",
        "many spaces and char": "    \n    \t     )        ",
    ];

    foreach (msg, test; trueTests)
        assert(test.isSpaceStr, msg);

    foreach (msg, test; falseTests)
        assert(!test.isSpaceStr, msg);

}

ElementType!R* begin(R)(auto ref R r)
if (!isSomeString!R && isInputRange!R) {
    return &r.front;
}

ElementType!R* end(R)(auto ref R r)
if (!isSomeString!R && isBidirectionalRange!R) {
    return (&r.back) + 1;
}

auto begin(R)(auto ref R r)
if (isSomeString!R) {
    return &r[0];
}

auto end(R)(auto ref R r)
if (isSomeString!R) {
    return (&r[$ - 1]) + 1;
}
