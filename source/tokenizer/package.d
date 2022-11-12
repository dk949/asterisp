module tokenizer;

import utils;
import errors;

import std.exception;
import std.algorithm;
import std.traits;
import std.conv;
import std.range;
import std.exception;
import std.uni;
import std.stdio;

enum TokenType {
    ID,
    NUMBER,
    STRING,
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

private alias CharIt = immutable(char)*;

private enum State {
    Begin,
    Comment,
    ID,
    Number,
    Minus,
    StringStart,
    String,
}

Token[] tokenize(string chars) {
    Token[] outp;
    char[] curr;

    if (chars.empty)
        return outp;

    auto state = State.Begin;
    auto ch = chars.begin;

    auto toState(State s) {
        state = s;
    }

    auto consume() {
        curr ~= *ch;
        ch++;
    }

    auto drop() {
        ch++;
    }

    auto dupe() {
        curr ~= *ch;
    }

    auto store(State st) {
        final switch (st) {
            case State.Number:
                try
                    outp ~= Token(curr.to!double);
                catch (ConvException)
                    throw new TokenException("Invalid number " ~ curr.idup);
                break;
            case State.String:
                throw new TokenException("Strings not yet supported");
            case State.ID:
                outp ~= Token(curr);
                break;
            case State.Begin:
            case State.Minus:
            case State.Comment:
            case State.StringStart:
                throw new InternalError("Cannot store state " ~ st.text);
        }
        curr.clear;
    }

    auto sBegin() {
        switch (*ch) {
            case '(':
                outp ~= Token(TokenType.LBRACKET);
                drop;
                break;
            case ')':
                outp ~= Token(TokenType.RBRACKET);
                drop;
                break;
            case ' ':
            case '\0': .. case '\v':
                drop;
                break;
            case ';':
                toState(State.Comment);
                break;
            case '0': .. case '9':
                toState(State.Number);
                break;
            case '-':
                toState(State.Minus);
                break;
            case '"':
                toState(State.StringStart);
                break;
            default:
                toState(State.ID);
                break;
        }
    }

    auto sComment() {
        if (*ch == '\n')
            toState(State.Begin);
        drop;
    }

    auto sID() {
        switch (*ch) {
            case '"':
                throw new TokenException("unsexpected \" when parsing ID");
            case '(':
            case ')':
            case ' ':
            case '\0': .. case '\v':
                store(State.ID);
                toState(State.Begin);
                break;
            default:
                consume;
        }
    }

    auto sNumber() {
        switch (*ch) {
            case '0': .. case '9':
            case '.':
            case '-':
            case 'e': // Scientific notation
                consume;
                break;
            default:
                toState(State.Begin);
                store(State.Number);
                break;
        }
    }

    auto sMinus() {
        if (*ch != '-')
            throw new InternalError("Expected - found " ~ *ch);
        if (ch + 1 != chars.end && isNumber(*(ch + 1)))
            toState(State.Number);
        else
            toState(State.ID);

    }

    auto sStringStart() {
        if (*ch != '"')
            throw new InternalError("Expected \" found " ~ *ch);
        drop;
        toState(State.String);
    }

    auto sString() {
        switch (*ch) {
            case '"':
                drop;
                toState(State.Begin);
                store(State.String);
                break;
            case '\\':
                throw new TokenException("Escape characters not yet supported");
            default:
                consume;
        }
        drop;
        toState(State.String);
    }

    while (ch != chars.end) {
        final switch (state) {
            case State.Begin:
                sBegin;
                break;
            case State.Comment:
                sComment;
                break;
            case State.ID:
                sID;
                break;
            case State.Number:
                sNumber;
                break;
            case State.Minus:
                sMinus;
                break;
            case State.StringStart:
                sStringStart;
                break;
            case State.String:
                sString;
                break;
        }
    }
    final switch (state) {
        case State.StringStart:
            throw new TokenException("Unexpected \" at end of input");
        case State.Minus:
            throw new InternalError("Unstored Minus at end of input");
        case State.String:
            throw new TokenException("Unterminated string at end of input");
        case State.ID:
        case State.Number:
            store(state);
            break;
        case State.Comment:
        case State.Begin: // Do nothing
            break;
    }

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
        const charsInId = "yasdf98u3_/..]][]]\\@@$%^&*".tokenize();
        const pinteger = "37".tokenize();
        const ninteger = "-37".tokenize();
        const pfloating = "37.89".tokenize();
        const nfloating = "-37.89".tokenize();
        const traildec = "37.".tokenize();
        const pscip = "1.7e10".tokenize();
        const nscip = "-1.7e10".tokenize();
        const pscin = "1.7e-10".tokenize();
        const nscin = "-1.7e-10".tokenize();

        assert(lbracket.length == 1 && lbracket[0] == LBRACKET, "left brakcet");
        assert(rbracket.length == 1 && rbracket[0] == RBRACKET, "right brakcet");
        assert(id.length == 1 && id[0] == ID && id[0] == "hello", "ID");
        assert(charsInId.length == 1 && charsInId[0] == ID && charsInId[0] == "yasdf98u3_/..]][]]\\@@$%^&*", "Id with weird characters");
        assert(pinteger.length == 1 && pinteger[0] == NUMBER && pinteger[0] == 37, "positive integer");
        assert(ninteger.length == 1 && ninteger[0] == NUMBER && ninteger[0] == -37, "negative integer");
        assert(pfloating.length == 1 && pfloating[0] == NUMBER && pfloating[0] == 37.89, "positive float");
        assert(nfloating.length == 1 && nfloating[0] == NUMBER && nfloating[0] == -37.89, "negative float");
        assert(traildec.length == 1 && traildec[0] == NUMBER && traildec[0] == 37., "trailing decimal point");
        assert(pscip.length == 1 && pscip[0] == NUMBER && pscip[0] == 1.7e10, "positive mantissa positive exponent");
        assert(nscip.length == 1 && nscip[0] == NUMBER && nscip[0] == -1.7e10, "negative mantissa positive exponent");
        assert(pscin.length == 1 && pscin[0] == NUMBER && pscin[0] == 1.7e-10, "positive mantissa negative exponent");
        assert(nscin.length == 1 && nscin[0] == NUMBER && nscin[0] == -1.7e-10, "negative mantissa negative exponent");

        assertThrown!TokenException("1.2.3".tokenize, "too many decimal points");
        assertThrown!TokenException("1e5e5".tokenize, "too many e");
        assertThrown!TokenException("1e".tokenize, "trailing e");
        assertThrown!TokenException("1e.".tokenize, "trailing e and decimal point");
        assertThrown!TokenException("1.e".tokenize, "trailing decimal point and e");

        // Many tokens
        const openOpenCLose = "(()".tokenize();
        const wsopenOpenCLose = "   (  (  \n\t)\n ".tokenize();
        const closeIdNumOpen = ")i 27(".tokenize();
        const wscloseIdNumOpen = "  )  i\n27\t(".tokenize();
        const define = "(define hello 47)".tokenize();
        const subtract = "(- 49 hello)".tokenize();

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
        assert(subtract == [
                Token(LBRACKET), Token("-"), Token(49), Token("hello"),
                Token(RBRACKET)
            ],
            "left, id = -, num = 49, id = hello, right"
        );
    }
}
