module errors;

import utils;
import tokenizer.location;

import std.exception;
import std.stdio;

// Runtime exceptions

abstract class RuntimeError : Exception {
    mixin locCtor;
    mixin basicExceptionCtors;
}

mixin makeRuntimeError!"TokenError";
mixin makeRuntimeError!"SyntaxError";
mixin makeRuntimeError!"SemanticError";
mixin makeRuntimeError!"ArgumentError";
mixin makeRuntimeError!"IndexError";
mixin makeRuntimeError!"TypeError";
mixin makeRuntimeError!"VariableError";

// Interpreter exceptions

abstract class InterpreterError : Exception {
    mixin basicExceptionCtors;
}

mixin makeInterpreterError!"InterpreterArgError";
mixin makeInterpreterError!"InterpreterFileError";

// Errors

class InternalError : Error {
    mixin basicExceptionCtors;
}

// Utilities

public void handleErrors(lazy void exec) {
    try
        exec();
    catch (RuntimeError e)
        stderr.writeln(e.loc, ": ", typeid(e).userText, ": ", e.message);
    catch (Exception e)
        stderr.writeln(typeid(e).userText, ": ", e.message);
}

private mixin template makeRuntimeError(string name) {
    mixin("class " ~ name ~ " : RuntimeError {
        @nogc @safe pure nothrow
        this(Loc location, string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
            super(location, msg, file, line, next);
        }
        @nogc @safe pure nothrow
        this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
            super(msg, file, line, next);
        }
        @nogc @safe pure nothrow
        this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__) {
            super(msg, file, line, next);
        }
    }");
}

private mixin template makeInterpreterError(string name) {
    mixin("class " ~ name ~ " : InterpreterError {
        mixin basicExceptionCtors;
    }");
}

/* For use with basicExceptionCtors.
   If a ctor is defiend in a class and a mixin defines another ctor,
   the one from the mixin gets ignored (dmd-2.101.2 and ldc-1.30.0, maybe bug?).

   If both defined in mixins, both are considered
*/
private mixin template locCtor() {
    Loc loc;
    @nogc @safe pure nothrow
    this(Loc location, string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        loc = location;
        super(msg, file, line, next);
    }

}
