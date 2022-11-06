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

    if (list is null)
        return x;
    if (list.length == 0)
        throw new InternalError("Cannot handle empty list in eval");

    Symbol op = list[0].forceCast!Symbol;
    Exp[] args = list[1 .. $];
    if (op == "quote")
        throw new InternalError("quote is not supported yet");
    else if (op == "if") {
        args.forceCount!3;
        if (_eval(args[0], env).forceCast!(Number).payload)
            return args[1];
        else
            return args[2];
    } else if (op == "define") {
        args.forceCount!2;
        env[args[0].forceCast!Symbol] = _eval(args[1], env);
        return null;
    } else if (op == "set!") {
        args.forceCount!2;
        env.find(args[0].forceCast!Symbol) = args[1];
        return null;
    } else if (op == "lambda") {
        args.forceCount!2;
        return new Procedure(
            args[0]
                .forceCast!(List)
                .map!(l => l.forceCast!Symbol)
                .array,
                args[1],
                env,
                &_eval
        );
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
