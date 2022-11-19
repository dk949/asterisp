module package_;

import errors;
import types;
import utils;
import hash;

import std.array;

class Package {
    Exp config;
    Exp[] defines;
    Exp mainFn;
    HashRes digest;
    this(Exp[] exps, HashRes h) {
        digest = h;

        auto defs = appender!(Exp[]);

        foreach (exp; exps) {
            const lst = exp.forceCast!List("expression at package scope");
            lst.forceAtLeast!1("item in an expression at package scope");
            const sym = lst.front.forceCast!Symbol(1.thArgOf("expression at package scope"));
            switch (sym) {
                case "*Def":
                case "*Defn":
                    defs.put(exp);
                    break;
                case "*Main":
                    if (!mainFn)
                        mainFn = exp;
                    else
                        throw new SemanticError("Expected only one `*Main` per application");
                    break;
                default:
                    throw new SemanticError(
                        "Expected either a definition or `*Main` at package scope");
            }
        }
        defines = defs.data;
    }
}
