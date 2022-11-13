module tokenizer.tokenizer;
import tokenizer.token;
import std.array;
import tokenizer.utils;
import errors;
import std.conv;
import std.uni;
import std.traits;

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

struct Tokenizer {
    private string m_input;
    private Appender!(char[]) m_currToken;
    private Appender!(Token[]) m_tokenized;
    private State m_state;
    private CharIt m_char;

    this(string input) {
        m_input = input;
        m_currToken = appender!(char[]);
        m_tokenized = appender!(Token[]);
        m_state = State.Begin;
        m_char = input.empty ? null : input.begin;
    }

    Token[] run() {
        if (!m_char)
            return [];

        while (m_char != m_input.end) {
            final switch (m_state) {
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
        final switch (m_state) {
            case State.StringStart:
                throw new TokenException("Unexpected \" at end of input");
            case State.Minus:
                throw new InternalError("Unstored Minus at end of input");
            case State.String:
                throw new TokenException("Unterminated string at end of input");
            case State.ID:
            case State.Number:
                store(m_state);
                break;
            case State.Comment:
            case State.Begin: // Do nothing
                break;
        }
        return m_tokenized.data;
    }

    private void sBegin() {
        switch (*m_char) {
            case '(':
                m_tokenized.put(Token(TokenType.LBRACKET));
                drop;
                break;
            case ')':
                m_tokenized.put(Token(TokenType.RBRACKET));
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

    private void sComment() {
        if (*m_char == '\n')
            toState(State.Begin);
        drop;
    }

    private void sID() {
        switch (*m_char) {
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

    private void sNumber() {
        switch (*m_char) {
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

    private void sMinus() {
        if (*m_char != '-')
            throw new InternalError("Expected - found " ~ *m_char);
        if (m_char + 1 != m_input.end && isNumber(*(m_char + 1)))
            toState(State.Number);
        else
            toState(State.ID);

    }

    private void sStringStart() {
        if (*m_char != '"')
            throw new InternalError("Expected \" found " ~ *m_char);
        drop;
        toState(State.String);
    }

    private void sString() {
        switch (*m_char) {
            case '"':
                drop;
                toState(State.Begin);
                store(State.String);
                break;
            case '\\':
                throw new TokenException("Escape m_chararacters not yet supported");
            default:
                consume;
        }
        drop;
        toState(State.String);
    }

    private void toState(State s) {
        m_state = s;
    }

    private void consume() {
        m_currToken.put(*m_char);
        m_char++;
    }

    auto drop() {
        m_char++;
    }

    auto dupe() {
        m_currToken.put(*m_char);
    }

    private void store(State st) {
        final switch (st) {
            case State.Number:
                try
                    m_tokenized.put(Token(m_currToken.data.to!double));
                catch (ConvException)
                    throw new TokenException("Invalid number " ~ m_currToken.data.idup);
                break;
            case State.String:
                throw new TokenException("Strings not yet supported");
            case State.ID:
                m_tokenized.put(Token(m_currToken.data));
                break;
            case State.Begin:
            case State.Minus:
            case State.Comment:
            case State.StringStart:
                throw new InternalError("Cannot store m_state " ~ st.text);
        }
        m_currToken.clear();
    }

}

unittest {
    import errors;
    import std.exception;

    with (TokenType) {
        // 0 tokens
        const empty = Tokenizer("").run();
        const wsempty = Tokenizer("  \n").run();

        assert(empty.length == 0, "Empty string should produce no tokens");
        assert(wsempty.length == 0, "String with just spaces should produce no tokens");

        // 1 token
        const lbracket = Tokenizer("(").run();
        const rbracket = Tokenizer(")").run();
        const id = Tokenizer("hello").run();
        const charsInId = Tokenizer("yasdf98u3_/..]][]]\\@@$%^&*").run();
        const pinteger = Tokenizer("37").run();
        const ninteger = Tokenizer("-37").run();
        const pfloating = Tokenizer("37.89").run();
        const nfloating = Tokenizer("-37.89").run();
        const traildec = Tokenizer("37.").run();
        const pscip = Tokenizer("1.7e10").run();
        const nscip = Tokenizer("-1.7e10").run();
        const pscin = Tokenizer("1.7e-10").run();
        const nscin = Tokenizer("-1.7e-10").run();

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

        assertThrown!TokenException(Tokenizer("1.2.3").run(), "too many decimal points");
        assertThrown!TokenException(Tokenizer("1e5e5").run(), "too many e");
        assertThrown!TokenException(Tokenizer("1e").run(), "trailing e");
        assertThrown!TokenException(Tokenizer("1e.").run(), "trailing e and decimal point");
        assertThrown!TokenException(Tokenizer("1.e").run(), "trailing decimal point and e");

        // Many tokens
        const openOpenCLose = Tokenizer("(()").run();
        const wsopenOpenCLose = Tokenizer("   (  (  \n\t)\n ").run();
        const closeIdNumOpen = Tokenizer(")i 27(").run();
        const wscloseIdNumOpen = Tokenizer("  )  i\n27\t(").run();
        const define = Tokenizer("(define hello 47)").run();
        const subtract = Tokenizer("(- 49 hello)").run();

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