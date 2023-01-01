module errors;

import utils;

import std.exception;
import std.stdio;

class TokenError : Exception {
    mixin basicExceptionCtors;
}

class SyntaxError : Exception {
    mixin basicExceptionCtors;
}

class SemanticError : Exception {
    mixin basicExceptionCtors;
}

class ArgumentError : Exception {
    mixin basicExceptionCtors;
}

class IndexError : Exception {
    mixin basicExceptionCtors;
}

class TypeError : Exception {
    mixin basicExceptionCtors;
}

class VariableError : Exception {
    mixin basicExceptionCtors;
}

class InterpreterError : Exception {
    mixin basicExceptionCtors;
}

class InternalError : Error {
    mixin basicExceptionCtors;
}

class InterpreterArgError : InterpreterError {
    mixin basicExceptionCtors;
}

class InterpreterFileError : InterpreterError {
    mixin basicExceptionCtors;
}

void handleErrors(lazy void exec) {
    try
        exec();
    catch (Exception e)
        stderr.writeln(typeid(e).userText, ": ", e.message);
}
