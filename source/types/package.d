module types;

import types.utils;

import errors;

import std.conv;
import std.range;
import std.traits;

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
    import std.math;

    mixin AddPayload!(double);

    bool isWhole() const {
        return rint(payload) == payload;
    }

    int opCmp(Number o) const {
        return cast(int)(sgn(payload - o.payload));
    }

    int opCmp(N)(N o) const
    if (isNumeric!N) {
        return cast(int)(sgn(payload - o));
    }
}

class String : Atom {
    mixin AddPayload!(string);
}

class Callable : Atom {
    abstract Exp call(List args, Env env);
}

class Function : Callable {
    alias FunctionT = Exp delegate(List);
    mixin AddPayload!(FunctionT);
    override Exp call(List args, Env) {
        return payload(args);
    }
}

class Procedure : Callable {
    alias EvalT = Exp function(Exp x, ref Env env);
    Symbol[] params;
    Exp body;
    Env env;
    EvalT eval;
    this(Symbol[] params, Exp body, Env env, EvalT eval) {
        this.params = params;
        this.body = body;
        this.env = env;
        this.eval = eval;
    }

    override string toString() const {
        string output = "Fn(";
        if (params && params.length > 0) {
            output ~= params[0].toString;

            foreach (param; params.drop(1))
                output ~= ", " ~ param.toString;

        }
        output ~= ")";
        return output;
    }

    override Exp call(List args, Env env) {
        auto newEnv = env.subEnv(params, args, &env);
        return eval(body, newEnv);
    }

    override bool opEquals(Object o) const {
        if (this is o)
            return true;
        else if (o is null)
            return false;
        else if (const p = cast(typeof(this)) o) {
            return params == p.params
                && body == p.body
                && env == p.env
                && eval == p.eval;
        } else
            return false;
    }

    override size_t toHash() const {
        size_t output = 0;
        foreach (sym; params)
            output = sym.toHash ^ (output << 1);
        foreach (sym; env.keys)
            output = sym.toHash ^ (output << 1);
        output = cast(size_t)(&eval) ^ (output << 1);
        if (auto at = cast(const(Atom))
            body)
            output = at.toHash ^ (output << 1);
        return output;
    }
}

struct Env {
    Exp[Symbol] _payload;
    alias _payload this;
    Env* outer;

    Env subEnv(Symbol[] params = null, List args = null, Env* outer = null) {
        auto output = this;
        output.outer = outer;
        if (params.length > 0 && args.length > 0) {
            if (params.length != args.length)
                throw new ArgumentError(
                    "Function expected "
                        ~ params.length.text
                        ~ " arguments, but received "
                        ~ args.length.text
                );
        } else if (params.length > 0 || args.length > 0) {
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
