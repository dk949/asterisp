module types.utils;

mixin template AddPayload(T) {

    T payload;
    alias payload this;

    this(T p) {
        payload = p;
    }

    this() {
    }

    override bool opEquals(Object o) const {
        if (this is o)
            return true;
        else if (o is null)
            return false;
        else if (const p = cast(typeof(this)) o)
            return payload == p.payload;
        else
            return false;
    }

    bool opEquals(T p) const {
        return payload == p;
    }

    @trusted
    override size_t toHash() const {
        return payload.sHashOf;
    }

    override string toString() const {
        return payload.text;
    }
}
