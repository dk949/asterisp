module tokenizer.token;

import errors;

import std.conv;
import std.exception;
import std.traits;

enum TokenType {
    ID,
    NUMBER,
    STRING,
    LBRACKET,
    RBRACKET,
}

private union Payload {
    string str;
    double num;
    typeof(null) null_;
}

struct Token {
    private TokenType type;
    private Payload payload;

    bool opEquals(TokenType t) const pure nothrow {
        return t == type;
    }

    bool opEquals(N)(N num) const pure nothrow
    if (isNumeric!N) {
        if (type == TokenType.NUMBER)
            return payload.num == num;
        else
            return false;
    }

    bool opEquals(S)(S str) const pure nothrow
    if (isSomeString!S) {
        if (type == TokenType.ID)
            return payload.str == str.text;
        else
            return false;
    }

    bool opEquals(Token other) const pure nothrow {
        if (type == other.type)
            with (TokenType) final switch (type) {
            case ID:
                return payload.str == other.payload.str;
            case NUMBER:
                return payload.num == other.payload.num;
            case STRING:
                return payload.str == other.payload.str;
            case LBRACKET:
            case RBRACKET:
                return true;
        } else
            return false;
    }

    this(S)(S str) pure nothrow
    if (isNarrowString!S) {
        type = TokenType.ID;
        payload.str = str.text;
    }

    this(double num) pure nothrow {
        type = TokenType.NUMBER;
        payload.num = num;
    }

    this(TokenType tok) pure nothrow {
        type = tok;
        with (TokenType) final switch (tok) {
            case ID:
                payload.str = payload.str.init;
                break;
            case NUMBER:
                payload.num = payload.num.init;
                break;
            case STRING:
                payload.str = payload.str.init;
                break;
            case LBRACKET:
            case RBRACKET:
                payload.null_ = payload.null_.init;
                break;
        }
    }

    string toString() const pure nothrow {
        with (TokenType) final switch (type) {
            case ID:
                return "Id(" ~ payload.str ~ ")";
            case NUMBER:
                return "Number(" ~ payload.num.text.assertNotThrown ~ ")";
            case STRING:
                return "String(" ~ payload.str ~ ")";
            case LBRACKET:
                return "LBRACKET";
            case RBRACKET:
                return "RBRACKET";
        }
    }

    auto to(TokenType tok)() const pure {
        if (type == tok) {
            static if (tok == TokenType.NUMBER)
                return payload.num;
            else static if (tok == TokenType.ID)
                return payload.str;
        } else
            throw new TokenException("");
    }
}
