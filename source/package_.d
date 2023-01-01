module package_;

import errors;
import types;
import utils;

import std.array;
import std.range;

class Package {
    Exp config;
    Exp[] defines;
    Exp mainFn;
    size_t digest;
    this(Exp[] exps, size_t h) {
        digest = h;

        auto defs = appender!(Exp[]);

        foreach (i, exp; exps.enumerate) {
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
                case "*Config":
                    if (i != 0)
                        throw new SemanticError(
                            "Expected `*Config` to be the first expression in a package");
                    else if (config)
                        throw new SemanticError("Expected only one `*Config` per package");
                    else
                        config = exp;
                    break;
                default:
                    throw new SemanticError(
                        "Expected either a definition, `*Config` or `*Main` at package scope");
            }
        }
        defines = defs.data;
    }
}
