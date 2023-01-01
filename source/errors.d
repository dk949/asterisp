module errors;

import utils;
import tokenizer.location;

import std.exception;
import std.stdio;

mixin template locationExceptionCtors() {
    Loc loc;
    this(Loc location, string msg) @nogc @safe pure nothrow {
        this(msg);
    }

    @nogc @safe pure nothrow
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }

    @nogc @safe pure nothrow
    this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line, next);
    }
}

class TokenError : Exception {
    mixin locationExceptionCtors;
}

class SyntaxError : Exception {
    mixin locationExceptionCtors;
}

class SemanticError : Exception {
    mixin locationExceptionCtors;
}

class ArgumentError : Exception {
    mixin locationExceptionCtors;
}

class IndexError : Exception {
    mixin locationExceptionCtors;
}

class TypeError : Exception {
    mixin locationExceptionCtors;
}

class VariableError : Exception {
    mixin locationExceptionCtors;
}

class InterpreterError : Exception {
    mixin locationExceptionCtors;
}

class InternalError : Error {
    mixin locationExceptionCtors;
}

class InterpreterArgError : InterpreterError {
    mixin locationExceptionCtors;
}

class InterpreterFileError : InterpreterError {
    mixin locationExceptionCtors;
}

void handleErrors(lazy void exec) {
    try
        exec();
    catch (Exception e)
        stderr.writeln(typeid(e).userText, ": ", e.message);
}
