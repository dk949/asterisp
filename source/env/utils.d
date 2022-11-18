module env.utils;

import types;
import utils;

import std.functional;
import std.math;
import std.range;
import std.stdio;

void addNumBinOp(string op)(ref Env env) {
    env[new Symbol(op)] = new Function((List l) {
        l.forceCount!2;

        const num1 = l.front.forceCast!Number(1.thArgOf(op)).payload;
        const num2 = l.back.forceCast!Number(1.thArgOf(op)).payload;
        return new Number(binaryFun!('a' ~ op ~ 'b')(num1, num2));
    });
}

void addMathConst(string K)(ref Env env) {
    mixin("auto num = new Number(" ~ K ~ ");");
    env[new Symbol("math." ~ K)] = num;
}
