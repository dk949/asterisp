module envconfig;
import std.process;
import std.traits;

/*
    bool, "traceback", "ASTR_TRACEBACK"
*/

public:

class EnvConfig {
    mixin setup!([
            Var("ASTR_TRACEBACK", null)
        ]);
}

static this() {
    envcfg_ = new EnvConfig();
}

const(EnvConfig) envcfg() {
    return envcfg_;
}

private:

EnvConfig envcfg_;

struct Var {
    string field;
    string def;
}

mixin template setup(Var[] vars) {
    static foreach (var; vars)
        mixin("string " ~ var.field ~ ";");

    package this() {
        static foreach (var; vars) {
            alias mem = __traits(getMember, this, var.field);
            static if (isFunction!(mem))
                continue;
            mem = environment.get(var.field, var.def);
        }
    }
}
