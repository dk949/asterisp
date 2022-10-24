module types;

import types.utils;

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
    mixin AddPayload!(double);
}

class Function : Atom {
    alias FunctionT = Exp delegate(List);
    mixin AddPayload!(FunctionT);
}

alias Env = Exp[Symbol];
