module package_;
import types;
import errors;
import utils;
import std.stdio;
import std.range;
import std.array;

class Package {
    Exp config;
    Exp[] defines;
    Exp mainFn;
    this(Exp[] exps) {
        auto defs = appender!(Exp[]);

        foreach (exp; exps) {
            const lst = exp.forceCast!List("expression at package scope");
            lst.forceAtLeast!1("item in an expression at package scope");
            const sym = lst.front.forceCast!Symbol;
            switch (sym) {
                case "*Def":
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
