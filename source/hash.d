module hash;
import std.traits;

size_t combineHash(Args...)(auto ref Args args) {
    size_t hash = 0;
    size_t i = 0;
    foreach (arg; args) // NOTE:
        //   https://dlang.org/library/object/hash_of.html suggests `hash = arg.hashOf(hash);`
        //   as a valid way to combine hashes. Testing this showed that it performs
        //   suboptimally (in terms of hash quality) if the last argument is a string
        hash = arg.sHashOf() ^ (hash << 1);

    return hash.sHashOf();
}

size_t sHashOf(T)(auto ref T t)
if (!isIntegral!(T)) {
    return t.hashOf();
}

size_t sHashOf(T)(auto ref T t)
if (isIntegral!(T)) {
    return t.hashOf(t);
}
