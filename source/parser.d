module parser;

import errors;
import package_;
import tokenizer;
import types;

import std.array;

Package parsePackage(Token[] tokens, size_t h) {
    auto exps = appender!(Exp[]);
    while (tokens.length != 0)
        exps.put(parse(tokens));
    return new Package(exps.data, h);
}

Exp parse(Token[] tokens) {
    return parse(tokens);
}

Exp parse(ref Token[] tokens) {
    if (tokens is null || tokens.length == 0)
        throw new SyntaxError("unexpected end of input");
    auto token = tokens.front;
    tokens.popFront;
    if (token == TokenType.LBRACKET) {
        if (tokens.length == 0)
            throw new SyntaxError("unexpected end of input");
        auto l = new List();
        while (tokens.front != TokenType.RBRACKET)
            l ~= parse(tokens);
        tokens.popFront;
        return l;
    } else if (token == TokenType.RBRACKET) {
        throw new SyntaxError("Unexpected )");
    } else
        return atom(token);
}

private Atom atom(Token token) {
    with (TokenType) {
        final switch (token.type) {
            case ID:
                return new Symbol(token.to!(TokenType.ID));
            case NUMBER:
                return new Number(token.to!(TokenType.NUMBER));
            case STRING:
                return new String(token.to!(TokenType.STRING));
            case LBRACKET:
            case RBRACKET:
                throw new InternalError("Unexpected token type in atom");
        }
    }
}

/// atom
unittest {
    import tokenizer.token;

    import std.exception;

    assertThrown!InternalError(Token(TokenType.LBRACKET).atom());
    assertThrown!InternalError(Token(TokenType.RBRACKET).atom());

    const sym = Token("hello").atom();
    assert(cast(Symbol) sym);
    assert(cast(Symbol) sym == new Symbol("hello"));

    const num = Token(29839).atom();
    assert(cast(Number) num);
    assert(cast(Number) num == new Number(29839));

    const str = Token(tokStr("some string")).atom();
    assert(cast(String) str);
    assert(cast(String) str == new String("some string"));
}
