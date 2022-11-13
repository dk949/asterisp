module parser;

import errors;
import tokenizer;
import types;

import std.conv;
import std.range;
import std.stdio;

Exp parse(Token[] tokens) {
    auto e = _parse(tokens);
    if (tokens.length > 0)
        throw new SyntaxError("Unexpected input after EOF");
    return e;
}

private Exp _parse(ref Token[] tokens) {
    if (tokens is null || tokens.length == 0)
        throw new SyntaxError("unexpected end of input");
    auto token = tokens.front;
    tokens.popFront;
    if (token == TokenType.LBRACKET) {
        if (tokens.length == 0)
            throw new SyntaxError("unexpected end of input");
        auto l = new List();
        while (tokens.front != TokenType.RBRACKET)
            l ~= _parse(tokens);
        tokens.popFront;
        return l;
    } else if (token == TokenType.RBRACKET) {
        throw new SyntaxError("Unexpected )");
    } else
        return atom(token);
}

private Atom atom(Token token) {
    if (token == TokenType.NUMBER)
        return new Number(token.to!(TokenType.NUMBER));
    else if (token == TokenType.ID)
        return new Symbol(token.to!(TokenType.ID));
    else
        throw new InternalError("Unexpected token type");
}
