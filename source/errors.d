module errors;

import std.exception;

class SyntaxError : Exception {
    mixin basicExceptionCtors;
}

class ArgumentError : Exception {
    mixin basicExceptionCtors;
}

class TypeError : Exception {
    mixin basicExceptionCtors;
}

class InternalError : Error {
    mixin basicExceptionCtors;
}
