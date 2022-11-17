module env.utils;

import types;
import utils;

import std.functional;
import std.math;
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

void addMathConst(string K)(ref Env env) {

    mixin("auto num = new Number(" ~ K ~ ");");
    env[new Symbol("math." ~ K)] = num;
}
