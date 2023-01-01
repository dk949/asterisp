module utils;

import errors;
import types;

import std.conv;
import std.traits;

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

T forceCast(T, W)(W what, string kind) {
    if (auto output = cast(T) what) {
        return output;
    } else {
        throw new TypeError(
            "Expected " ~ kind ~ " to be a "
                ~ typeid(T)
                .userText
                ~ ", got "
                ~ typeid(what)
                .userText
        );
    }
}

private string th(long i) {
    static immutable string[] suffixes = ["th", "st", "nd", "rd"];

    // TODO: Why am i converting it to string?
    const outp = i.text;
    const last = outp[$ - 1];
    const special = outp.length > 1 && outp[$ - 2] == '1';

    switch (last) {
        case '1':
        case '2':
        case '3':
            if (special)
                goto case '0';
            return outp ~ suffixes[last - '0'];
        case '0':
        case '4': .. case '9':
            return outp ~ suffixes[0];
        default:
            throw new InternalError("Cannot ith number " ~ outp);
    }
}

// th
unittest {
    assert(0.th == "0th", "0th");
    assert(1.th == "1st", "1st");
    assert(2.th == "2nd", "2nd");
    assert(3.th == "3rd", "3rd");
    assert(4.th == "4th", "4th");
    assert(9.th == "9th", "9th");

    assert(10.th == "10th", "10th");
    assert(11.th == "11th", "11th");
    assert(12.th == "12th", "12th");
    assert(13.th == "13th", "13th");
    assert(14.th == "14th", "14th");
    assert(19.th == "19th", "19th");

    assert(21.th == "21st", "21st");
    assert(22.th == "22nd", "22nd");

    assert(100.th == "100th", "100th");
    assert(101.th == "101st", "101st");
    assert(102.th == "102nd", "102nd");
    assert(103.th == "103rd", "103rd");

    assert(111.th == "111th", "111th");
    assert(112.th == "112th", "112th");
    assert(113.th == "113th", "113th");

    assert((-1).th == "-1st", "-1st");
    assert((-2).th == "-2nd", "-2nd");
    assert((-3).th == "-3rd", "-3rd");
    assert((-4).th == "-4th", "-4th");
    assert((-9).th == "-9th", "-9th");

    assert((-10).th == "-10th", "-10th");
    assert((-11).th == "-11th", "-11th");
    assert((-12).th == "-12th", "-12th");
    assert((-13).th == "-13th", "-13th");
    assert((-14).th == "-14th", "-14th");
    assert((-19).th == "-19th", "-19th");
}

string thArgOf(long n, string what) {
    return n.th ~ " argument of " ~ what;
}

string argOf(string what) {
    return "argument of `" ~ what ~ "`";
}

void forceCount(size_t n, L)(L l, string kind)
if (is(L == List) || is(L == Exp[])) {
    if (l.length != n)
        throw new ArgumentError(
            "Expected "
                ~ n.text
                ~ " " ~ kind ~ ", got "
                ~ l.length.text
        );
}

void forceAtLeast(size_t n, L)(inout(L) l, string kind)
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

/**
 *
 * Params:
 *   a = First expression. Always evaluated once
 *   b = Second expression. Evaluated once if `a` is falsy
 * Returns:
 *   `a` if `a` is truthy, other wise `b`
 */
CommonType!(A, B) coal(A, B)(lazy A a, lazy B b)
if (!is(CommonType!(A, B) == void)) {
    if(const res = a)
        return res;
    else
        return b;
}
