module eval;

import env;
import errors;
import types;
import utils;

import std.conv;
import std.range;
import std.algorithm;

Exp eval(Exp x) {
    return _eval(x, standard_environment);
}

private Exp _eval(Exp x, ref Env env)
in (x !is null) {
    if (auto sym = cast(Symbol) x) {
        if (sym in env)
            return env[sym];
        else
            throw new VariableError("No such variable " ~ sym.toString());
    }

    auto list = cast(List) x;

    if (list is null || list.length == 0)
        return x;

    Symbol op = list[0].forceCast!Symbol;
    Exp[] args = list[1 .. $];
    if (op in specialFns) {
        return specialFns[op](args, env);
    } else {
        auto proc = _eval(op, env);
        List vals = new List();
        foreach (arg; args)
            vals ~= _eval(arg, env);

        if (auto fn = cast(Callable) proc)
            return fn.call(vals, env);

        throw new InternalError("Unknown function type");
    }
}

private alias SpecialFn = Exp delegate(ref Exp[], ref Env);
private SpecialFn[Symbol] specialFns;

static this() {
    specialFns = [
        new Symbol("*Def"): (ref args, ref env) {
            args.forceCount!2;
            auto sym = args[0].forceCast!Symbol;
            if (sym.front == '*')
                throw new VariableError("Symbols cannot start with *");
            env[sym] = _eval(args[1], env);
            return env[sym];
        },
        new Symbol("*Fn"): (ref args, ref env) {
            args.forceCount!2;
            return new Procedure(args[0].forceCast!(List)
                    .map!(l => l.forceCast!Symbol)
                    .array, args[1], env, &_eval);
        },
        new Symbol("*If"): (ref args, ref env) {
            args.forceCount!3;
            return _eval(args[0], env).forceCast!(Number).payload
                ? _eval(args[1], env) //
                 : _eval(args[2], env);
        },
    ];
}
