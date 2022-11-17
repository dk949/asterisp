module tokenizer.utils;

import std.traits;

ElementType!R* begin(R)(auto ref R r)
if (!isSomeString!R && isInputRange!R) {
    return &r.front;
}

ElementType!R* end(R)(auto ref R r)
if (!isSomeString!R && isBidirectionalRange!R) {
    return (&r.back) + 1;
}

auto begin(R)(auto ref R r)
if (isSomeString!R) {
    return &r[0];
}

auto end(R)(auto ref R r)
if (isSomeString!R) {
    return (&r[$ - 1]) + 1;
}
