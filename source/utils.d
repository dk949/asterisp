module utils;

import errors;
import types;

import std.conv;

string userText(T)(T t) {
    string s = t.text;
    if (s.length == 0)
        return "";
    if (s[0] == '.' || s[$ - 1] == '.')
        throw new InternalError(__FUNCTION__, " is meant to be used on type names which cannot begin or end in `.`");
    long count = s.length;
    foreach_reverse (ch; s) {
        if (ch == '.')
            return s[count .. $];
        count--;
    }
    return s;
}

unittest {
    import std.exception;

    assert("".userText == "", "empty");
    assert("hello".userText == "hello", "no dot");
    assert("hello.hi".userText == "hi", "one dot");
    assert("hello.hi.there".userText == "there", "two dots");

    assertThrown!InternalError(".hello.hi.there".userText, "leading dot");
    assertThrown!InternalError("hello.hi.there.".userText, "trailing dot");
    assertThrown!InternalError(".".userText, "dot only");
}

T forceCast(T, W)(W what, string kind = "arguent") {
    if (auto output = cast(T) what) {
        return output;
    } else {
        throw new TypeError(
            "Expected " ~ kind ~ " to be of type "
                ~ typeid(T)
                .userText
                ~ ", got "
                ~ typeid(what)
                .userText
        );
    }
}

void forceCount(size_t n, L)(L l, string kind = "argument(s)")
if (is(L == List) || is(L == Exp[])) {
    if (l.length != n)
        throw new ArgumentError(
            "Expected "
                ~ n.text
                ~ " " ~ kind ~ ", got "
                ~ l.length.text
        );
}

void forceAtLeast(size_t n, L)(inout(L) l, string kind = "argument(s)")
if (is(L == List) || is(L == Exp[])) {
    if (l.length < n)
        throw new ArgumentError(
            "Expected at least "
                ~ n.text
                ~ " " ~ kind ~ ", got "
                ~ l.length.text
        );
}

enum isClass(T) = is(T : Object);
unittest {
    class C {
    }

    struct S {
    }

    static assert(isClass!C);
    static assert(!isClass!S);
    static assert(!isClass!int);
    static assert(!isClass!string);
}

T construct(T, Args...)(Args args) {
    static if (isClass!T)
        return new T(args);
    else
        return T(args);
}

auto ref dbg(string msg, T)(auto ref T t) {
    stderr.writeln(msg, t);
    return t;
}

void clear(R)(ref R r) {
    r.length = 0;
}
