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
    standard_environment[new Symbol("begin")] = new Function((List l) {
        return l.back;
    });
    standard_environment[new Symbol("pi")] = new Number(PI);
    standard_environment[new Symbol("e")] = new Number(E);
}
