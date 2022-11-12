module utils;

import errors;
import types;

import std.conv;
import std.traits;
import std.range;

T forceCast(T, W)(W what) {
    if (auto output = cast(T) what) {
        return output;
    } else {
        throw new TypeError(
            "Expected arguent to be of type "
                ~ typeid(W)
                .text
                .text
                ~ ", got "
                ~ typeid(T).text
                .text
        );
    }
}

void forceCount(size_t n, L, string func = __FUNCTION__)(L l)
if (is(L == List) || is(L == Exp[])) {
    if (l.length != n)
        throw new ArgumentError(
            func
                ~ ": Expected "
                ~ n.text
                ~ " arguments, got "
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

void clear(R)(ref R r){
    r.length = 0;
}
