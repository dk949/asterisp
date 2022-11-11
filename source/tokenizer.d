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
    bool opEquals(TokenType t) const {
        return t == type;
    }

    bool opEquals(N)(N num) const
    if (isNumeric!N) {
        if (type == TokenType.NUMBER)
            return payload.num == num;
        else
            return false;
    }

    bool opEquals(S)(S str) const
    if (isSomeString!S) {
        if (type == TokenType.ID)
            return payload.str == str.text;
        else
            return false;
    }

    bool opEquals()(auto ref const Token other) const {
        if (type == other.type)
            with (TokenType) final switch (type) {
            case ID:
                return payload.str == other.payload.str;
            case NUMBER:
                return payload.num == other.payload.num;
            case LBRACKET:
            case RBRACKET:
                return true;
        } else
            return false;
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

unittest {
    with (TokenType) {

        // 0 tokens
        const empty = "".tokenize();
        const wsempty = "  \n".tokenize();

        // 1 token
        const lbracket = "(".tokenize();
        const rbracket = ")".tokenize();
        const id = "hello".tokenize();
        const charsInId = "89yasdf98u3_/..]][]]\\@@$%^&*".tokenize();
        const pinteger = "37".tokenize();
        const ninteger = "-37".tokenize();
        const pfloating = "37.89".tokenize();
        const nfloating = "-37.89".tokenize();
        const pscip = "1.7e10".tokenize();
        const nscip = "-1.7e10".tokenize();
        const pscin = "1.7e-10".tokenize();
        const nscin = "-1.7e-10".tokenize();

        // Many tokens
        const openOpenCLose = "(()".tokenize();
        const wsopenOpenCLose = "   (  (  \n\t)\n ".tokenize();
        const closeIdNumOpen = ")i 27(".tokenize();
        const wscloseIdNumOpen = "  )  i\n27\t(".tokenize();

        assert(empty.length == 0);
        assert(wsempty.length == 0);

        // 1 token
        assert(lbracket.length == 1 && lbracket[0] == LBRACKET);
        assert(rbracket.length == 1 && rbracket[0] == RBRACKET);
        assert(id.length == 1 && id[0] == ID && id[0] == "hello");
        assert(charsInId.length == 1 && charsInId[0] == ID && charsInId[0] == "89yasdf98u3_/..]][]]\\@@$%^&*");
        assert(pinteger.length == 1 && pinteger[0] == NUMBER && pinteger[0] == 37);
        assert(ninteger.length == 1 && ninteger[0] == NUMBER && ninteger[0] == -37);
        assert(pfloating.length == 1 && pfloating[0] == NUMBER && pfloating[0] == 37.89);
        assert(nfloating.length == 1 && nfloating[0] == NUMBER && nfloating[0] == -37.89);
        assert(pscip.length == 1 && pscip[0] == NUMBER && pscip[0] == 1.7e10);
        assert(nscip.length == 1 && nscip[0] == NUMBER && nscip[0] == -1.7e10);
        assert(pscin.length == 1 && pscin[0] == NUMBER && pscin[0] == 1.7e-10);
        assert(nscin.length == 1 && nscin[0] == NUMBER && nscin[0] == -1.7e-10);

        // Many tokens
        assert(openOpenCLose == [
                Token(LBRACKET), Token(LBRACKET), Token(RBRACKET)
            ]);
        assert(wsopenOpenCLose == [
                Token(LBRACKET), Token(LBRACKET), Token(RBRACKET)
            ]);
        assert(closeIdNumOpen == [
                Token(RBRACKET), Token("i"), Token(27), Token(LBRACKET)
            ]);
        assert(wscloseIdNumOpen == [
                Token(RBRACKET), Token("i"), Token(27), Token(LBRACKET)
            ]);
    }
}
