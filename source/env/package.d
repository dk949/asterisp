module env;

import env.utils;

import types;

import std.math;
import std.range;

Env standard_environment;
static this() {
    standard_environment.addNumBinOp!("+");
    standard_environment.addNumBinOp!("-");
    standard_environment.addNumBinOp!("*");
    standard_environment.addNumBinOp!("/");
    standard_environment.addNumBinOp!(">");
    standard_environment.addNumBinOp!("<");
    standard_environment.addNumBinOp!(">=");
    standard_environment.addNumBinOp!("<=");
    standard_environment.addNumBinOp!("==");
    standard_environment[new Symbol("begin")] = new Function((List l) {
        return l.payload.back;
    });
    standard_environment[new Symbol("pi")] = new Number(PI);
}
