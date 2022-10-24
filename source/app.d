import std.algorithm;
import std.array;
import std.conv;
import std.conv;
import std.digest.crc;
import std.digest.murmurhash;
import std.functional;
import std.exception;
import std.stdio;
import std.string;
import std.math;
import std.traits;

import core.stdc.string: memcpy;

enum tmpSOurce = `
(*Def globalVar1 42)
(*Def globalVar2 "hello")
(*Module helloWorld
    (*Def modVar "world")
    (*Def AAAAA ($ var)
        (*Print var)
    )
    (*Def Main
        (*Print globalVar2 " " modVar " " AAAAA)
    )
)
`;

/*******************.
|       Errors      |
`*******************/

class SyntaxError : Exception {
    mixin basicExceptionCtors;
}

class ArgumentError : Exception {
    mixin basicExceptionCtors;
}

class TypeError : Exception {
    mixin basicExceptionCtors;
}

class InternalError : Error {
    mixin basicExceptionCtors;
}

/*******************.
|       Types       |
`*******************/

mixin template AddPayload(T) {
    T payload;

    this(T p) {
        payload = p;
    }

    this() {
    }

    override bool opEquals(Object o) const {
        if (this is o)
            return true;
        else if (o is null)
            return false;
        else if (const p = cast(typeof(this)) o)
            return payload == p.payload;
        else
            return false;
    }

    bool opEquals(T p) const {
        return payload == p;
    }

    // XXX: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    @trusted
    override size_t toHash() const
    out (r; r != size_t.max) {
        auto d = assertNotThrown(payload.text)
            .digest!(MurmurHash3!128);
        size_t output = void;
        memcpy(&output, &d[0], 8);
        return output;
    }

    override string toString() const {
        return payload.text;
    }
}

class Exp {
    abstract override string toString() const;
}

class Atom : Exp {
    abstract override bool opEquals(Object o) const;
    abstract override size_t toHash() const;
}

class List : Exp {
    mixin AddPayload!(Exp[]);
}

class Symbol : Atom {
    mixin AddPayload!(string);
}

class Number : Atom {
    mixin AddPayload!(double);
}

class Function : Atom {
    alias FunctionT = Exp delegate(List);
    mixin AddPayload!(FunctionT);
}

alias Env = Exp[Symbol];

/*******************.
|       Parser      |
`*******************/

string[] tokenize(string chars) {
    return chars
        .replace("(", " ( ")
        .replace(")", " ) ")
        .split();
}

Exp parse(string program)
in (program !is null) {
    auto tok = program.tokenize;
    writeln("tok = ", tok);
    auto parsed = read_from_tokens(tok);
    writeln("parsed = ", parsed);
    return parsed;
}

Exp read_from_tokens(ref string[] tokens)
in (tokens !is null) {
    if (tokens.length == 0)
        throw new SyntaxError("unexpected EOF");
    auto token = tokens.front;
    tokens.popFront;
    if (token == "(") {
        auto l = new List();
        while (tokens.front != ")")
            l.payload ~= read_from_tokens(tokens);
        tokens.popFront;
        return l;
    } else if (token == ")") {
        throw new SyntaxError("Unexpected )");
    } else
        return atom(token);
}

Atom atom(string token)
in (token !is null) {
    try
        return new Number(token.to!double);
    catch (ConvException)
        return new Symbol(token);
}

/*******************.
|    Environment    |
`*******************/

T forceCast(T, W)(W what) {
    if (auto output = cast(T) what) {
        return output;
    } else {
        throw new TypeError(
            "Expected arguent to be of type "
                ~ typeid(W)
                .text
                .text
                ~ ", got "
                ~ typeid(T).text
                .text
        );
    }

}

void forceCount(size_t n, string func = __FUNCTION__)(List l) {
    if (l.payload.length != n)
        throw new ArgumentError(
            func
                ~ ": Expected "
                ~ n.text
                ~ " arguments, got "
                ~ l.payload.length.text
        );
}

void addNumBinOp(string op)(ref Env env) {
    env[new Symbol(op)] = new Function((List l) {
        l.forceCount!2;
        return new Number(
            binaryFun!('a' ~ op ~ 'b')(
            l.payload.front.forceCast!(Number)
            .payload,
            l.payload.back.forceCast!(Number)
            .payload
        )
        );
    });
}

Env standard_environment;
static this() {
    standard_environment.addNumBinOp!("+");
    standard_environment.addNumBinOp!("-");
    standard_environment.addNumBinOp!("*");
    standard_environment.addNumBinOp!("/");
    standard_environment.addNumBinOp!(">");
    standard_environment.addNumBinOp!("<");
    standard_environment.addNumBinOp!(">=");
    standard_environment.addNumBinOp!("<=");
    standard_environment.addNumBinOp!("==");
    standard_environment[new Symbol("begin")] = new Function((List l) {
        return l.payload.back;
    });
    standard_environment[new Symbol("pi")] = new Number(PI);
}

/*******************.
|        Eval       |
`*******************/

Exp eval(Exp x) {
    return eval(x, standard_environment);
}

Exp eval(Exp x, ref Env env) {
    if (auto sym = cast(Symbol) x) {
        return env[sym];
    } else if (auto num = cast(Number) x) {
        return num;
    } else if (auto list = cast(List) x) {
        if (list.payload.front == new Symbol("if")) {
            list.forceCount!4;
            if (eval(list.payload[1], env).forceCast!Number.payload == 0.0)
                return list.payload[2];
            else
                return list.payload[3];
        } else if (list.payload.front == new Symbol("define")) {
            list.forceCount!3;
            env[list.payload[1].forceCast!Symbol] = list.payload[2];
            return null;
        } else {
            auto proc = (eval(list.payload[0], env)).forceCast!(Function);
            List args = new List();
            foreach (arg; list.payload[1 .. $])
                args.payload ~= eval(arg, env);
            return proc.payload(args);
        }
    } else {
        throw new InternalError("Unexpected type in eval: " ~ typeid(x).text);
    }
}

void main() {
    enum program =
        "
(begin
    (define r 10)
    (if (> 1000 (* pi (* r r)))
        1000
        0
    )
)
";
    program.parse().eval().writeln;
}
