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

void forceCount(size_t n, string func = __FUNCTION__)(List l) {
    if (l.payload.length != n)
        throw new ArgumentError(
            func
                ~ ": Expected "
                ~ n.text
                ~ " arguments, got "
                ~ l.payload.length.text
        );
}
