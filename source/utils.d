module utils;

import errors;
import types;

import std.conv;

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
