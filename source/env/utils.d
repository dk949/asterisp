module env.utils;

import types;
import utils;

import std.functional;
import std.range;

void addNumBinOp(string op)(ref Env env) {
    env[new Symbol(op)] = new Function((List l) {
        l.forceCount!2;
        return new Number(
            binaryFun!('a' ~ op ~ 'b')(
            l.front.forceCast!(Number)
            .payload,
            l.back.forceCast!(Number)
            .payload
        )
        );
    });
}
