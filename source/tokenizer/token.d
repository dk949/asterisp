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

struct TokStr(S)
if (isSomeString!S) {
    S s;
}

TokStr!(S) tokStr(S)(S s)
if (isSomeString!S) {
    return TokStr!S(s);
}

enum isTokStr(TS) = __traits(isSame, TemplateOf!(TS), TokStr);

struct Token {
    private TokenType m_type;
    private Payload payload;

    TokenType type() const {
        return m_type;
    }

    bool opEquals(TokenType t) const pure nothrow {
        return t == m_type;
    }

    bool opEquals(N)(N num) const pure nothrow
    if (isNumeric!N) {
        if (m_type == TokenType.NUMBER)
            return payload.num == num;
        else
            return false;
    }

    bool opEquals(S)(S str) const pure
    if (isSomeString!S) {
        if (m_type == TokenType.ID)
            return payload.str == str.text;
        else
            return false;
    }

    bool opEquals(TS)(TS tokS) const pure
    if (isTokStr!TS) {
        if (m_type == TokenType.STRING)
            return payload.str == tokS.s.text;
        else
            return false;
    }

    bool opEquals(Token other) const pure nothrow {
        if (m_type == other.m_type)
            with (TokenType) final switch (m_type) {
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

    this(double num) pure nothrow {
        m_type = TokenType.NUMBER;
        payload.num = num;
    }

    this(S)(S str) pure
    if (isSomeString!S) {
        m_type = TokenType.ID;
        payload.str = str.text;
    }

    this(TS)(TS tokS) pure
    if (isTokStr!TS) {
        m_type = TokenType.STRING;
        payload.str = tokS.s.text;
    }

    this(TokenType tok) pure nothrow {
        m_type = tok;
        payload = payload.init;
    }

    string toString() const pure nothrow {
        with (TokenType) final switch (m_type) {
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
        if (m_type == tok) {
            static if (tok == TokenType.NUMBER)
                return payload.num;
            else static if (tok == TokenType.ID || tok == TokenType.STRING)
                return payload.str;
        } else
            throw new TokenError("Cannot convert " ~ m_type.text ~ " to " ~ tok.text);
    }
}

/// Token(double)
unittest {
    with (TokenType) {
        const zero = Token(0);
        const number = Token(879.253489);

        assert(zero.m_type == NUMBER && zero.payload.num == 0, "number token 0");
        assert(number.m_type == NUMBER && number.payload.num == 879.253489, "number token 879.253489");
    }
}

/// Token(string)
unittest {
    with (TokenType) {
        const emptyId = Token("");
        const emptyWId = Token(""w);
        const emptyDId = Token(""d);
        const textId = Token("hello");
        const textWId = Token("hello"w);
        const textDId = Token("hello"d);

        assert(emptyId.m_type == ID && emptyId.payload.str == "", "empty utf8 ID");
        assert(emptyWId.m_type == ID && emptyWId.payload.str.wtext == ""w, "empty utf16 ID");
        assert(emptyDId.m_type == ID && emptyDId.payload.str.dtext == ""d, "empty utf32 ID");
        assert(textId.m_type == ID && textId.payload.str == "hello", `"hello" utf8 ID`);
        assert(textWId.m_type == ID && textWId.payload.str.wtext == "hello"w, `"hello" utf16 ID`);
        assert(textDId.m_type == ID && textDId.payload.str.dtext == "hello"d, `"hello" utf32 ID`);
    }
}

/// Token(TokStr)
unittest {
    import std.stdio;

    with (TokenType) {
        const emptyStr = Token(tokStr(""));
        const emptyWStr = Token(tokStr(""w));
        const emptyDStr = Token(tokStr(""d));
        const textStr = Token(tokStr("hello"));
        const textWStr = Token(tokStr("hello"w));
        const textDStr = Token(tokStr("hello"d));

        assert(emptyStr.m_type == STRING && emptyStr.payload.str == "", "empty utf8 string");
        assert(emptyWStr.m_type == STRING && emptyWStr.payload.str.wtext == ""w, "empty utf16 string");
        assert(emptyDStr.m_type == STRING && emptyDStr.payload.str.dtext == ""d, "empty utf32 string");
        assert(textStr.m_type == STRING && textStr.payload.str == "hello", `"hello" utf8 string`);
        assert(textWStr.m_type == STRING && textWStr.payload.str.wtext == "hello"w, `"hello" utf16 string`);
        assert(textDStr.m_type == STRING && textDStr.payload.str.dtext == "hello"d, `"hello" utf32 string`);
    }
}

/// Token(TokenType)
unittest {
    with (TokenType) {
        const emptyId = Token(ID);
        const emptyNum = Token(NUMBER);
        const emptyStr = Token(STRING);
        const lbrack = Token(LBRACKET);
        const rbrack = Token(RBRACKET);

        assert(emptyId.m_type == ID && emptyId.payload.str == null, "empty ID");
        assert(emptyNum == NUMBER && emptyNum.payload.num == 0, "empty number");
        assert(emptyStr == STRING && emptyStr.payload.str == null, "empty string");
        assert(lbrack == LBRACKET && lbrack.payload.null_ == null, "left bracket");
        assert(rbrack == RBRACKET && rbrack.payload.null_ == null, "right bracket");
    }
}
