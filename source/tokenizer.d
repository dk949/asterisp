module tokenizer;

import std.exception;
import std.algorithm;
import std.traits;
import std.conv;
import std.range;
import std.exception;
import std.uni;

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

    bool opEquals()(auto ref const Token other) const pure nothrow {
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

bool isSpaceStr(S)(S str) pure nothrow {
    return str.all!isWhite.assertNotThrown;
}

unittest {
    auto trueTests = [
        "empty": "",
        "one space": " ",
        "two spaces": "  ",
        "newline": "\n",
        "space and newline": " \n",
    ];

    auto falseTests = [
        "one char": "a",
        "two chars": "ab",
        "char and space": " b",
        "char and space 2": "b ",
        "many spaces and char": "    \n    \t     )        ",
    ];

    foreach (msg, test; trueTests)
        assert(test.isSpaceStr, msg);

    foreach (msg, test; falseTests)
        assert(!test.isSpaceStr, msg);

}

Token[] tokenize(string chars) pure nothrow {
    long currStart, currEnd;
    Token[] outp;

    auto pushCurr() nothrow {
        const tmp = chars[currStart .. currEnd];
        if (!isSpaceStr(tmp))
            outp ~= Token(tmp.to!double)
                .ifThrown!ConvException(Token(tmp))
                .assertNotThrown;
        currStart = currEnd;
    }

    auto skipCurr() nothrow {
        assert(currStart == currEnd);
        currStart++;
        currEnd++;
    }

    foreach (ch; chars) {
        import std.stdio;

        switch (ch) {
            case ' ':
            case '\0': .. case '\v':
                pushCurr;
                skipCurr;
                break;
            case '(':
                pushCurr;
                skipCurr;
                outp ~= Token(TokenType.LBRACKET);
                break;
            case ')':
                pushCurr;
                skipCurr;
                outp ~= Token(TokenType.RBRACKET);
                break;
            default:
                currEnd++;
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

        assert(empty.length == 0, "Empty string should produce no tokens");
        assert(wsempty.length == 0, "String with just spaces should produce no tokens");

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

        assert(lbracket.length == 1 && lbracket[0] == LBRACKET, "left brakcet");
        assert(rbracket.length == 1 && rbracket[0] == RBRACKET, "right brakcet");
        assert(id.length == 1 && id[0] == ID && id[0] == "hello", "ID");
        assert(charsInId.length == 1 && charsInId[0] == ID && charsInId[0] == "89yasdf98u3_/..]][]]\\@@$%^&*", "Id with weird cgaracters");
        assert(pinteger.length == 1 && pinteger[0] == NUMBER && pinteger[0] == 37, "positive integer");
        assert(ninteger.length == 1 && ninteger[0] == NUMBER && ninteger[0] == -37, "negative integer");
        assert(pfloating.length == 1 && pfloating[0] == NUMBER && pfloating[0] == 37.89, "positive float");
        assert(nfloating.length == 1 && nfloating[0] == NUMBER && nfloating[0] == -37.89, "negative float");
        assert(pscip.length == 1 && pscip[0] == NUMBER && pscip[0] == 1.7e10, "positive mantissa positive exponent");
        assert(nscip.length == 1 && nscip[0] == NUMBER && nscip[0] == -1.7e10, "negative mantissa positive exponent");
        assert(pscin.length == 1 && pscin[0] == NUMBER && pscin[0] == 1.7e-10, "positive mantissa negative exponent");
        assert(nscin.length == 1 && nscin[0] == NUMBER && nscin[0] == -1.7e-10, "negative mantissa negative exponent");

        // Many tokens
        const openOpenCLose = "(()".tokenize();
        const wsopenOpenCLose = "   (  (  \n\t)\n ".tokenize();
        const closeIdNumOpen = ")i 27(".tokenize();
        const wscloseIdNumOpen = "  )  i\n27\t(".tokenize();
        const define = "(define hello 47)".tokenize();

        assert(openOpenCLose == [
                Token(LBRACKET), Token(LBRACKET), Token(RBRACKET),
            ],
            "left, left, right"
        );
        assert(wsopenOpenCLose == [
                Token(LBRACKET), Token(LBRACKET), Token(RBRACKET),
            ], "left, left, right despite white space");

        assert(closeIdNumOpen == [
                Token(RBRACKET), Token("i"), Token(27), Token(LBRACKET),
            ],
            "right, id = i, num = 27, left"
        );
        assert(wscloseIdNumOpen == [
                Token(RBRACKET), Token("i"), Token(27), Token(LBRACKET),
            ],
            "right, id = i, num = 27, left, despite white space"
        );
        assert(define == [
                Token(LBRACKET), Token("define"), Token("hello"), Token(47),
                Token(RBRACKET)
            ],
            "left, id = define, id = hello, num = 47, right"
        );
    }
}
