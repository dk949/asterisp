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

    Symbol op = list.front.forceCast!Symbol(1.thArgOf("expression"));
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

private Symbol checkNewSym(Symbol sym, const(Env) env) {
    if (sym.front == '*')
        throw new VariableError("Symbols cannot start with *");
    if (sym in env)
        throw new VariableError("redefinition of " ~ sym);
    return sym;
}

private Symbol[] fnSymbolList(List params) {
    Symbol[] syms = new Symbol[params.length];

    foreach (i, param; params.enumerate)
        syms[i] = param.forceCast!Symbol((i + 1).thArgOf("*Fn parameter list"));
    return syms;
}

static this() {
    specialFns = [
        new Symbol("*Def"): (ref args, ref env) {
            args.forceCount!2;
            auto sym = args[0].forceCast!Symbol(1.thArgOf("*Def"));
            env[sym.checkNewSym(env)] = eval(args[1], env);
            return env[sym];
        },
        new Symbol("*Fn"): (ref args, ref env) {
            args.forceCount!2;
            auto params = args[0].forceCast!List(1.thArgOf("*Fn"));
            return new Procedure(params.fnSymbolList, args[1], env, &eval);
        },
        new Symbol("*Defn"): (ref args, ref env) {
            args.forceCount!3;
            auto sym = args[0].forceCast!Symbol(1.thArgOf("*Defn"));
            auto params = args[1].forceCast!List(2.thArgOf("*Defn"));
            env[sym.checkNewSym(env)] = new Procedure(params.fnSymbolList, args[2], env, &eval);
            return env[sym];
        },
        new Symbol("*If"): (ref args, ref env) {
            args.forceCount!3;
            return eval(args[0], env).forceCast!Number(1.thArgOf("*If"))
                .payload
                ? eval(args[1], env) //
                 : eval(args[2], env);
        },
    ];
}
