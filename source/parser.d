module parser;

import errors;
import types;

import std.conv;
import std.range;

string[] tokenize(string chars) {
    return chars
        .replace("(", " ( ")
        .replace(")", " ) ")
        .split();
}

Exp parse(string[] tokens) {
    return _parse(tokens);
}

private Exp _parse(ref string[] tokens)
in (tokens !is null) {
    if (tokens.length == 0)
        throw new SyntaxError("unexpected EOF");
    auto token = tokens.front;
    tokens.popFront;
    if (token == "(") {
        auto l = new List();
        while (tokens.front != ")")
            l ~= _parse(tokens);
        tokens.popFront;
        return l;
    } else if (token == ")") {
        throw new SyntaxError("Unexpected )");
    } else
        return atom(token);
}

private Atom atom(string token)
in (token !is null) {
    try
        return new Number(token.to!double);
    catch (ConvException)
        return new Symbol(token);
}
