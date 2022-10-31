module types;

import types.utils;

import errors;

import std.conv;
import std.range;

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
    Exp call(List args) {
        return payload(args);
    }
}

struct Env {
    Exp[Symbol] _payload;
    alias _payload this;
    Env* outer;

    static Env subEnv(Symbol[] params = null, List args = null, Env* outer = null) {
        auto output = Env();
        output.outer = outer;
        if (params && args) {
            if (params.length != args.length)
                throw new InternalError(
                    "Number of params != number of args. params.length = "
                        ~ params.length.text
                        ~ " args.length =  "
                        ~ args.length.text
                );
        } else if (params || args) {
            throw new InternalError(
                "Supplied only "
                    ~ (params ? "params" : "args")
                    ~ ". Expected either both or neither."
            );
        }

        foreach (param, arg; zip(params, args))
            output[param] = arg;

        return output;
    }

    ref Exp find(Symbol sym) return {
        if (sym in _payload)
            return this[sym];
        else if (outer)
            return outer.find(sym);
        throw new VariableError("No such variable: " ~ sym);
    }
}

class Procedure : Exp {
    Symbol[] params;
    Exp body;
    Env env;
    this(Symbol[] params, Exp body, Env env) {
        this.params = params;
        this.body = body;
        this.env = env;
    }

    override string toString() const {
        string output = ("Fn(" ~ params[0].toString);

        foreach (param; params[1 .. $]) {
            output ~= ", " ~ param.toString;
        }
        output ~= ")";
        return output;
    }
}
