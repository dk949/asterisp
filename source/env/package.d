module env;

import env.utils;

import types;
import utils;

import std.math;
import std.range;

Env standard_environment;
static this() {
    standard_environment = construct!Env;
    standard_environment.addNumBinOp!("+");
    standard_environment.addNumBinOp!("-");
    standard_environment.addNumBinOp!("*");
    standard_environment.addNumBinOp!("/");
    standard_environment.addNumBinOp!(">");
    standard_environment.addNumBinOp!("<");
    standard_environment.addNumBinOp!(">=");
    standard_environment.addNumBinOp!("<=");
    standard_environment.addNumBinOp!("==");
    standard_environment.addNumBinOp!("||");
    standard_environment.addNumBinOp!("&&");
    standard_environment[new Symbol("*Begin")] = new Function((List l) {
        return l.back;
    });
    standard_environment[new Symbol("math.pi")] = new Number(PI);
    standard_environment[new Symbol("math.e")] = new Number(E);
}
