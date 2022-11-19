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

    // XXX: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    @trusted
    override size_t toHash() const
    out (r; r != size_t.max) {

        auto d = assertNotThrown(payload.text).makeHash;
        size_t output = void;
        memcpy(&output, &d[0], 8);
        return output;
    }

    override string toString() const {

        return payload.text;
    }
}
