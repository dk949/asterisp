module eval;

import env;
import errors;
import package_;
import types;
import utils;

import std.algorithm;
import std.range;

Exp eval(Exp x) {
    return eval(x, standard_environment);
}

Exp eval(Package p) {
    auto eviron = standard_environment;
    foreach (def; p.defines)
        def.eval(eviron);
    if (p.mainFn)
        return p.mainFn.eval(eviron);
    else
        return null;
}

private Exp eval(Exp x, ref Env env)
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
        auto proc = eval(op, env);
        List vals = new List();
        foreach (arg; args)
            vals ~= eval(arg, env);

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
            if (sym in env)
                throw new VariableError("redefinition of " ~ sym);
            env[sym] = eval(args[1], env);
            return env[sym];
        },
        new Symbol("*Fn"): (ref args, ref env) {
            args.forceCount!2;
            return new Procedure(args[0].forceCast!(List)
                    .map!(l => l.forceCast!Symbol)
                    .array, args[1], env, &eval);
        },
        new Symbol("*If"): (ref args, ref env) {
            args.forceCount!3;
            return eval(args[0], env).forceCast!(Number).payload
                ? eval(args[1], env) //
                 : eval(args[2], env);
        },
    ];
}
