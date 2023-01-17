module parser;

import errors;
import package_;
import tokenizer;
import types;

import std.array;

private Token* lastToken;
Loc getLoc(Token* tok) {
    if (tok)
        return tok.location;
    else
        return Loc(1, 1, null);
}

Package parsePackage(Token[] tokens, size_t h) {
    auto exps = appender!(Exp[]);
    while (tokens.length != 0)
        exps.put(parse(tokens));
    return new Package(exps.data, h);
}

Exp parse(Token[] tokens) {
    lastToken = tokens ? &tokens[0] : null;
    return parse(tokens);
}

Token[] checkEOI(return scope Token[] t) {
    if (t is null || t.length == 0)
        throw new SyntaxError(lastToken.getLoc(), "unexpected end of input");
    return t;
}

Exp parse(ref Token[] tokens) {
    auto token = tokens.checkEOI().front;
    lastToken = &tokens[0];
    tokens.popFront;
    if (token == TokenType.LBRACKET) {
        auto l = new List();
        while (tokens.checkEOI.front != TokenType.RBRACKET)
            l ~= parse(tokens);

        tokens.popFront;
        return l;
    } else if (token == TokenType.RBRACKET) {
        throw new SyntaxError(lastToken.getLoc(), "Unexpected )");
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
