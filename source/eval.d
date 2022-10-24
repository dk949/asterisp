module eval;

import env;
import errors;
import types;
import utils;

import std.conv;
import std.range;

Exp eval(Exp x) {
    return _eval(x, standard_environment);
}

private Exp _eval(Exp x, ref Env env) {
    if (auto sym = cast(Symbol) x) {
        return env[sym];
    } else if (auto num = cast(Number) x) {
        return num;
    } else if (auto list = cast(List) x) {
        if (list.payload.front == new Symbol("if")) {
            list.forceCount!4;
            if (_eval(list.payload[1], env).forceCast!Number.payload == 0.0)
                return list.payload[2];
            else
                return list.payload[3];
        } else if (list.payload.front == new Symbol("define")) {
            list.forceCount!3;
            env[list.payload[1].forceCast!Symbol] = list.payload[2];
            return null;
        } else {
            auto proc = (_eval(list.payload[0], env)).forceCast!(Function);
            List args = new List();
            foreach (arg; list.payload[1 .. $])
                args.payload ~= _eval(arg, env);
            return proc.payload(args);
        }
    } else {
        throw new InternalError("Unexpected type in eval: " ~ typeid(x).text);
    }
}
