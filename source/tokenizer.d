module tokenizer;

import std.exception;
import std.algorithm;
import std.uni;
import std.traits;
import std.conv;

enum TokenType {
    ID,
    NUMBER,
    LBRACKET,
    RBRACKET,
}

union Payload {
    string str;
    double num;
    typeof(null) null_;
}

class TokenException : Exception {
    mixin basicExceptionCtors;
}

struct Token {
    TokenType type;
    Payload payload;
    bool opEquals()(auto ref const TokenType t) const {
        return t == type;
    }

    this(S)(S str)
    if (isNarrowString!S) {
        type = TokenType.ID;
        payload.str = str.text;
    }

    this(double num) {
        type = TokenType.NUMBER;
        payload.num = num;
    }

    this(TokenType tok) {
        type = tok;
        with (TokenType) final switch (tok) {
            case ID:
                payload.str = payload.str.init;
                break;
            case NUMBER:
                payload.num = payload.num.init;
                break;
            case LBRACKET:
            case RBRACKET:
                payload.null_ = payload.null_.init;
                break;
        }
    }

    string toString() const {
        with (TokenType) final switch (type) {
            case ID:
                return "Id(" ~ payload.str ~ ")";
            case NUMBER:
                return "Number(" ~ payload.num.text ~ ")";
            case LBRACKET:
                return "LBRACKET";
            case RBRACKET:
                return "RBRACKET";
        }
    }

    auto to(TokenType tok)() {
        if (type == tok) {
            static if (tok == TokenType.NUMBER)
                return payload.num;
            else static if (tok == TokenType.ID)
                return payload.str;
        } else
            throw new TokenException("");
    }
}

bool isSpaceStr(S)(S str) {
    return all!(isSpace)(str);

}

Token[] tokenize(string chars) {
    char[] curr;
    Token[] outp;

    auto pushCurr() {
        if (!isSpaceStr(curr))
            try
                outp ~= Token(curr.to!double);
            catch (ConvException)
                outp ~= Token(curr);

        curr.length = 0;
    }

    foreach (ch; chars) {
        switch (ch) {
            case ' ':
            case '\0': .. case '\v':
                pushCurr;
                break;
            case '(':
                pushCurr;
                outp ~= Token(TokenType.LBRACKET);
                break;
            case ')':
                pushCurr;
                outp ~= Token(TokenType.RBRACKET);
                break;
            default:
                curr ~= (ch);
                break;
        }
    }
    pushCurr;

    return outp;
}
