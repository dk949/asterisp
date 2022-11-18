module env;

import env.utils;

import errors;
import types;
import utils;

import std.conv;
import std.math;
import std.range;
import std.stdio;

Env standard_environment;
static this() {
    standard_environment = construct!Env;

    // General
    standard_environment[new Symbol("*Main")] = new Function((List l) {
        l.forceCount!1;
        return l.front;
    });
    standard_environment[new Symbol("*Print")] = new Function((List l) {
        foreach (elem; l)
            write(elem);
        writeln("");
        return null;
    });

    // Math
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

    standard_environment.addMathConst!("E");
    standard_environment.addMathConst!("LN10");
    standard_environment.addMathConst!("LN2");
    standard_environment.addMathConst!("LOG10E");
    standard_environment.addMathConst!("LOG2");
    standard_environment.addMathConst!("LOG2E");
    standard_environment.addMathConst!("LOG2T");
    standard_environment.addMathConst!("M_1_PI");
    standard_environment.addMathConst!("M_2_PI");
    standard_environment.addMathConst!("M_2_SQRTPI");
    standard_environment.addMathConst!("PI");
    standard_environment.addMathConst!("PI_2");
    standard_environment.addMathConst!("PI_4");
    standard_environment.addMathConst!("SQRT1_2");
    standard_environment.addMathConst!("SQRT2");

    // Lists
    // construct
    standard_environment[new Symbol(",")] = new Function((List l) { return l; });
    // append
    standard_environment[new Symbol(",>")] = new Function((List l) {
        l.forceAtLeast!2;
        auto lst = l.front.forceCast!List(1.thArgOf(",>"));
        return new List(lst ~ l.drop(1));
    });
    // prepend
    standard_environment[new Symbol(",<")] = new Function((List l) {
        l.forceAtLeast!2;
        auto lst = l.front.forceCast!List(1.thArgOf(",<")).payload;
        return new List(l.drop(1) ~ lst);
    });

    // head
    standard_environment[new Symbol("^")] = new Function((List l) {
        l.forceCount!1;
        auto lst = l.front.forceCast!List(argOf("^"));
        return lst.front;
    });
    // tail
    standard_environment[new Symbol("$>")] = new Function((List l) {
        l.forceCount!1;
        auto lst = l.front.forceCast!List(argOf("$>"));
        return new List(lst[1 .. $]);
    });

    // first
    standard_environment[new Symbol("^>")] = new Function((List l) {
        l.forceCount!1;
        auto lst = l.front.forceCast!List(argOf("^>"));
        return new List(lst[0 .. ($ - 1)]);
    });
    // last
    standard_environment[new Symbol("$")] = new Function((List l) {
        l.forceCount!1;
        auto lst = l.front.forceCast!List(argOf("$"));
        return lst.back;
    });

    // element at
    standard_environment[new Symbol("^$")] = new Function((List l) {
        l.forceCount!2;
        auto lst = l.front.forceCast!List(1.thArgOf("^$"));
        auto idx = l.back.forceCast!Number(2.thArgOf("^$"));
        if (!idx.isWhole)
            throw new ArgumentError("Expected index to be a whole number");
        if (idx < 0)
            throw new IndexError("Expected index to be a positive number");
        if (idx >= lst.length)
            throw new IndexError(
                "Index " ~ idx.toString ~ " is out of range for list of length " ~ lst.length.text);
        return lst[cast(ulong) idx.payload];
    });

    // get length
    standard_environment[new Symbol("^?$")] = new Function((List l) {
        l.forceCount!1;
        auto lst = l.front.forceCast!List(argOf("^?$"));
        return new Number(lst.length);
    });
}
