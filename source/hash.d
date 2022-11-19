module hash;

import std.digest.murmurhash;

alias Hash = MurmurHash3!128;
alias HashRes = DigestType!Hash;

HashRes makeHash(T)(auto ref T t) {
    return digest!Hash(t);
}
